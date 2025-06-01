-- ============================================================================
-- CardSense AI Database - Complete Development Setup
-- ============================================================================
-- 
-- Purpose: Complete database setup for development environment
-- Version: 1.0.0
-- Environment: Development/Testing ONLY
-- 
-- This script runs all schema files and loads development seed data
-- 
-- Usage:
-- psql -h your-supabase-host -U postgres -d postgres -f setup_development.sql
-- 
-- ============================================================================

\echo '============================================================================'
\echo 'CardSense AI Database - Development Setup Starting'
\echo '============================================================================'

-- Set error handling
\set ON_ERROR_STOP on

-- ============================================================================
-- STEP 1: EXTENSIONS
-- ============================================================================

\echo ''
\echo 'Step 1: Installing PostgreSQL extensions...'

\i ../schema/01_extensions.sql

-- ============================================================================
-- STEP 2: CORE TABLES
-- ============================================================================

\echo ''
\echo 'Step 2: Creating core database tables...'

\i ../schema/02_core_tables.sql

-- ============================================================================
-- STEP 3: INDEXES
-- ============================================================================

\echo ''
\echo 'Step 3: Creating performance indexes...'

\i ../schema/03_indexes.sql

-- ============================================================================
-- STEP 4: TRIGGERS
-- ============================================================================

\echo ''
\echo 'Step 4: Setting up database triggers...'

\i ../schema/04_triggers.sql

-- ============================================================================
-- STEP 5: FUNCTIONS
-- ============================================================================

\echo ''
\echo 'Step 5: Creating stored procedures and functions...'

\i ../schema/05_functions.sql

-- ============================================================================
-- STEP 6: ROW LEVEL SECURITY
-- ============================================================================

\echo ''
\echo 'Step 6: Configuring Row Level Security policies...'

\i ../schema/06_rls_policies.sql

-- ============================================================================
-- STEP 7: STORAGE SETUP
-- ============================================================================

\echo ''
\echo 'Step 7: Setting up Supabase storage buckets and policies...'

\i ../schema/07_storage_setup.sql

-- ============================================================================
-- STEP 8: DEVELOPMENT SEED DATA
-- ============================================================================

\echo ''
\echo 'Step 8: Loading development seed data...'

\i ../seeds/development_seed.sql

-- ============================================================================
-- VERIFICATION
-- ============================================================================

\echo ''
\echo 'Verifying database setup...'

-- Check table counts
DO $$
DECLARE
    table_count INTEGER;
    function_count INTEGER;
    policy_count INTEGER;
    user_count INTEGER;
    transaction_count INTEGER;
BEGIN
    -- Count tables
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE';
    
    -- Count functions
    SELECT COUNT(*) INTO function_count 
    FROM information_schema.routines 
    WHERE routine_schema = 'public' 
    AND routine_type = 'FUNCTION';
    
    -- Count RLS policies
    SELECT COUNT(*) INTO policy_count 
    FROM pg_policies 
    WHERE schemaname = 'public';
    
    -- Count test users
    SELECT COUNT(*) INTO user_count FROM user_profiles;
    
    -- Count test transactions
    SELECT COUNT(*) INTO transaction_count FROM transactions;
    
    RAISE NOTICE '';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'DEVELOPMENT SETUP VERIFICATION';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Database Tables: %', table_count;
    RAISE NOTICE 'Functions Created: %', function_count;
    RAISE NOTICE 'RLS Policies: %', policy_count;
    RAISE NOTICE 'Test Users: %', user_count;
    RAISE NOTICE 'Test Transactions: %', transaction_count;
    RAISE NOTICE '';
    
    IF table_count < 10 THEN
        RAISE WARNING 'Expected at least 10 tables, found %', table_count;
    END IF;
    
    IF function_count < 15 THEN
        RAISE WARNING 'Expected at least 15 functions, found %', function_count;
    END IF;
    
    IF policy_count < 20 THEN
        RAISE WARNING 'Expected at least 20 RLS policies, found %', policy_count;
    END IF;
    
    IF user_count < 3 THEN
        RAISE WARNING 'Expected at least 3 test users, found %', user_count;
    END IF;
    
    IF transaction_count < 5 THEN
        RAISE WARNING 'Expected at least 5 test transactions, found %', transaction_count;
    END IF;
    
    RAISE NOTICE 'Development database setup completed successfully!';
    RAISE NOTICE '';
    RAISE NOTICE 'Test User Accounts:';
    RAISE NOTICE '- john.doe@example.com (User ID: 550e8400-e29b-41d4-a716-446655440001)';
    RAISE NOTICE '- jane.smith@example.com (User ID: 550e8400-e29b-41d4-a716-446655440002)';
    RAISE NOTICE '- mike.johnson@example.com (User ID: 550e8400-e29b-41d4-a716-446655440003)';
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '1. Configure your Supabase project settings';
    RAISE NOTICE '2. Update storage bucket URLs in 07_storage_setup.sql';
    RAISE NOTICE '3. Test the application with the provided test accounts';
    RAISE NOTICE '4. Review RLS policies in Supabase dashboard';
    RAISE NOTICE '';
    RAISE NOTICE '============================================================================';
END $$;

-- Test key functions
\echo 'Testing key database functions...'

-- Test auto-categorization
SELECT 'Testing auto-categorization...' as test;
SELECT auto_categorize_transaction('Grocery shopping at Whole Foods', 'Whole Foods Market') as grocery_category_test;

-- Test spending trends (should return empty for new setup)
SELECT 'Testing spending trends function...' as test;
SELECT COUNT(*) as trend_records FROM get_spending_trends('550e8400-e29b-41d4-a716-446655440001'::UUID);

-- Test RLS policies
SELECT 'Testing RLS policies...' as test;
SELECT * FROM test_rls_policies() ORDER BY table_name;

\echo ''
\echo '============================================================================'
\echo 'CardSense AI Database - Development Setup Complete!'
\echo '============================================================================'
\echo ''
\echo 'Your development database is ready to use.'
\echo 'Check the output above for any warnings or errors.'
\echo ''
\echo 'Important Security Notes:'
\echo '- This setup includes TEST DATA and should NEVER be used in production'
\echo '- Test user accounts have predictable UUIDs for development convenience'
\echo '- All RLS policies are active - test with proper authentication'
\echo ''
\echo 'Happy coding! 🚀'
\echo '' 