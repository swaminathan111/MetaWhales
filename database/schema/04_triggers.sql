-- ============================================================================
-- CardSense AI Database Schema - Triggers & Automation
-- ============================================================================
-- 
-- Purpose: Implement automated data management and business logic
-- Version: 1.0.0
-- Compatible with: PostgreSQL 13+, Supabase
-- 
-- Trigger Categories:
-- - Timestamp management (updated_at fields)
-- - Data validation and business rules
-- - Automated calculations (balances, summaries)
-- - Audit trails and logging
-- - Notification triggers
-- 
-- ============================================================================

-- ============================================================================
-- 1. UTILITY FUNCTIONS FOR TRIGGERS
-- ============================================================================

-- Generic function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to validate email format
CREATE OR REPLACE FUNCTION validate_email_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email IS NOT NULL AND NEW.email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to ensure only one primary card per user
CREATE OR REPLACE FUNCTION enforce_single_primary_card()
RETURNS TRIGGER AS $$
BEGIN
    -- If setting a card as primary, unset all other primary cards for this user
    IF NEW.is_primary = TRUE THEN
        UPDATE user_cards 
        SET is_primary = FALSE 
        WHERE user_id = NEW.user_id 
        AND id != NEW.id 
        AND is_primary = TRUE;
    END IF;
    
    -- Ensure at least one active card is primary
    IF NEW.is_primary = FALSE AND NEW.status = 'active' THEN
        -- Check if this was the only primary card
        IF NOT EXISTS (
            SELECT 1 FROM user_cards 
            WHERE user_id = NEW.user_id 
            AND is_primary = TRUE 
            AND status = 'active'
            AND id != NEW.id
        ) THEN
            -- Make this card primary if no other primary card exists
            NEW.is_primary = TRUE;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate available credit
CREATE OR REPLACE FUNCTION calculate_available_credit()
RETURNS TRIGGER AS $$
BEGIN
    -- Only calculate for credit cards
    IF NEW.card_type = 'credit' AND NEW.credit_limit IS NOT NULL THEN
        NEW.available_credit = NEW.credit_limit - COALESCE(NEW.current_balance, 0);
        
        -- Ensure available credit is not negative
        IF NEW.available_credit < 0 THEN
            NEW.available_credit = 0;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update conversation message count
CREATE OR REPLACE FUNCTION update_conversation_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Update message count and last message time
        UPDATE chat_conversations 
        SET 
            total_messages = total_messages + 1,
            last_message_at = NEW.created_at,
            updated_at = NOW()
        WHERE id = NEW.conversation_id;
        
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Decrease message count
        UPDATE chat_conversations 
        SET 
            total_messages = GREATEST(total_messages - 1, 0),
            updated_at = NOW()
        WHERE id = OLD.conversation_id;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to update user last active timestamp
CREATE OR REPLACE FUNCTION update_user_last_active()
RETURNS TRIGGER AS $$
BEGIN
    -- Update user's last active timestamp
    UPDATE user_profiles 
    SET last_active_at = NOW() 
    WHERE id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to validate transaction amount
CREATE OR REPLACE FUNCTION validate_transaction_amount()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure positive amount
    IF NEW.amount <= 0 THEN
        RAISE EXCEPTION 'Transaction amount must be positive: %', NEW.amount;
    END IF;
    
    -- Validate currency code
    IF NEW.currency IS NOT NULL AND LENGTH(NEW.currency) != 3 THEN
        RAISE EXCEPTION 'Currency code must be 3 characters: %', NEW.currency;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to auto-categorize transactions
CREATE OR REPLACE FUNCTION auto_categorize_transaction()
RETURNS TRIGGER AS $$
DECLARE
    category_id UUID;
BEGIN
    -- Only auto-categorize if no category is set
    IF NEW.category_id IS NULL THEN
        -- Simple keyword-based categorization
        SELECT id INTO category_id
        FROM spending_categories
        WHERE is_active = TRUE
        AND (
            LOWER(NEW.description) LIKE '%grocery%' OR
            LOWER(NEW.description) LIKE '%supermarket%' OR
            LOWER(NEW.merchant_name) LIKE '%grocery%'
        )
        AND name = 'Groceries'
        LIMIT 1;
        
        -- If no specific match, use 'Other' category
        IF category_id IS NULL THEN
            SELECT id INTO category_id
            FROM spending_categories
            WHERE name = 'Other' AND is_active = TRUE
            LIMIT 1;
        END IF;
        
        NEW.category_id = category_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update card balance after transaction
CREATE OR REPLACE FUNCTION update_card_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Update card balance based on transaction type
        IF NEW.transaction_type IN ('purchase', 'fee', 'interest') THEN
            -- Increase balance for purchases and fees
            UPDATE user_cards 
            SET 
                current_balance = current_balance + NEW.amount,
                updated_at = NOW()
            WHERE id = NEW.card_id;
        ELSIF NEW.transaction_type IN ('payment', 'refund') THEN
            -- Decrease balance for payments and refunds
            UPDATE user_cards 
            SET 
                current_balance = GREATEST(current_balance - NEW.amount, 0),
                updated_at = NOW()
            WHERE id = NEW.card_id;
        END IF;
        
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Reverse the balance change
        IF OLD.transaction_type IN ('purchase', 'fee', 'interest') THEN
            UPDATE user_cards 
            SET 
                current_balance = GREATEST(current_balance - OLD.amount, 0),
                updated_at = NOW()
            WHERE id = OLD.card_id;
        ELSIF OLD.transaction_type IN ('payment', 'refund') THEN
            UPDATE user_cards 
            SET 
                current_balance = current_balance + OLD.amount,
                updated_at = NOW()
            WHERE id = OLD.card_id;
        END IF;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to create spending summary
CREATE OR REPLACE FUNCTION update_spending_summary()
RETURNS TRIGGER AS $$
DECLARE
    summary_year INTEGER;
    summary_month INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        summary_year = EXTRACT(YEAR FROM NEW.transaction_date);
        summary_month = EXTRACT(MONTH FROM NEW.transaction_date);
        
        -- Insert or update spending summary
        INSERT INTO spending_summaries (
            user_id, year, month, total_spent, total_transactions,
            average_transaction_amount, largest_transaction_amount
        )
        VALUES (
            NEW.user_id, summary_year, summary_month, NEW.amount, 1,
            NEW.amount, NEW.amount
        )
        ON CONFLICT (user_id, year, month)
        DO UPDATE SET
            total_spent = spending_summaries.total_spent + NEW.amount,
            total_transactions = spending_summaries.total_transactions + 1,
            average_transaction_amount = (spending_summaries.total_spent + NEW.amount) / (spending_summaries.total_transactions + 1),
            largest_transaction_amount = GREATEST(spending_summaries.largest_transaction_amount, NEW.amount),
            updated_at = NOW();
            
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to check for alert conditions
CREATE OR REPLACE FUNCTION check_alert_conditions()
RETURNS TRIGGER AS $$
DECLARE
    alert_rule RECORD;
    should_alert BOOLEAN;
BEGIN
    -- Check all active alert rules for this user/card
    FOR alert_rule IN 
        SELECT * FROM alert_rules 
        WHERE user_id = NEW.user_id 
        AND (card_id IS NULL OR card_id = NEW.card_id)
        AND is_active = TRUE
    LOOP
        should_alert = FALSE;
        
        -- Check different rule types
        CASE alert_rule.rule_type
            WHEN 'high_amount' THEN
                IF NEW.amount >= (alert_rule.conditions->>'threshold')::DECIMAL THEN
                    should_alert = TRUE;
                END IF;
            WHEN 'daily_limit' THEN
                -- Check if daily spending exceeds limit
                IF (
                    SELECT COALESCE(SUM(amount), 0) 
                    FROM transactions 
                    WHERE user_id = NEW.user_id 
                    AND DATE(transaction_date) = DATE(NEW.transaction_date)
                ) >= (alert_rule.conditions->>'daily_limit')::DECIMAL THEN
                    should_alert = TRUE;
                END IF;
            WHEN 'merchant_alert' THEN
                IF LOWER(NEW.merchant_name) LIKE LOWER('%' || (alert_rule.conditions->>'merchant_pattern') || '%') THEN
                    should_alert = TRUE;
                END IF;
        END CASE;
        
        -- Create notification if alert condition is met
        IF should_alert THEN
            INSERT INTO notifications (
                user_id, title, message, notification_type, priority
            ) VALUES (
                NEW.user_id,
                COALESCE(alert_rule.notification_title, 'Transaction Alert'),
                COALESCE(alert_rule.notification_message, 'Alert condition triggered for transaction'),
                'transaction_alert',
                'high'
            );
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 2. TIMESTAMP TRIGGERS
-- ============================================================================

-- User profiles updated_at trigger
CREATE TRIGGER trigger_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Card issuers updated_at trigger
CREATE TRIGGER trigger_card_issuers_updated_at
    BEFORE UPDATE ON card_issuers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Card categories updated_at trigger
CREATE TRIGGER trigger_card_categories_updated_at
    BEFORE UPDATE ON card_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- User cards updated_at trigger
CREATE TRIGGER trigger_user_cards_updated_at
    BEFORE UPDATE ON user_cards
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Spending categories updated_at trigger
CREATE TRIGGER trigger_spending_categories_updated_at
    BEFORE UPDATE ON spending_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Transactions updated_at trigger
CREATE TRIGGER trigger_transactions_updated_at
    BEFORE UPDATE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Chat conversations updated_at trigger
CREATE TRIGGER trigger_chat_conversations_updated_at
    BEFORE UPDATE ON chat_conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Chat messages updated_at trigger
CREATE TRIGGER trigger_chat_messages_updated_at
    BEFORE UPDATE ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Alert rules updated_at trigger
CREATE TRIGGER trigger_alert_rules_updated_at
    BEFORE UPDATE ON alert_rules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Spending summaries updated_at trigger
CREATE TRIGGER trigger_spending_summaries_updated_at
    BEFORE UPDATE ON spending_summaries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 3. VALIDATION TRIGGERS
-- ============================================================================

-- Email validation trigger
CREATE TRIGGER trigger_validate_user_email
    BEFORE INSERT OR UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION validate_email_format();

-- Transaction amount validation trigger
CREATE TRIGGER trigger_validate_transaction_amount
    BEFORE INSERT OR UPDATE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION validate_transaction_amount();

-- ============================================================================
-- 4. BUSINESS LOGIC TRIGGERS
-- ============================================================================

-- Primary card enforcement trigger
CREATE TRIGGER trigger_enforce_primary_card
    BEFORE INSERT OR UPDATE ON user_cards
    FOR EACH ROW
    EXECUTE FUNCTION enforce_single_primary_card();

-- Available credit calculation trigger
CREATE TRIGGER trigger_calculate_available_credit
    BEFORE INSERT OR UPDATE ON user_cards
    FOR EACH ROW
    EXECUTE FUNCTION calculate_available_credit();

-- Transaction auto-categorization trigger
CREATE TRIGGER trigger_auto_categorize_transaction
    BEFORE INSERT ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION auto_categorize_transaction();

-- ============================================================================
-- 5. BALANCE AND SUMMARY TRIGGERS
-- ============================================================================

-- Card balance update trigger
CREATE TRIGGER trigger_update_card_balance
    AFTER INSERT OR DELETE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_card_balance();

-- Spending summary update trigger
CREATE TRIGGER trigger_update_spending_summary
    AFTER INSERT ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_spending_summary();

-- ============================================================================
-- 6. ACTIVITY TRACKING TRIGGERS
-- ============================================================================

-- User last active update for transactions
CREATE TRIGGER trigger_update_user_active_transactions
    AFTER INSERT ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_last_active();

-- User last active update for chat messages
CREATE TRIGGER trigger_update_user_active_chat
    AFTER INSERT ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_user_last_active();

-- Conversation stats update trigger
CREATE TRIGGER trigger_update_conversation_stats
    AFTER INSERT OR DELETE ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_stats();

-- ============================================================================
-- 7. ALERT AND NOTIFICATION TRIGGERS
-- ============================================================================

-- Alert condition checking trigger
CREATE TRIGGER trigger_check_alert_conditions
    AFTER INSERT ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION check_alert_conditions();

-- ============================================================================
-- 8. AUDIT TRIGGERS (Optional - for compliance)
-- ============================================================================

-- Create audit log table for sensitive operations
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    user_id UUID,
    old_values JSONB,
    new_values JSONB,
    changed_by UUID,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit function for sensitive tables
CREATE OR REPLACE FUNCTION audit_sensitive_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Only audit specific sensitive operations
    IF TG_TABLE_NAME IN ('user_cards', 'transactions') THEN
        INSERT INTO audit_log (
            table_name, operation, user_id, old_values, new_values, changed_by
        ) VALUES (
            TG_TABLE_NAME,
            TG_OP,
            COALESCE(NEW.user_id, OLD.user_id),
            CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
            CASE WHEN TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN row_to_json(NEW) ELSE NULL END,
            COALESCE(NEW.user_id, OLD.user_id)
        );
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Audit triggers for sensitive tables
CREATE TRIGGER trigger_audit_user_cards
    AFTER INSERT OR UPDATE OR DELETE ON user_cards
    FOR EACH ROW
    EXECUTE FUNCTION audit_sensitive_changes();

CREATE TRIGGER trigger_audit_transactions
    AFTER INSERT OR UPDATE OR DELETE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION audit_sensitive_changes();

-- ============================================================================
-- Success Message and Summary
-- ============================================================================

DO $$
DECLARE
    trigger_count INTEGER;
    function_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO trigger_count 
    FROM information_schema.triggers 
    WHERE trigger_schema = 'public';
    
    SELECT COUNT(*) INTO function_count 
    FROM information_schema.routines 
    WHERE routine_schema = 'public' 
    AND routine_type = 'FUNCTION'
    AND routine_name LIKE '%trigger%' OR routine_name LIKE '%update_%' OR routine_name LIKE '%validate_%';
    
    RAISE NOTICE 'Database triggers created successfully. Total triggers: %', trigger_count;
    RAISE NOTICE 'Supporting functions created: %', function_count;
    RAISE NOTICE 'Automated features: Timestamps, Validation, Balance Updates, Alerts, Audit Trails';
    RAISE NOTICE 'Next steps: Run 05_functions.sql for additional stored procedures';
END $$; 