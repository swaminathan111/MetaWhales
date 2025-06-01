-- ============================================================================
-- CardSense AI Database Schema - Performance Indexes
-- ============================================================================
-- 
-- Purpose: Create strategic indexes for optimal query performance
-- Version: 1.0.0
-- Compatible with: PostgreSQL 13+, Supabase
-- 
-- Index Categories:
-- - Primary lookup indexes (user_id, foreign keys)
-- - Time-based indexes (created_at, transaction_date)
-- - Search and filter indexes (status, type fields)
-- - Composite indexes for common query patterns
-- - Unique indexes for data integrity
-- 
-- ============================================================================

-- ============================================================================
-- 1. USER PROFILES INDEXES
-- ============================================================================

-- Email lookup for authentication
CREATE INDEX IF NOT EXISTS idx_user_profiles_email 
ON user_profiles(email);

-- Active user lookup
CREATE INDEX IF NOT EXISTS idx_user_profiles_last_active 
ON user_profiles(last_active_at DESC) 
WHERE onboarding_completed = TRUE;

-- Onboarding status for analytics
CREATE INDEX IF NOT EXISTS idx_user_profiles_onboarding 
ON user_profiles(onboarding_completed, created_at);

-- ============================================================================
-- 2. CARD MANAGEMENT INDEXES
-- ============================================================================

-- Card issuers - active lookup
CREATE INDEX IF NOT EXISTS idx_card_issuers_active 
ON card_issuers(name) 
WHERE is_active = TRUE;

-- Card categories - active lookup
CREATE INDEX IF NOT EXISTS idx_card_categories_active 
ON card_categories(name) 
WHERE is_active = TRUE;

-- User cards - primary user lookup
CREATE INDEX IF NOT EXISTS idx_user_cards_user_id 
ON user_cards(user_id, status, is_primary);

-- User cards - issuer and category lookups
CREATE INDEX IF NOT EXISTS idx_user_cards_issuer 
ON user_cards(issuer_id);

CREATE INDEX IF NOT EXISTS idx_user_cards_category 
ON user_cards(category_id);

-- User cards - due date alerts
CREATE INDEX IF NOT EXISTS idx_user_cards_due_date 
ON user_cards(due_date, user_id) 
WHERE status = 'active' AND due_date IS NOT NULL;

-- User cards - statement date processing
CREATE INDEX IF NOT EXISTS idx_user_cards_statement_date 
ON user_cards(statement_date, user_id) 
WHERE status = 'active' AND statement_date IS NOT NULL;

-- ============================================================================
-- 3. SPENDING CATEGORIES INDEXES
-- ============================================================================

-- Active categories lookup
CREATE INDEX IF NOT EXISTS idx_spending_categories_active 
ON spending_categories(name) 
WHERE is_active = TRUE;

-- Hierarchical category structure
CREATE INDEX IF NOT EXISTS idx_spending_categories_parent 
ON spending_categories(parent_category_id, name) 
WHERE is_active = TRUE;

-- System vs custom categories
CREATE INDEX IF NOT EXISTS idx_spending_categories_system 
ON spending_categories(is_system_category, name) 
WHERE is_active = TRUE;

-- ============================================================================
-- 4. TRANSACTIONS INDEXES
-- ============================================================================

-- Primary user transaction lookup
CREATE INDEX IF NOT EXISTS idx_transactions_user_date 
ON transactions(user_id, transaction_date DESC);

-- Card-specific transaction lookup
CREATE INDEX IF NOT EXISTS idx_transactions_card_date 
ON transactions(card_id, transaction_date DESC);

-- Category-based analysis
CREATE INDEX IF NOT EXISTS idx_transactions_category_date 
ON transactions(category_id, transaction_date DESC);

-- Monthly aggregation support (date-based for grouping)
CREATE INDEX IF NOT EXISTS idx_transactions_monthly 
ON transactions(user_id, transaction_date);

-- Amount-based queries (large transactions)
CREATE INDEX IF NOT EXISTS idx_transactions_amount 
ON transactions(user_id, amount DESC, transaction_date DESC);

-- Merchant analysis
CREATE INDEX IF NOT EXISTS idx_transactions_merchant 
ON transactions(merchant_name, user_id, transaction_date DESC) 
WHERE merchant_name IS NOT NULL;

-- Status-based queries
CREATE INDEX IF NOT EXISTS idx_transactions_status 
ON transactions(status, transaction_date DESC);

-- Recurring transaction analysis
CREATE INDEX IF NOT EXISTS idx_transactions_recurring 
ON transactions(user_id, is_recurring, transaction_date DESC) 
WHERE is_recurring = TRUE;

-- Rewards tracking
CREATE INDEX IF NOT EXISTS idx_transactions_rewards 
ON transactions(user_id, reward_points_earned DESC, transaction_date DESC) 
WHERE reward_points_earned > 0;

-- ============================================================================
-- 5. CHAT SYSTEM INDEXES
-- ============================================================================

-- User conversations lookup
CREATE INDEX IF NOT EXISTS idx_chat_conversations_user 
ON chat_conversations(user_id, last_message_at DESC) 
WHERE status = 'active';

-- Conversation status management
CREATE INDEX IF NOT EXISTS idx_chat_conversations_status 
ON chat_conversations(status, last_message_at DESC);

-- Chat messages - conversation lookup
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation 
ON chat_messages(conversation_id, created_at ASC);

-- Chat messages - user lookup
CREATE INDEX IF NOT EXISTS idx_chat_messages_user 
ON chat_messages(user_id, created_at DESC);

-- AI model performance analysis
CREATE INDEX IF NOT EXISTS idx_chat_messages_ai_model 
ON chat_messages(ai_model_used, ai_response_time_ms) 
WHERE sender_type = 'assistant';

-- Voice message lookup
CREATE INDEX IF NOT EXISTS idx_chat_messages_voice 
ON chat_messages(user_id, created_at DESC) 
WHERE message_type = 'voice';

-- ============================================================================
-- 6. NOTIFICATIONS INDEXES
-- ============================================================================

-- User notifications - unread first
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread 
ON notifications(user_id, is_read, created_at DESC);

-- Notification type analysis
CREATE INDEX IF NOT EXISTS idx_notifications_type 
ON notifications(notification_type, created_at DESC);

-- Priority-based delivery
CREATE INDEX IF NOT EXISTS idx_notifications_priority 
ON notifications(priority, created_at DESC) 
WHERE is_read = FALSE;

-- Expired notifications cleanup
CREATE INDEX IF NOT EXISTS idx_notifications_expired 
ON notifications(expires_at) 
WHERE expires_at IS NOT NULL;

-- Alert rules - user lookup
CREATE INDEX IF NOT EXISTS idx_alert_rules_user 
ON alert_rules(user_id, is_active);

-- Alert rules - card-specific
CREATE INDEX IF NOT EXISTS idx_alert_rules_card 
ON alert_rules(card_id, is_active) 
WHERE card_id IS NOT NULL;

-- ============================================================================
-- 7. ANALYTICS INDEXES
-- ============================================================================

-- Monthly summaries - user timeline
CREATE INDEX IF NOT EXISTS idx_spending_summaries_user_timeline 
ON spending_summaries(user_id, year DESC, month DESC);

-- Period-based summaries
CREATE INDEX IF NOT EXISTS idx_spending_summaries_period 
ON spending_summaries(year, month, created_at DESC);

-- User engagement - session lookup
CREATE INDEX IF NOT EXISTS idx_user_engagement_session 
ON user_engagement(user_id, created_at DESC);

-- User engagement - event tracking
CREATE INDEX IF NOT EXISTS idx_user_engagement_events 
ON user_engagement(event_type, created_at DESC);

-- User engagement - feature usage
CREATE INDEX IF NOT EXISTS idx_user_engagement_features 
ON user_engagement(feature_used, created_at DESC) 
WHERE feature_used IS NOT NULL;

-- User engagement - daily active users
CREATE INDEX IF NOT EXISTS idx_user_engagement_daily 
ON user_engagement(user_id, created_at);

-- ============================================================================
-- 8. COMPOSITE BUSINESS INDEXES
-- ============================================================================

-- User dashboard activity
CREATE INDEX IF NOT EXISTS idx_user_dashboard_activity 
ON transactions(user_id, transaction_date DESC, amount DESC);

-- Card utilization tracking
CREATE INDEX IF NOT EXISTS idx_card_utilization 
ON transactions(card_id, transaction_date DESC) 
WHERE status = 'completed';

-- Monthly category spending analysis
CREATE INDEX IF NOT EXISTS idx_monthly_category_spending 
ON transactions(category_id, transaction_date, amount DESC);

-- Reward optimization
CREATE INDEX IF NOT EXISTS idx_reward_optimization 
ON transactions(user_id, category_id, reward_points_earned DESC) 
WHERE reward_points_earned > 0;

-- ============================================================================
-- 9. SEARCH INDEXES
-- ============================================================================

-- Transaction description search
CREATE INDEX IF NOT EXISTS idx_transactions_description_search 
ON transactions USING gin(to_tsvector('english', description)) 
WHERE description IS NOT NULL;

-- Merchant name search
CREATE INDEX IF NOT EXISTS idx_transactions_merchant_search 
ON transactions USING gin(to_tsvector('english', merchant_name)) 
WHERE merchant_name IS NOT NULL;

-- Chat message content search
CREATE INDEX IF NOT EXISTS idx_chat_messages_search 
ON chat_messages USING gin(to_tsvector('english', message)) 
WHERE message IS NOT NULL AND sender_type = 'user';

-- ============================================================================
-- 10. SPECIALIZED INDEXES
-- ============================================================================

-- Active cards only
CREATE INDEX IF NOT EXISTS idx_user_cards_active_only 
ON user_cards(user_id, created_at DESC) 
WHERE status = 'active';

-- Pending transactions only
CREATE INDEX IF NOT EXISTS idx_transactions_pending_only 
ON transactions(user_id, created_at DESC) 
WHERE status = 'pending';

-- High-value transactions
CREATE INDEX IF NOT EXISTS idx_transactions_high_value 
ON transactions(user_id, amount DESC, transaction_date DESC) 
WHERE amount > 1000;

-- Recent chat activity
CREATE INDEX IF NOT EXISTS idx_chat_recent_activity 
ON chat_messages(user_id, created_at DESC);

-- ============================================================================
-- INDEX MAINTENANCE FUNCTIONS
-- ============================================================================

-- Function to analyze index usage and performance
CREATE OR REPLACE FUNCTION analyze_index_usage()
RETURNS TABLE(
    schemaname TEXT,
    tablename TEXT,
    indexname TEXT,
    num_rows BIGINT,
    table_size TEXT,
    index_size TEXT,
    unique_index BOOLEAN,
    number_of_scans BIGINT,
    tuples_read BIGINT,
    tuples_fetched BIGINT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::TEXT,
        tablename::TEXT,
        indexname::TEXT,
        num_rows::BIGINT,
        pg_size_pretty(table_bytes::BIGINT)::TEXT AS table_size,
        pg_size_pretty(index_bytes::BIGINT)::TEXT AS index_size,
        unique_index::BOOLEAN,
        number_of_scans::BIGINT,
        tuples_read::BIGINT,
        tuples_fetched::BIGINT
    FROM (
        SELECT 
            schemaname,
            tablename,
            indexname,
            reltuples::BIGINT AS num_rows,
            pg_relation_size(i.indexrelid) AS index_bytes,
            pg_relation_size(i.indrelid) AS table_bytes,
            indisunique AS unique_index,
            idx_scan AS number_of_scans,
            idx_tup_read AS tuples_read,
            idx_tup_fetch AS tuples_fetched
        FROM pg_stat_user_indexes ui
        JOIN pg_index i ON ui.indexrelid = i.indexrelid
        WHERE schemaname = 'public'
    ) AS index_stats
    ORDER BY index_bytes DESC;
END;
$$;

-- Function to find unused indexes
CREATE OR REPLACE FUNCTION find_unused_indexes()
RETURNS TABLE(
    schemaname TEXT,
    tablename TEXT,
    indexname TEXT,
    index_size TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::TEXT,
        tablename::TEXT,
        indexname::TEXT,
        pg_size_pretty(pg_relation_size(indexrelid))::TEXT AS index_size
    FROM pg_stat_user_indexes 
    WHERE idx_scan = 0
    AND schemaname = 'public'
    AND indexname NOT LIKE '%_pkey'  -- Exclude primary keys
    ORDER BY pg_relation_size(indexrelid) DESC;
END;
$$;

-- Grant appropriate permissions
GRANT EXECUTE ON FUNCTION analyze_index_usage() TO authenticated;
GRANT EXECUTE ON FUNCTION find_unused_indexes() TO authenticated;

-- ============================================================================
-- INDEX VALIDATION
-- ============================================================================

-- Check that all expected indexes were created
DO $$
DECLARE
    missing_indexes TEXT[] := ARRAY[]::TEXT[];
    expected_count INTEGER := 45;  -- Update this number as indexes are added
    actual_count INTEGER;
BEGIN
    -- Count actual indexes created by this script
    SELECT COUNT(*) INTO actual_count
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND indexname LIKE 'idx_%';
    
    -- Log results
    RAISE NOTICE 'Index creation summary:';
    RAISE NOTICE '- Expected indexes: %', expected_count;
    RAISE NOTICE '- Created indexes: %', actual_count;
    
    IF actual_count < expected_count THEN
        RAISE WARNING 'Some indexes may not have been created successfully';
    ELSE
        RAISE NOTICE '✅ All indexes created successfully';
    END IF;
END;
$$; 