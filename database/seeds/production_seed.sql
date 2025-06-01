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
(uuid_generate_v4(), 'Chase', 'https://logos.chase.com/chase-logo.png', 'https://www.chase.com', '1-800-432-3117', true),
(uuid_generate_v4(), 'American Express', 'https://logos.americanexpress.com/amex-logo.png', 'https://www.americanexpress.com', '1-800-528-4800', true),
(uuid_generate_v4(), 'Capital One', 'https://logos.capitalone.com/capital-one-logo.png', 'https://www.capitalone.com', '1-800-227-4825', true),
(uuid_generate_v4(), 'Citi', 'https://logos.citi.com/citi-logo.png', 'https://www.citi.com', '1-800-950-5114', true),
(uuid_generate_v4(), 'Bank of America', 'https://logos.bankofamerica.com/boa-logo.png', 'https://www.bankofamerica.com', '1-800-732-9194', true),
(uuid_generate_v4(), 'Wells Fargo', 'https://logos.wellsfargo.com/wf-logo.png', 'https://www.wellsfargo.com', '1-800-869-3557', true),
(uuid_generate_v4(), 'Discover', 'https://logos.discover.com/discover-logo.png', 'https://www.discover.com', '1-800-347-2683', true),
(uuid_generate_v4(), 'US Bank', 'https://logos.usbank.com/usbank-logo.png', 'https://www.usbank.com', '1-800-872-2657', true),
(uuid_generate_v4(), 'PNC Bank', 'https://logos.pnc.com/pnc-logo.png', 'https://www.pnc.com', '1-888-762-2265', true),
(uuid_generate_v4(), 'TD Bank', 'https://logos.td.com/td-logo.png', 'https://www.td.com', '1-888-751-9000', true),
(uuid_generate_v4(), 'Barclays', 'https://logos.barclays.com/barclays-logo.png', 'https://www.barclays.com', '1-877-523-0478', true),
(uuid_generate_v4(), 'Synchrony Bank', 'https://logos.synchrony.com/synchrony-logo.png', 'https://www.synchrony.com', '1-866-396-8254', true);

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
-- - 12 major US credit card issuers with contact information
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