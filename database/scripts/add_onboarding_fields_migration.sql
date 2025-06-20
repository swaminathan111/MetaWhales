-- ============================================================================
-- Migration: Add Missing Onboarding Fields
-- ============================================================================
-- 
-- Purpose: Add missing onboarding fields to user_profiles table
-- Date: 2024-12-28
-- Compatible with: PostgreSQL 13+, Supabase
-- 
-- Fields being added:
-- - monthly_spending_range: User's selected spending range
-- - is_open_to_new_card: Whether user is open to getting new cards
-- - onboarding_additional_info: Free-text user goals/expectations
-- 
-- ============================================================================

-- Add missing onboarding fields if they don't exist
DO $$
BEGIN
    -- Add monthly_spending_range column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'monthly_spending_range'
    ) THEN
        ALTER TABLE user_profiles 
        ADD COLUMN monthly_spending_range VARCHAR(20);
        
        -- Add comment
        COMMENT ON COLUMN user_profiles.monthly_spending_range IS 'User selected spending range: ₹0-10k, ₹10-30k, ₹30-75k, ₹75k+';
    END IF;

    -- Add is_open_to_new_card column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'is_open_to_new_card'
    ) THEN
        ALTER TABLE user_profiles 
        ADD COLUMN is_open_to_new_card BOOLEAN;
        
        -- Add comment
        COMMENT ON COLUMN user_profiles.is_open_to_new_card IS 'Whether user is open to getting a new card this year';
    END IF;

    -- Add onboarding_additional_info column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'onboarding_additional_info'
    ) THEN
        ALTER TABLE user_profiles 
        ADD COLUMN onboarding_additional_info TEXT;
        
        -- Add comment
        COMMENT ON COLUMN user_profiles.onboarding_additional_info IS 'Free-text user goals, pain points, or expectations';
    END IF;

    RAISE NOTICE 'Onboarding fields migration completed successfully';
END $$;

-- Add validation constraints
ALTER TABLE user_profiles 
ADD CONSTRAINT check_monthly_spending_range 
CHECK (monthly_spending_range IS NULL OR monthly_spending_range IN ('₹0-10k', '₹10-30k', '₹30-75k', '₹75k+'));

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_monthly_spending_range 
ON user_profiles(monthly_spending_range) 
WHERE monthly_spending_range IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_user_profiles_is_open_to_new_card 
ON user_profiles(is_open_to_new_card) 
WHERE is_open_to_new_card IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_user_profiles_onboarding_completed 
ON user_profiles(onboarding_completed, onboarding_completed_at) 
WHERE onboarding_completed = TRUE;

-- Grant necessary permissions
GRANT SELECT, UPDATE ON user_profiles TO authenticated;
GRANT SELECT, UPDATE ON user_profiles TO service_role;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration completed successfully!';
    RAISE NOTICE 'Added fields: monthly_spending_range, is_open_to_new_card, onboarding_additional_info';
    RAISE NOTICE 'Added indexes for better query performance';
    RAISE NOTICE 'Next step: Update OnboardingService to use database instead of SharedPreferences';
END $$; 