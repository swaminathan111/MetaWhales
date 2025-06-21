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
(uuid_generate_v4(), 'HDFC Bank', 'https://logos.hdfcbank.com/hdfc-logo.png', 'https://www.hdfcbank.com', '1800-266-4332', true),
(uuid_generate_v4(), 'ICICI Bank', 'https://logos.icicibank.com/icici-logo.png', 'https://www.icicibank.com', '1800-102-4242', true),
(uuid_generate_v4(), 'SBI Cards', 'https://logos.sbicard.com/sbi-logo.png', 'https://www.sbicard.com', '1800-180-1290', true),
(uuid_generate_v4(), 'Axis Bank', 'https://logos.axisbank.com/axis-logo.png', 'https://www.axisbank.com', '1800-419-5959', true),
(uuid_generate_v4(), 'Kotak Mahindra Bank', 'https://logos.kotak.com/kotak-logo.png', 'https://www.kotak.com', '1800-274-0110', true),
(uuid_generate_v4(), 'American Express India', 'https://logos.americanexpress.com/amex-india-logo.png', 'https://www.americanexpress.com/in', '1800-110-024', true),
(uuid_generate_v4(), 'IndusInd Bank', 'https://logos.indusind.com/indusind-logo.png', 'https://www.indusind.com', '1800-267-7777', true),
(uuid_generate_v4(), 'Yes Bank', 'https://logos.yesbank.com/yes-logo.png', 'https://www.yesbank.in', '1800-220-0200', true);

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