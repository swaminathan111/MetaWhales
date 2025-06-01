-- ============================================================================
-- CardSense AI Database - Cleanup Script
-- ============================================================================
-- 
-- Purpose: Clean up old data and perform database maintenance
-- Version: 1.0.0
-- Environment: All (with safety checks)
-- 
-- This script performs various cleanup operations:
-- - Remove old notifications
-- - Clean up orphaned files
-- - Archive old engagement data
-- - Vacuum and analyze tables
-- 
-- Usage:
-- psql -h your-supabase-host -U postgres -d postgres -f cleanup.sql
-- 
-- ============================================================================

\echo '============================================================================'
\echo 'CardSense AI Database - Cleanup Starting'
\echo '============================================================================'

-- Set error handling
\set ON_ERROR_STOP on

-- Safety check
DO $$
BEGIN
    RAISE NOTICE 'Starting database cleanup for: %', current_database();
    RAISE NOTICE 'Current time: %', NOW();
END $$;

-- ============================================================================
-- CLEANUP OPERATIONS
-- ============================================================================

\echo ''
\echo 'Step 1: Cleaning up old notifications...'

-- Clean up old notifications (older than 90 days)
DO $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM notifications 
    WHERE created_at < (CURRENT_DATE - INTERVAL '90 days');
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % old notifications', deleted_count;
END $$;

\echo ''
\echo 'Step 2: Cleaning up old user engagement data...'

-- Clean up old engagement data (older than 1 year)
DO $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_engagement 
    WHERE created_at < (CURRENT_DATE - INTERVAL '1 year');
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % old engagement records', deleted_count;
END $$;

\echo ''
\echo 'Step 3: Cleaning up orphaned storage files...'

-- Clean up orphaned files using the built-in function
SELECT cleanup_orphaned_files();

\echo ''
\echo 'Step 4: Cleaning up old chat conversations...'

-- Clean up very old chat conversations (older than 2 years)
-- This is optional and should be adjusted based on your retention policy
DO $$
DECLARE
    deleted_conversations INTEGER;
    deleted_messages INTEGER;
BEGIN
    -- First delete messages from old conversations
    DELETE FROM chat_messages 
    WHERE conversation_id IN (
        SELECT id FROM chat_conversations 
        WHERE created_at < (CURRENT_DATE - INTERVAL '2 years')
    );
    
    GET DIAGNOSTICS deleted_messages = ROW_COUNT;
    
    -- Then delete the conversations
    DELETE FROM chat_conversations 
    WHERE created_at < (CURRENT_DATE - INTERVAL '2 years');
    
    GET DIAGNOSTICS deleted_conversations = ROW_COUNT;
    
    RAISE NOTICE 'Deleted % old conversations and % messages', deleted_conversations, deleted_messages;
END $$;

\echo ''
\echo 'Step 5: Updating spending summaries...'

-- Recalculate spending summaries for active users (last 30 days)
DO $$
DECLARE
    user_record RECORD;
    updated_count INTEGER := 0;
BEGIN
    FOR user_record IN 
        SELECT DISTINCT user_id 
        FROM transactions 
        WHERE created_at >= (CURRENT_DATE - INTERVAL '30 days')
    LOOP
        -- Update current month
        PERFORM calculate_monthly_summary(user_record.user_id, CURRENT_DATE);
        
        -- Update previous month if we're early in the current month
        IF EXTRACT(DAY FROM CURRENT_DATE) <= 5 THEN
            PERFORM calculate_monthly_summary(user_record.user_id, CURRENT_DATE - INTERVAL '1 month');
        END IF;
        
        updated_count := updated_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Updated spending summaries for % active users', updated_count;
END $$;

-- ============================================================================
-- DATABASE MAINTENANCE
-- ============================================================================

\echo ''
\echo 'Step 6: Performing database maintenance...'

-- Vacuum and analyze tables for better performance
VACUUM ANALYZE user_profiles;
VACUUM ANALYZE transactions;
VACUUM ANALYZE spending_summaries;
VACUUM ANALYZE chat_conversations;
VACUUM ANALYZE chat_messages;
VACUUM ANALYZE notifications;
VACUUM ANALYZE user_engagement;

\echo 'Database tables vacuumed and analyzed'

-- ============================================================================
-- STATISTICS AND REPORTING
-- ============================================================================

\echo ''
\echo 'Step 7: Generating cleanup report...'

DO $$
DECLARE
    total_users INTEGER;
    active_users INTEGER;
    total_transactions INTEGER;
    recent_transactions INTEGER;
    total_conversations INTEGER;
    total_notifications INTEGER;
    storage_usage RECORD;
BEGIN
    -- Get user statistics
    SELECT COUNT(*) INTO total_users FROM user_profiles;
    SELECT COUNT(DISTINCT user_id) INTO active_users 
    FROM transactions 
    WHERE created_at >= (CURRENT_DATE - INTERVAL '30 days');
    
    -- Get transaction statistics
    SELECT COUNT(*) INTO total_transactions FROM transactions;
    SELECT COUNT(*) INTO recent_transactions 
    FROM transactions 
    WHERE created_at >= (CURRENT_DATE - INTERVAL '30 days');
    
    -- Get conversation statistics
    SELECT COUNT(*) INTO total_conversations FROM chat_conversations;
    
    -- Get notification statistics
    SELECT COUNT(*) INTO total_notifications FROM notifications;
    
    RAISE NOTICE '';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'CLEANUP REPORT';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Database Statistics:';
    RAISE NOTICE '- Total Users: %', total_users;
    RAISE NOTICE '- Active Users (30 days): %', active_users;
    RAISE NOTICE '- Total Transactions: %', total_transactions;
    RAISE NOTICE '- Recent Transactions (30 days): %', recent_transactions;
    RAISE NOTICE '- Total Conversations: %', total_conversations;
    RAISE NOTICE '- Current Notifications: %', total_notifications;
    RAISE NOTICE '';
    
    -- Storage statistics
    RAISE NOTICE 'Storage Statistics:';
    FOR storage_usage IN SELECT * FROM get_storage_stats() LOOP
        RAISE NOTICE '- %: % files, % bytes total', 
            storage_usage.bucket_name, 
            storage_usage.file_count, 
            storage_usage.total_size;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Cleanup completed successfully at %', NOW();
    RAISE NOTICE '============================================================================';
END $$;

-- ============================================================================
-- OPTIONAL: DEVELOPMENT DATA RESET
-- ============================================================================

-- Uncomment the following section ONLY for development environments
-- to completely reset test data

/*
\echo ''
\echo 'WARNING: Development data reset section'
\echo 'This section is commented out for safety'

-- DANGER: This will delete ALL user data
-- Only uncomment in development environments

-- DO $$
-- BEGIN
--     IF current_database() LIKE '%dev%' OR current_database() LIKE '%test%' THEN
--         RAISE NOTICE 'Resetting development data...';
--         
--         -- Delete all user data (cascades to related tables)
--         DELETE FROM user_profiles;
--         
--         -- Reset sequences if needed
--         -- ALTER SEQUENCE some_sequence RESTART WITH 1;
--         
--         RAISE NOTICE 'Development data reset complete';
--     ELSE
--         RAISE EXCEPTION 'Development reset attempted on non-development database: %', current_database();
--     END IF;
-- END $$;
*/

-- ============================================================================
-- PERFORMANCE RECOMMENDATIONS
-- ============================================================================

\echo ''
\echo 'Performance Recommendations:'

-- Check for tables that might need index optimization
DO $$
DECLARE
    table_stats RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Table Size Analysis:';
    
    FOR table_stats IN
        SELECT 
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
            pg_total_relation_size(schemaname||'.'||tablename) as size_bytes
        FROM pg_tables 
        WHERE schemaname = 'public'
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
        LIMIT 5
    LOOP
        RAISE NOTICE '- %: %', table_stats.tablename, table_stats.size;
        
        -- Suggest reindexing for large tables
        IF table_stats.size_bytes > 100000000 THEN -- 100MB
            RAISE NOTICE '  → Consider reindexing this large table';
        END IF;
    END LOOP;
END $$;

\echo ''
\echo '============================================================================'
\echo 'CardSense AI Database - Cleanup Complete!'
\echo '============================================================================'
\echo ''
\echo 'Cleanup operations completed successfully.'
\echo 'Check the output above for statistics and recommendations.'
\echo ''
\echo 'Recommended cleanup schedule:'
\echo '- Run this script weekly for active databases'
\echo '- Run monthly for low-activity databases'
\echo '- Monitor storage usage and adjust retention policies as needed'
\echo ''
\echo 'Next maintenance tasks:'
\echo '1. Review storage usage and clean up large files if needed'
\echo '2. Monitor query performance and add indexes if necessary'
\echo '3. Update spending category keywords based on user feedback'
\echo '4. Review and update RLS policies if application changes'
\echo '' 