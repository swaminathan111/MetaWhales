-- ============================================================================
-- CardSense AI Database - Development Seed Data
-- ============================================================================
-- 
-- Purpose: Populate database with realistic test data for development
-- Version: 1.0.0
-- Environment: Development/Testing ONLY
-- 
-- WARNING: This file contains test data and should NEVER be run in production
-- 
-- ============================================================================

-- ============================================================================
-- CARD ISSUERS SEED DATA
-- ============================================================================

INSERT INTO card_issuers (id, name, logo_url, website_url, customer_service_phone, is_active) VALUES
(uuid_generate_v4(), 'Chase', 'https://logos.chase.com/chase-logo.png', 'https://www.chase.com', '1-800-432-3117', true),
(uuid_generate_v4(), 'American Express', 'https://logos.americanexpress.com/amex-logo.png', 'https://www.americanexpress.com', '1-800-528-4800', true),
(uuid_generate_v4(), 'Capital One', 'https://logos.capitalone.com/capital-one-logo.png', 'https://www.capitalone.com', '1-800-227-4825', true),
(uuid_generate_v4(), 'Citi', 'https://logos.citi.com/citi-logo.png', 'https://www.citi.com', '1-800-950-5114', true),
(uuid_generate_v4(), 'Bank of America', 'https://logos.bankofamerica.com/boa-logo.png', 'https://www.bankofamerica.com', '1-800-732-9194', true),
(uuid_generate_v4(), 'Wells Fargo', 'https://logos.wellsfargo.com/wf-logo.png', 'https://www.wellsfargo.com', '1-800-869-3557', true),
(uuid_generate_v4(), 'Discover', 'https://logos.discover.com/discover-logo.png', 'https://www.discover.com', '1-800-347-2683', true),
(uuid_generate_v4(), 'US Bank', 'https://logos.usbank.com/usbank-logo.png', 'https://www.usbank.com', '1-800-872-2657', true);

-- ============================================================================
-- CARD CATEGORIES SEED DATA
-- ============================================================================

INSERT INTO card_categories (id, name, description, icon_name, color_code, is_active) VALUES
(uuid_generate_v4(), 'Travel Rewards', 'Cards that earn points or miles for travel purchases', 'airplane', '#3B82F6', true),
(uuid_generate_v4(), 'Cash Back', 'Cards that offer cash back on purchases', 'dollar-sign', '#10B981', true),
(uuid_generate_v4(), 'Business', 'Credit cards designed for business expenses', 'briefcase', '#8B5CF6', true),
(uuid_generate_v4(), 'Student', 'Credit cards designed for students with limited credit history', 'graduation-cap', '#F59E0B', true),
(uuid_generate_v4(), 'Secured', 'Cards that require a security deposit', 'shield', '#EF4444', true),
(uuid_generate_v4(), 'Premium', 'High-end cards with exclusive benefits and higher fees', 'crown', '#F97316', true),
(uuid_generate_v4(), 'Balance Transfer', 'Cards with promotional rates for transferring balances', 'refresh', '#06B6D4', true),
(uuid_generate_v4(), 'No Annual Fee', 'Cards with no annual fee', 'check-circle', '#84CC16', true);

-- ============================================================================
-- SPENDING CATEGORIES SEED DATA
-- ============================================================================

INSERT INTO spending_categories (id, name, description, icon_name, color_code, is_active, is_system_category) VALUES
(uuid_generate_v4(), 'Groceries', 'Food and household items', 'shopping-cart', '#10B981', true, true),
(uuid_generate_v4(), 'Gas & Fuel', 'Gasoline and vehicle fuel', 'gas-pump', '#EF4444', true, true),
(uuid_generate_v4(), 'Restaurants', 'Dining out and food delivery', 'utensils', '#F59E0B', true, true),
(uuid_generate_v4(), 'Entertainment', 'Movies, games, and leisure activities', 'film', '#8B5CF6', true, true),
(uuid_generate_v4(), 'Travel', 'Transportation and accommodation', 'airplane', '#3B82F6', true, true),
(uuid_generate_v4(), 'Shopping', 'General retail purchases', 'shopping-bag', '#F97316', true, true),
(uuid_generate_v4(), 'Bills & Utilities', 'Monthly bills and utilities', 'receipt', '#6B7280', true, true),
(uuid_generate_v4(), 'Healthcare', 'Medical expenses and insurance', 'heart', '#EC4899', true, true),
(uuid_generate_v4(), 'Education', 'School and learning expenses', 'book', '#06B6D4', true, true),
(uuid_generate_v4(), 'Other', 'Miscellaneous expenses', 'more-horizontal', '#9CA3AF', true, true);

-- ============================================================================
-- DEVELOPMENT SEED VERIFICATION
-- ============================================================================

DO $$
DECLARE
    issuer_count INTEGER;
    category_count INTEGER;
    spending_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO issuer_count FROM card_issuers;
    SELECT COUNT(*) INTO category_count FROM card_categories;
    SELECT COUNT(*) INTO spending_count FROM spending_categories;
    
    RAISE NOTICE 'Development reference data loaded successfully:';
    RAISE NOTICE '- Card Issuers: %', issuer_count;
    RAISE NOTICE '- Card Categories: %', category_count;
    RAISE NOTICE '- Spending Categories: %', spending_count;
    RAISE NOTICE '';
    RAISE NOTICE 'To test with user data:';
    RAISE NOTICE '1. Create users through Supabase Auth (signup/login)';
    RAISE NOTICE '2. User profiles will be created automatically via triggers';
    RAISE NOTICE '3. Add cards and transactions through the app UI';
    RAISE NOTICE '';
    RAISE NOTICE 'Development seed completed successfully!';
END $$;

-- ============================================================================
-- DEVELOPMENT NOTES
-- ============================================================================

-- This seed file creates:
-- - 8 major credit card issuers
-- - 8 card categories (travel, cash back, business, etc.)
-- - 10 spending categories for transaction categorization
--
-- USER DATA TESTING:
-- For testing with user data, you need to:
-- 1. Sign up users through Supabase Auth (app UI or Auth API)
-- 2. User profiles will be automatically created via database triggers
-- 3. Add credit cards through the app interface
-- 4. Create transactions through the app or API
--
-- This approach ensures proper foreign key relationships and
-- follows the same data flow as the production application.
--
-- To reset reference data:
-- 1. Delete: TRUNCATE TABLE card_issuers, card_categories, spending_categories CASCADE;
-- 2. Re-run this seed file

-- Remember: This is for DEVELOPMENT ONLY!
-- Never run this in production environment.

-- ============================================================================
-- END OF DEVELOPMENT SEED
-- ============================================================================ 