-- ============================================================================
-- CardSense AI Database Schema - Functions & Stored Procedures
-- ============================================================================
-- 
-- Purpose: Define reusable database functions and stored procedures
-- Version: 1.0.0
-- Compatible with: PostgreSQL 13+, Supabase
-- 
-- Functions included:
-- - User management functions
-- - Transaction processing functions
-- - Analytics and reporting functions
-- - Data validation functions
-- - Utility functions
-- 
-- ============================================================================

-- ============================================================================
-- USER MANAGEMENT FUNCTIONS
-- ============================================================================

-- Function to create user profile after authentication
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_profiles (
        id,
        email,
        created_at,
        updated_at,
        onboarding_completed,
        notification_preferences
    )
    VALUES (
        NEW.id,
        NEW.email,
        NOW(),
        NOW(),
        false,
        jsonb_build_object(
            'email_notifications', true,
            'push_notifications', true,
            'sms_notifications', false,
            'spending_alerts', true,
            'payment_reminders', true,
            'weekly_summary', true
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update user last active timestamp
CREATE OR REPLACE FUNCTION update_user_last_active(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE user_profiles 
    SET 
        last_active_at = NOW(),
        updated_at = NOW()
    WHERE id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user has completed onboarding
CREATE OR REPLACE FUNCTION is_onboarding_complete(user_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    is_complete BOOLEAN := false;
BEGIN
    SELECT onboarding_completed INTO is_complete
    FROM user_profiles
    WHERE id = user_uuid;
    
    RETURN COALESCE(is_complete, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- TRANSACTION PROCESSING FUNCTIONS
-- ============================================================================

-- Function to categorize transactions automatically
CREATE OR REPLACE FUNCTION auto_categorize_transaction(
    description TEXT,
    merchant_name TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    category_id UUID;
    search_text TEXT;
BEGIN
    -- Prepare search text (lowercase for case-insensitive matching)
    search_text := LOWER(COALESCE(description, '') || ' ' || COALESCE(merchant_name, ''));
    
    -- Try to find category based on description patterns
    SELECT id INTO category_id
    FROM spending_categories
    WHERE 
        enabled = true
        AND (
            -- Check if any keywords match
            EXISTS (
                SELECT 1 
                FROM unnest(string_to_array(LOWER(keywords), ',')) AS keyword
                WHERE search_text LIKE '%' || TRIM(keyword) || '%'
            )
            OR
            -- Check merchant name patterns
            (merchant_name IS NOT NULL AND LOWER(name) = LOWER(merchant_name))
        )
    ORDER BY 
        -- Prioritize exact merchant matches
        CASE WHEN LOWER(name) = LOWER(COALESCE(merchant_name, '')) THEN 1 ELSE 2 END,
        created_at ASC
    LIMIT 1;
    
    -- If no category found, assign to "Other"
    IF category_id IS NULL THEN
        SELECT id INTO category_id
        FROM spending_categories
        WHERE name = 'Other' AND enabled = true
        LIMIT 1;
    END IF;
    
    RETURN category_id;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate monthly spending summary
CREATE OR REPLACE FUNCTION calculate_monthly_summary(
    user_uuid UUID,
    summary_month DATE
)
RETURNS VOID AS $$
DECLARE
    month_start DATE;
    month_end DATE;
    total_spent DECIMAL(10,2);
    transaction_count INTEGER;
    category_breakdown JSONB;
BEGIN
    -- Calculate month boundaries
    month_start := date_trunc('month', summary_month);
    month_end := (month_start + INTERVAL '1 month' - INTERVAL '1 day');
    
    -- Calculate total spending for the month
    SELECT 
        COALESCE(SUM(amount), 0),
        COUNT(*)
    INTO total_spent, transaction_count
    FROM transactions
    WHERE 
        user_id = user_uuid
        AND transaction_date >= month_start
        AND transaction_date <= month_end
        AND amount > 0; -- Only count expenses
    
    -- Calculate category breakdown
    SELECT jsonb_object_agg(
        sc.name,
        jsonb_build_object(
            'amount', COALESCE(category_totals.total, 0),
            'count', COALESCE(category_totals.count, 0),
            'percentage', CASE 
                WHEN total_spent > 0 THEN ROUND((COALESCE(category_totals.total, 0) / total_spent) * 100, 2)
                ELSE 0
            END
        )
    ) INTO category_breakdown
    FROM spending_categories sc
    LEFT JOIN (
        SELECT 
            t.spending_category_id,
            SUM(t.amount) as total,
            COUNT(*) as count
        FROM transactions t
        WHERE 
            t.user_id = user_uuid
            AND t.transaction_date >= month_start
            AND t.transaction_date <= month_end
            AND t.amount > 0
        GROUP BY t.spending_category_id
    ) category_totals ON sc.id = category_totals.spending_category_id
    WHERE sc.enabled = true;
    
    -- Insert or update summary
    INSERT INTO spending_summaries (
        user_id,
        month,
        total_spent,
        transaction_count,
        category_breakdown,
        created_at,
        updated_at
    )
    VALUES (
        user_uuid,
        month_start,
        total_spent,
        transaction_count,
        category_breakdown,
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id, month)
    DO UPDATE SET
        total_spent = EXCLUDED.total_spent,
        transaction_count = EXCLUDED.transaction_count,
        category_breakdown = EXCLUDED.category_breakdown,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to process new transaction
CREATE OR REPLACE FUNCTION process_transaction()
RETURNS TRIGGER AS $$
DECLARE
    category_id UUID;
BEGIN
    -- Auto-categorize if category not provided
    IF NEW.spending_category_id IS NULL THEN
        NEW.spending_category_id := auto_categorize_transaction(
            NEW.description,
            NEW.merchant_name
        );
    END IF;
    
    -- Set default values
    NEW.created_at := COALESCE(NEW.created_at, NOW());
    NEW.updated_at := NOW();
    
    -- Update monthly summary (async via trigger after insert)
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ANALYTICS FUNCTIONS
-- ============================================================================

-- Function to get user spending trends
CREATE OR REPLACE FUNCTION get_spending_trends(
    user_uuid UUID,
    months_back INTEGER DEFAULT 6
)
RETURNS TABLE(
    month DATE,
    total_spent DECIMAL(10,2),
    transaction_count INTEGER,
    avg_transaction DECIMAL(10,2),
    month_over_month_change DECIMAL(5,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH monthly_data AS (
        SELECT 
            ss.month,
            ss.total_spent,
            ss.transaction_count,
            CASE 
                WHEN ss.transaction_count > 0 
                THEN ROUND(ss.total_spent / ss.transaction_count, 2)
                ELSE 0
            END as avg_transaction,
            LAG(ss.total_spent) OVER (ORDER BY ss.month) as prev_month_spent
        FROM spending_summaries ss
        WHERE 
            ss.user_id = user_uuid
            AND ss.month >= (CURRENT_DATE - (months_back || ' months')::INTERVAL)
        ORDER BY ss.month DESC
    )
    SELECT 
        md.month,
        md.total_spent,
        md.transaction_count,
        md.avg_transaction,
        CASE 
            WHEN md.prev_month_spent IS NOT NULL AND md.prev_month_spent > 0
            THEN ROUND(((md.total_spent - md.prev_month_spent) / md.prev_month_spent) * 100, 2)
            ELSE NULL
        END as month_over_month_change
    FROM monthly_data md;
END;
$$ LANGUAGE plpgsql;

-- Function to get top spending categories
CREATE OR REPLACE FUNCTION get_top_categories(
    user_uuid UUID,
    time_period INTERVAL DEFAULT '30 days'::INTERVAL,
    limit_count INTEGER DEFAULT 5
)
RETURNS TABLE(
    category_name TEXT,
    total_amount DECIMAL(10,2),
    transaction_count INTEGER,
    avg_transaction DECIMAL(10,2),
    percentage_of_total DECIMAL(5,2)
) AS $$
DECLARE
    total_spending DECIMAL(10,2);
BEGIN
    -- Calculate total spending for percentage calculation
    SELECT COALESCE(SUM(amount), 0) INTO total_spending
    FROM transactions
    WHERE 
        user_id = user_uuid
        AND transaction_date >= (CURRENT_DATE - time_period)
        AND amount > 0;
    
    RETURN QUERY
    SELECT 
        sc.name as category_name,
        COALESCE(SUM(t.amount), 0) as total_amount,
        COUNT(t.id)::INTEGER as transaction_count,
        CASE 
            WHEN COUNT(t.id) > 0 
            THEN ROUND(COALESCE(SUM(t.amount), 0) / COUNT(t.id), 2)
            ELSE 0::DECIMAL(10,2)
        END as avg_transaction,
        CASE 
            WHEN total_spending > 0 
            THEN ROUND((COALESCE(SUM(t.amount), 0) / total_spending) * 100, 2)
            ELSE 0::DECIMAL(5,2)
        END as percentage_of_total
    FROM spending_categories sc
    LEFT JOIN transactions t ON (
        sc.id = t.spending_category_id
        AND t.user_id = user_uuid
        AND t.transaction_date >= (CURRENT_DATE - time_period)
        AND t.amount > 0
    )
    WHERE sc.enabled = true
    GROUP BY sc.id, sc.name
    HAVING COALESCE(SUM(t.amount), 0) > 0
    ORDER BY total_amount DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- NOTIFICATION FUNCTIONS
-- ============================================================================

-- Function to create notification
CREATE OR REPLACE FUNCTION create_notification(
    user_uuid UUID,
    notification_type TEXT,
    title TEXT,
    message TEXT,
    data_payload JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO notifications (
        id,
        user_id,
        type,
        title,
        message,
        data,
        created_at
    )
    VALUES (
        uuid_generate_v4(),
        user_uuid,
        notification_type,
        title,
        message,
        data_payload,
        NOW()
    )
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql;

-- Function to check spending alerts
CREATE OR REPLACE FUNCTION check_spending_alerts(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
    monthly_spending DECIMAL(10,2);
    weekly_spending DECIMAL(10,2);
    daily_spending DECIMAL(10,2);
    monthly_limit DECIMAL(10,2);
    weekly_limit DECIMAL(10,2);
    daily_limit DECIMAL(10,2);
    user_prefs JSONB;
BEGIN
    -- Get user preferences
    SELECT notification_preferences INTO user_prefs
    FROM user_profiles
    WHERE id = user_uuid;
    
    -- Only proceed if spending alerts are enabled
    IF NOT COALESCE(user_prefs->>'spending_alerts', 'true')::BOOLEAN THEN
        RETURN;
    END IF;
    
    -- Calculate current spending periods
    SELECT COALESCE(SUM(amount), 0) INTO monthly_spending
    FROM transactions
    WHERE 
        user_id = user_uuid
        AND transaction_date >= date_trunc('month', CURRENT_DATE)
        AND amount > 0;
    
    SELECT COALESCE(SUM(amount), 0) INTO weekly_spending
    FROM transactions
    WHERE 
        user_id = user_uuid
        AND transaction_date >= date_trunc('week', CURRENT_DATE)
        AND amount > 0;
    
    SELECT COALESCE(SUM(amount), 0) INTO daily_spending
    FROM transactions
    WHERE 
        user_id = user_uuid
        AND transaction_date >= CURRENT_DATE
        AND amount > 0;
    
    -- Get spending limits (you'd typically store these in user preferences)
    monthly_limit := COALESCE((user_prefs->>'monthly_limit')::DECIMAL(10,2), 5000);
    weekly_limit := COALESCE((user_prefs->>'weekly_limit')::DECIMAL(10,2), 1200);
    daily_limit := COALESCE((user_prefs->>'daily_limit')::DECIMAL(10,2), 200);
    
    -- Check monthly limit (80% warning, 100% alert)
    IF monthly_spending >= monthly_limit THEN
        PERFORM create_notification(
            user_uuid,
            'spending_limit_exceeded',
            'Monthly Budget Exceeded',
            FORMAT('You have spent $%.2f this month, exceeding your $%.2f limit.', monthly_spending, monthly_limit),
            jsonb_build_object('period', 'monthly', 'spent', monthly_spending, 'limit', monthly_limit)
        );
    ELSIF monthly_spending >= (monthly_limit * 0.8) THEN
        PERFORM create_notification(
            user_uuid,
            'spending_limit_warning',
            'Monthly Budget Warning',
            FORMAT('You have spent $%.2f this month, which is 80%% of your $%.2f limit.', monthly_spending, monthly_limit),
            jsonb_build_object('period', 'monthly', 'spent', monthly_spending, 'limit', monthly_limit)
        );
    END IF;
    
    -- Similar checks for weekly and daily limits
    IF weekly_spending >= weekly_limit THEN
        PERFORM create_notification(
            user_uuid,
            'spending_limit_exceeded',
            'Weekly Budget Exceeded',
            FORMAT('You have spent $%.2f this week, exceeding your $%.2f limit.', weekly_spending, weekly_limit),
            jsonb_build_object('period', 'weekly', 'spent', weekly_spending, 'limit', weekly_limit)
        );
    END IF;
    
    IF daily_spending >= daily_limit THEN
        PERFORM create_notification(
            user_uuid,
            'spending_limit_exceeded',
            'Daily Budget Exceeded',
            FORMAT('You have spent $%.2f today, exceeding your $%.2f limit.', daily_spending, daily_limit),
            jsonb_build_object('period', 'daily', 'spent', daily_spending, 'limit', daily_limit)
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Function to clean old data
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS VOID AS $$
BEGIN
    -- Delete old notifications (older than 90 days)
    DELETE FROM notifications
    WHERE created_at < (CURRENT_DATE - INTERVAL '90 days');
    
    -- Delete old user engagement data (older than 1 year)
    DELETE FROM user_engagement
    WHERE created_at < (CURRENT_DATE - INTERVAL '1 year');
    
    -- Archive old transactions (optional - you might want to keep these)
    -- This is just an example, adjust retention policy as needed
    
    RAISE NOTICE 'Cleanup completed successfully';
END;
$$ LANGUAGE plpgsql;

-- Function to validate credit card number format (basic validation)
CREATE OR REPLACE FUNCTION validate_card_number(card_number TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Basic validation: only digits, 13-19 characters
    RETURN card_number ~ '^[0-9]{13,19}$';
END;
$$ LANGUAGE plpgsql;

-- Function to mask credit card number (show only last 4 digits)
CREATE OR REPLACE FUNCTION mask_card_number(card_number TEXT)
RETURNS TEXT AS $$
BEGIN
    IF LENGTH(card_number) < 4 THEN
        RETURN '****';
    END IF;
    
    RETURN REPEAT('*', LENGTH(card_number) - 4) || RIGHT(card_number, 4);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Function to update updated_at timestamp
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- END OF FUNCTIONS
-- ============================================================================ 