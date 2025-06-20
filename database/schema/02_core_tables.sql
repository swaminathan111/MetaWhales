-- ============================================================================
-- CardSense AI Database Schema - Core Tables
-- ============================================================================
-- 
-- Purpose: Define all core application tables for CardSense AI
-- Version: 1.0.0
-- Compatible with: PostgreSQL 13+, Supabase
-- 
-- Tables included:
-- - user_profiles: Extended user information (extends Supabase auth.users)
-- - card_issuers: Credit card issuing banks/institutions
-- - card_categories: Credit card type classifications
-- - user_cards: User's credit/debit cards
-- - spending_categories: Transaction categorization system
-- - transactions: All user financial transactions
-- - chat_conversations: AI chat session management
-- - chat_messages: Individual chat messages
-- - notifications: User notification system
-- - alert_rules: Automated alert configuration
-- - spending_summaries: Monthly spending analytics
-- - user_engagement: User behavior tracking
-- 
-- ============================================================================

-- ============================================================================
-- 1. USER PROFILES & AUTHENTICATION
-- ============================================================================

-- User profiles table (extends Supabase auth.users)
-- Stores additional user information and preferences
CREATE TABLE user_profiles (
    -- Primary key references Supabase auth.users
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    
    -- Basic user information
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    
    -- Onboarding & user preferences
    onboarding_completed BOOLEAN DEFAULT FALSE,
    onboarding_completed_at TIMESTAMP WITH TIME ZONE,
    selected_optimizations TEXT[] DEFAULT '{}',
    selected_spending_categories TEXT[] DEFAULT '{}',
    -- Add missing onboarding fields
    monthly_spending_range VARCHAR(20), -- e.g., '₹10-30k'
    is_open_to_new_card BOOLEAN,
    onboarding_additional_info TEXT,
    preferred_language VARCHAR(10) DEFAULT 'en',
    
    -- App settings and preferences
    notification_preferences JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{}',
    ai_chat_enabled BOOLEAN DEFAULT TRUE,
    speech_to_text_enabled BOOLEAN DEFAULT TRUE,
    
    -- Metadata and tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    app_version VARCHAR(20),
    
    -- Constraints
    CONSTRAINT user_profiles_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

-- ============================================================================
-- 2. CREDIT CARD MANAGEMENT
-- ============================================================================

-- Card issuers/banks table
-- Stores information about financial institutions that issue cards
CREATE TABLE card_issuers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    logo_url TEXT,
    website_url TEXT,
    customer_service_phone VARCHAR(20),
    country VARCHAR(100) DEFAULT 'India',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Card categories table
-- Defines different types/categories of credit cards
CREATE TABLE card_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_name VARCHAR(50),
    color_code VARCHAR(7), -- Hex color code
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User cards table
-- Stores user's credit and debit cards
CREATE TABLE user_cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    issuer_id UUID REFERENCES card_issuers(id),
    category_id UUID REFERENCES card_categories(id),
    
    -- Card identification (no sensitive data stored)
    card_name VARCHAR(255) NOT NULL,
    card_type VARCHAR(50) CHECK (card_type IN ('credit', 'debit', 'prepaid')),
    last_four_digits VARCHAR(4),
    card_network VARCHAR(20) CHECK (card_network IN ('visa', 'mastercard', 'rupay', 'amex', 'diners')),
    
    -- Financial information
    credit_limit DECIMAL(12,2),
    current_balance DECIMAL(12,2) DEFAULT 0,
    available_credit DECIMAL(12,2),
    minimum_payment DECIMAL(10,2),
    due_date DATE,
    statement_date DATE,
    annual_fee DECIMAL(10,2),
    interest_rate DECIMAL(5,2),
    
    -- Rewards and benefits
    reward_points DECIMAL(10,2) DEFAULT 0,
    cashback_earned DECIMAL(10,2) DEFAULT 0,
    benefits JSONB DEFAULT '{}', -- Store benefits as JSON
    
    -- Card status and metadata
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked', 'expired')),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(user_id, card_name),
    CONSTRAINT valid_last_four_digits CHECK (last_four_digits ~ '^[0-9]{4}$')
);

-- ============================================================================
-- 3. SPENDING CATEGORIES & TRANSACTIONS
-- ============================================================================

-- Spending categories table
-- Defines categories for transaction classification
CREATE TABLE spending_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_name VARCHAR(50),
    color_code VARCHAR(7),
    parent_category_id UUID REFERENCES spending_categories(id),
    is_system_category BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Transactions table
-- Stores all user financial transactions
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    card_id UUID REFERENCES user_cards(id) ON DELETE CASCADE,
    category_id UUID REFERENCES spending_categories(id),
    
    -- Transaction details
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    description TEXT NOT NULL,
    merchant_name VARCHAR(255),
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('purchase', 'refund', 'payment', 'fee', 'interest')),
    
    -- Location and timing
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
    location_city VARCHAR(100),
    location_country VARCHAR(100) DEFAULT 'India',
    
    -- Rewards and points
    reward_points_earned DECIMAL(8,2) DEFAULT 0,
    cashback_earned DECIMAL(8,2) DEFAULT 0,
    reward_rate DECIMAL(4,2), -- Percentage rate used
    
    -- Status and metadata
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    is_recurring BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT positive_amount CHECK (amount > 0)
);

-- ============================================================================
-- 4. AI CHAT & CONVERSATIONS
-- ============================================================================

-- Chat conversations table
-- Manages AI chat sessions
CREATE TABLE chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    
    -- Conversation metadata
    title VARCHAR(255),
    summary TEXT,
    total_messages INTEGER DEFAULT 0,
    
    -- Timing and status
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived', 'deleted')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat messages table
-- Stores individual chat messages
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES chat_conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    
    -- Message content
    message TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'voice', 'system')),
    sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('user', 'assistant')),
    
    -- AI model information
    ai_model_used VARCHAR(100),
    ai_response_time_ms INTEGER,
    confidence_score DECIMAL(3,2),
    
    -- Voice message details
    voice_duration_seconds INTEGER,
    voice_file_url TEXT,
    transcription_text TEXT,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_confidence_score CHECK (confidence_score >= 0 AND confidence_score <= 1)
);

-- ============================================================================
-- 5. NOTIFICATIONS & ALERTS
-- ============================================================================

-- Notifications table
-- Stores user notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    
    -- Notification content
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    
    -- Action and navigation
    action_url TEXT,
    action_data JSONB,
    
    -- Delivery and status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    delivery_method VARCHAR(20) DEFAULT 'in_app' CHECK (delivery_method IN ('in_app', 'push', 'email', 'sms')),
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Alert rules table
-- Configures automated notifications
CREATE TABLE alert_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    card_id UUID REFERENCES user_cards(id) ON DELETE CASCADE,
    
    -- Rule configuration
    rule_name VARCHAR(255) NOT NULL,
    rule_type VARCHAR(50) NOT NULL,
    conditions JSONB NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Notification settings
    notification_title VARCHAR(255),
    notification_message TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 6. ANALYTICS & INSIGHTS
-- ============================================================================

-- Monthly spending summaries table
-- Stores aggregated spending data for analytics
CREATE TABLE spending_summaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    
    -- Time period
    year INTEGER NOT NULL,
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    
    -- Summary data
    total_spent DECIMAL(12,2) DEFAULT 0,
    total_transactions INTEGER DEFAULT 0,
    average_transaction_amount DECIMAL(10,2) DEFAULT 0,
    largest_transaction_amount DECIMAL(12,2) DEFAULT 0,
    
    -- Category and card breakdowns
    category_breakdown JSONB DEFAULT '{}',
    card_usage_breakdown JSONB DEFAULT '{}',
    
    -- Rewards earned
    total_reward_points DECIMAL(10,2) DEFAULT 0,
    total_cashback DECIMAL(10,2) DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(user_id, year, month),
    CONSTRAINT valid_year CHECK (year >= 2020 AND year <= 2100)
);

-- User engagement table
-- Tracks user behavior and app usage
CREATE TABLE user_engagement (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    
    -- Session information
    session_id VARCHAR(100),
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB DEFAULT '{}',
    
    -- Context
    screen_name VARCHAR(100),
    feature_used VARCHAR(100),
    duration_seconds INTEGER,
    
    -- Device and app info
    app_version VARCHAR(20),
    platform VARCHAR(20),
    device_info JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- Table Comments for Documentation
-- ============================================================================

COMMENT ON TABLE user_profiles IS 'Extended user profiles that complement Supabase auth.users';
COMMENT ON TABLE card_issuers IS 'Financial institutions that issue credit/debit cards';
COMMENT ON TABLE card_categories IS 'Classification system for different types of cards';
COMMENT ON TABLE user_cards IS 'User-owned credit and debit cards (no sensitive data stored)';
COMMENT ON TABLE spending_categories IS 'Hierarchical categorization system for transactions';
COMMENT ON TABLE transactions IS 'All user financial transactions with detailed metadata';
COMMENT ON TABLE chat_conversations IS 'AI chat sessions with conversation metadata';
COMMENT ON TABLE chat_messages IS 'Individual messages within chat conversations';
COMMENT ON TABLE notifications IS 'User notification system with delivery tracking';
COMMENT ON TABLE alert_rules IS 'User-configured automated alert rules';
COMMENT ON TABLE spending_summaries IS 'Pre-aggregated monthly spending analytics';
COMMENT ON TABLE user_engagement IS 'User behavior tracking for analytics and improvements';

-- ============================================================================
-- Success Message
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Core tables created successfully. Total tables: 12';
    RAISE NOTICE 'Next steps: Run 03_indexes.sql for performance optimization';
END $$; 