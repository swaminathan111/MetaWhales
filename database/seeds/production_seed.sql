-- ============================================================================
-- CardSense AI Database - Production Seed Data
-- ============================================================================
-- 
-- Purpose: Populate database with production reference data only
-- Version: 1.0.0
-- Environment: Production
-- 
-- This file contains ONLY reference data that should exist in production:
-- - Card issuers
-- - Card categories  
-- - Spending categories
-- 
-- NO test users, transactions, or personal data included
-- 
-- ============================================================================

-- ============================================================================
-- CARD ISSUERS REFERENCE DATA
-- ============================================================================

INSERT INTO card_issuers (id, name, logo_url, website_url, customer_service_phone, enabled) VALUES
(uuid_generate_v4(), 'HDFC Bank', 'https://logos.hdfcbank.com/hdfc-logo.png', 'https://www.hdfcbank.com', '1800-266-4332', true),
(uuid_generate_v4(), 'ICICI Bank', 'https://logos.icicibank.com/icici-logo.png', 'https://www.icicibank.com', '1800-102-4242', true),
(uuid_generate_v4(), 'SBI Cards', 'https://logos.sbicard.com/sbi-logo.png', 'https://www.sbicard.com', '1800-180-1290', true),
(uuid_generate_v4(), 'Axis Bank', 'https://logos.axisbank.com/axis-logo.png', 'https://www.axisbank.com', '1800-419-5959', true),
(uuid_generate_v4(), 'Kotak Mahindra Bank', 'https://logos.kotak.com/kotak-logo.png', 'https://www.kotak.com', '1800-274-0110', true),
(uuid_generate_v4(), 'American Express India', 'https://logos.americanexpress.com/amex-india-logo.png', 'https://www.americanexpress.com/in', '1800-110-024', true),
(uuid_generate_v4(), 'IndusInd Bank', 'https://logos.indusind.com/indusind-logo.png', 'https://www.indusind.com', '1800-267-7777', true),
(uuid_generate_v4(), 'Yes Bank', 'https://logos.yesbank.com/yes-logo.png', 'https://www.yesbank.in', '1800-220-0200', true),
(uuid_generate_v4(), 'BOB Cards', 'https://logos.bobcards.com/bob-logo.png', 'https://www.bobcards.com', '1800-180-1111', true),
(uuid_generate_v4(), 'Standard Chartered India', 'https://logos.sc.com/sc-india-logo.png', 'https://www.sc.com/in', '1800-345-3333', true),
(uuid_generate_v4(), 'RBL Bank', 'https://logos.rblbank.com/rbl-logo.png', 'https://www.rblbank.com', '1800-121-9050', true),
(uuid_generate_v4(), 'IDFC First Bank', 'https://logos.idfcfirstbank.com/idfc-logo.png', 'https://www.idfcfirstbank.com', '1800-10-888', true);

-- ============================================================================
-- CARD CATEGORIES REFERENCE DATA
-- ============================================================================

INSERT INTO card_categories (id, name, description, icon, color, enabled) VALUES
(uuid_generate_v4(), 'Travel Rewards', 'Cards that earn points or miles for travel purchases', 'airplane', '#3B82F6', true),
(uuid_generate_v4(), 'Cash Back', 'Cards that offer cash back on purchases', 'dollar-sign', '#10B981', true),
(uuid_generate_v4(), 'Business', 'Credit cards designed for business expenses', 'briefcase', '#8B5CF6', true),
(uuid_generate_v4(), 'Student', 'Credit cards designed for students with limited credit history', 'graduation-cap', '#F59E0B', true),
(uuid_generate_v4(), 'Secured', 'Cards that require a security deposit', 'shield', '#EF4444', true),
(uuid_generate_v4(), 'Premium', 'High-end cards with exclusive benefits and higher fees', 'crown', '#F97316', true),
(uuid_generate_v4(), 'Balance Transfer', 'Cards with promotional rates for transferring balances', 'refresh', '#06B6D4', true),
(uuid_generate_v4(), 'No Annual Fee', 'Cards with no annual fee', 'check-circle', '#84CC16', true),
(uuid_generate_v4(), 'Rewards', 'General rewards cards that earn points on purchases', 'gift', '#EC4899', true),
(uuid_generate_v4(), 'Low Interest', 'Cards with low ongoing APR rates', 'trending-down', '#6366F1', true);

-- ============================================================================
-- SPENDING CATEGORIES REFERENCE DATA
-- ============================================================================

INSERT INTO spending_categories (id, name, description, icon, color, keywords, enabled, is_system_category) VALUES
-- Essential Categories
(uuid_generate_v4(), 'Groceries', 'Food and household items', 'shopping-cart', '#10B981', 'grocery,supermarket,food,walmart,target,costco,kroger,safeway,whole foods,trader joe,aldi,publix,wegmans,harris teeter', true, true),
(uuid_generate_v4(), 'Gas & Fuel', 'Gasoline and vehicle fuel', 'gas-pump', '#EF4444', 'gas,fuel,shell,exxon,chevron,bp,mobil,station,texaco,marathon,speedway,wawa,circle k', true, true),
(uuid_generate_v4(), 'Restaurants', 'Dining out and food delivery', 'utensils', '#F59E0B', 'restaurant,dining,food,delivery,uber eats,doordash,grubhub,takeout,mcdonald,burger king,subway,starbucks,chipotle,taco bell,pizza', true, true),
(uuid_generate_v4(), 'Bills & Utilities', 'Monthly bills and utilities', 'receipt', '#6B7280', 'electric,water,internet,phone,cable,utility,bill,payment,verizon,att,comcast,spectrum,duke energy,pge', true, true),

-- Transportation
(uuid_generate_v4(), 'Transportation', 'Public transit, rideshare, and parking', 'car', '#3B82F6', 'uber,lyft,taxi,metro,bus,train,parking,toll,subway,transit,amtrak', true, true),
(uuid_generate_v4(), 'Auto & Transport', 'Car maintenance, insurance, and related expenses', 'wrench', '#6366F1', 'auto,car,mechanic,insurance,repair,maintenance,oil change,tire,dmv,registration', true, true),

-- Shopping & Entertainment
(uuid_generate_v4(), 'Shopping', 'General retail purchases', 'shopping-bag', '#F97316', 'amazon,ebay,shopping,retail,store,mall,online,clothing,electronics,home depot,lowes,best buy', true, true),
(uuid_generate_v4(), 'Entertainment', 'Movies, games, and leisure activities', 'film', '#8B5CF6', 'movie,theater,netflix,spotify,gaming,entertainment,concert,streaming,hulu,disney,apple music', true, true),

-- Travel & Accommodation
(uuid_generate_v4(), 'Travel', 'Flights, hotels, and vacation expenses', 'airplane', '#06B6D4', 'airline,hotel,flight,vacation,airbnb,booking,expedia,marriott,hilton,delta,american airlines,united', true, true),

-- Health & Personal Care
(uuid_generate_v4(), 'Healthcare', 'Medical expenses and insurance', 'heart', '#EC4899', 'doctor,hospital,pharmacy,medical,health,insurance,prescription,cvs,walgreens,dentist,clinic', true, true),
(uuid_generate_v4(), 'Personal Care', 'Beauty, grooming, and wellness', 'user', '#F472B6', 'salon,spa,beauty,haircut,massage,gym,fitness,cosmetics,skincare', true, true),

-- Financial & Professional
(uuid_generate_v4(), 'Financial Services', 'Banking, investments, and financial fees', 'credit-card', '#1F2937', 'bank,atm,fee,investment,loan,mortgage,credit,financial,advisor,tax preparation', true, true),
(uuid_generate_v4(), 'Professional Services', 'Legal, accounting, and business services', 'briefcase', '#374151', 'lawyer,accountant,consultant,legal,professional,business,service,contractor', true, true),

-- Education & Family
(uuid_generate_v4(), 'Education', 'School and learning expenses', 'book', '#0891B2', 'school,education,tuition,books,supplies,course,university,college,training,certification', true, true),
(uuid_generate_v4(), 'Family & Childcare', 'Children and family-related expenses', 'users', '#DB2777', 'childcare,daycare,babysitter,kids,children,family,school supplies,toys,diapers', true, true),

-- Home & Garden
(uuid_generate_v4(), 'Home & Garden', 'Home improvement and gardening', 'home', '#059669', 'home improvement,garden,lawn,landscaping,furniture,appliances,home depot,lowes,ikea', true, true),

-- Charitable & Gifts
(uuid_generate_v4(), 'Charitable Giving', 'Donations and charitable contributions', 'heart-handshake', '#7C3AED', 'donation,charity,church,nonprofit,giving,contribution,tithe', true, true),
(uuid_generate_v4(), 'Gifts & Special Occasions', 'Gifts, celebrations, and special events', 'gift', '#DC2626', 'gift,birthday,wedding,holiday,celebration,flowers,party,anniversary', true, true),

-- Miscellaneous
(uuid_generate_v4(), 'Other', 'Miscellaneous expenses', 'more-horizontal', '#9CA3AF', '', true, true);

-- ============================================================================
-- PRODUCTION VERIFICATION
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
    
    RAISE NOTICE 'Production reference data loaded successfully:';
    RAISE NOTICE '- Card Issuers: %', issuer_count;
    RAISE NOTICE '- Card Categories: %', category_count;
    RAISE NOTICE '- Spending Categories: %', spending_count;
    
    IF issuer_count < 10 OR category_count < 8 OR spending_count < 15 THEN
        RAISE WARNING 'Some reference data may be missing. Please verify the seed data.';
    END IF;
END $$;

-- ============================================================================
-- PRODUCTION NOTES
-- ============================================================================

-- This production seed includes:
-- - 12 major Indian credit card issuers with contact information
-- - 10 comprehensive card categories covering all major types
-- - 18 detailed spending categories with extensive keyword matching
-- - All categories include proper icons and colors for UI consistency
-- - Keywords are optimized for automatic transaction categorization

-- Security considerations:
-- - No personal data or test accounts included
-- - All reference data is publicly available information
-- - UUIDs are generated at runtime for security

-- Maintenance:
-- - Review and update issuer information quarterly
-- - Add new spending categories as needed based on user feedback
-- - Update keywords based on transaction categorization accuracy

-- ============================================================================
-- END OF PRODUCTION SEED
-- ============================================================================ 