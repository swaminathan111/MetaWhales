-- ============================================================================
-- CardSense AI Database Schema - Row Level Security (RLS) Policies
-- ============================================================================
-- 
-- Purpose: Define security policies to protect user data
-- Version: 1.0.0
-- Compatible with: PostgreSQL 13+, Supabase
-- 
-- Security Features:
-- - Row Level Security on all user data tables
-- - User isolation (users can only access their own data)
-- - Admin access through service role
-- - Public access for reference data only
-- 
-- ============================================================================

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY ON ALL TABLES
-- ============================================================================

-- User data tables - require authentication
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE spending_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_engagement ENABLE ROW LEVEL SECURITY;

-- Reference tables - public read access, admin write
ALTER TABLE card_issuers ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE spending_categories ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- USER PROFILES POLICIES
-- ============================================================================

-- Users can view and update their own profile
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (triggered by auth signup)
CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Service role can manage all profiles
CREATE POLICY "Service role can manage all profiles" ON user_profiles
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================================================
-- USER CARDS POLICIES
-- ============================================================================

-- Users can manage their own cards
CREATE POLICY "Users can view own cards" ON user_cards
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cards" ON user_cards
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cards" ON user_cards
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cards" ON user_cards
    FOR DELETE USING (auth.uid() = user_id);

-- Service role can manage all cards
CREATE POLICY "Service role can manage all cards" ON user_cards
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================================================
-- TRANSACTIONS POLICIES
-- ============================================================================

-- Users can manage their own transactions
CREATE POLICY "Users can view own transactions" ON transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions" ON transactions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own transactions" ON transactions
    FOR DELETE USING (auth.uid() = user_id);

-- Service role can manage all transactions
CREATE POLICY "Service role can manage all transactions" ON transactions
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================================================
-- SPENDING SUMMARIES POLICIES
-- ============================================================================

-- Users can view their own spending summaries
CREATE POLICY "Users can view own spending summaries" ON spending_summaries
    FOR SELECT USING (auth.uid() = user_id);

-- Only system/service can insert/update summaries (calculated automatically)
CREATE POLICY "Service role can manage spending summaries" ON spending_summaries
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================================================
-- CHAT CONVERSATIONS POLICIES
-- ============================================================================

-- Users can manage their own conversations
CREATE POLICY "Users can view own conversations" ON chat_conversations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations" ON chat_conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations" ON chat_conversations
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversations" ON chat_conversations
    FOR DELETE USING (auth.uid() = user_id);

-- Service role can manage all conversations
CREATE POLICY "Service role can manage all conversations" ON chat_conversations
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================================================
-- CHAT MESSAGES POLICIES
-- ============================================================================

-- Users can view messages from their own conversations
CREATE POLICY "Users can view own messages" ON chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE id = chat_messages.conversation_id 
            AND user_id = auth.uid()
        )
    );

-- Users can insert messages to their own conversations
CREATE POLICY "Users can insert own messages" ON chat_messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE id = chat_messages.conversation_id 
            AND user_id = auth.uid()
        )
    );

-- Users can update their own messages
CREATE POLICY "Users can update own messages" ON chat_messages
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE id = chat_messages.conversation_id 
            AND user_id = auth.uid()
        )
    );

-- Users can delete their own messages
CREATE POLICY "Users can delete own messages" ON chat_messages
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE id = chat_messages.conversation_id 
            AND user_id = auth.uid()
        )
    );

-- Service role can manage all messages
CREATE POLICY "Service role can manage all messages" ON chat_messages
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================================================
-- NOTIFICATIONS POLICIES
-- ============================================================================

-- Users can view and manage their own notifications
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notifications" ON notifications
    FOR DELETE USING (auth.uid() = user_id);

-- System can create notifications for users
CREATE POLICY "Service role can create notifications" ON notifications
    FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- Service role can manage all notifications
CREATE POLICY "Service role can manage all notifications" ON notifications
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================================================
-- USER ENGAGEMENT POLICIES
-- ============================================================================

-- Users can view their own engagement data
CREATE POLICY "Users can view own engagement" ON user_engagement
    FOR SELECT USING (auth.uid() = user_id);

-- Only system can insert engagement data
CREATE POLICY "Service role can manage engagement" ON user_engagement
    FOR ALL USING (auth.role() = 'service_role');

-- ============================================================================
-- REFERENCE TABLES POLICIES (PUBLIC READ ACCESS)
-- ============================================================================

-- Card issuers - public read access
CREATE POLICY "Public read access to card issuers" ON card_issuers
    FOR SELECT USING (true);

-- Admin/service role can manage card issuers
CREATE POLICY "Service role can manage card issuers" ON card_issuers
    FOR ALL USING (auth.role() = 'service_role');

-- Card categories - public read access
CREATE POLICY "Public read access to card categories" ON card_categories
    FOR SELECT USING (true);

-- Admin/service role can manage card categories
CREATE POLICY "Service role can manage card categories" ON card_categories
    FOR ALL USING (auth.role() = 'service_role');

-- Spending categories - public read access
CREATE POLICY "Public read access to spending categories" ON spending_categories
    FOR SELECT USING (true);

-- Admin/service role can manage spending categories
CREATE POLICY "Service role can manage spending categories" ON spending_categories
    FOR ALL USING (auth.role() = 'service_role');

-- Note: Users cannot create custom spending categories in the current schema
-- All spending categories are system-managed for consistency
-- If custom categories are needed, add a user_id column to spending_categories table

-- ============================================================================
-- ADDITIONAL SECURITY FUNCTIONS
-- ============================================================================

-- Function to check if user owns a conversation
CREATE OR REPLACE FUNCTION auth.owns_conversation(conversation_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM chat_conversations
        WHERE id = conversation_id AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user owns a card
CREATE OR REPLACE FUNCTION auth.owns_card(card_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_cards
        WHERE id = card_id AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to validate user can access transaction
CREATE OR REPLACE FUNCTION auth.can_access_transaction(transaction_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM transactions
        WHERE id = transaction_id AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- REALTIME POLICIES FOR SUPABASE
-- ============================================================================

-- Enable realtime for chat functionality
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_conversations;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- Enable realtime for transaction updates
ALTER PUBLICATION supabase_realtime ADD TABLE transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE spending_summaries;

-- ============================================================================
-- SECURITY TESTING FUNCTIONS
-- ============================================================================

-- Function to test RLS policies (for development)
CREATE OR REPLACE FUNCTION test_rls_policies()
RETURNS TABLE(
    table_name TEXT,
    policy_count INTEGER,
    rls_enabled BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tablename::TEXT,
        COUNT(p.policyname)::INTEGER as policy_count,
        t.rowsecurity as rls_enabled
    FROM pg_tables t
    LEFT JOIN pg_policies p ON p.tablename = t.tablename
    WHERE t.schemaname = 'public'
    AND t.tablename IN (
        'user_profiles', 'user_cards', 'transactions', 'spending_summaries',
        'chat_conversations', 'chat_messages', 'notifications', 'user_engagement',
        'card_issuers', 'card_categories', 'spending_categories'
    )
    GROUP BY t.tablename, t.rowsecurity
    ORDER BY t.tablename;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- AUDIT FUNCTIONS
-- ============================================================================

-- Function to log security events
CREATE OR REPLACE FUNCTION log_security_event(
    event_type TEXT,
    table_name TEXT,
    record_id UUID,
    details JSONB DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    -- In production, you might want to log to a separate audit table
    -- For now, just raise a notice
    RAISE NOTICE 'Security Event: % on % for record % by user % - %', 
        event_type, 
        table_name, 
        record_id, 
        auth.uid(), 
        details;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- COMMENTS AND DOCUMENTATION
-- ============================================================================

COMMENT ON POLICY "Users can view own profile" ON user_profiles IS 
'Allows users to view their own profile data only';

COMMENT ON POLICY "Users can view own cards" ON user_cards IS 
'Users can only see their own credit cards';

COMMENT ON POLICY "Users can view own transactions" ON transactions IS 
'Users can only access their own transaction history';

COMMENT ON POLICY "Public read access to card issuers" ON card_issuers IS 
'Card issuers are public reference data';

COMMENT ON POLICY "Users can view own messages" ON chat_messages IS 
'Users can only see messages from their own conversations';

-- ============================================================================
-- SECURITY BEST PRACTICES NOTES
-- ============================================================================

-- 1. All user data tables have RLS enabled
-- 2. Users can only access their own data
-- 3. Reference tables are publicly readable but only admin writable
-- 4. Service role has full access for system operations
-- 5. Realtime is enabled for chat and notification features
-- 6. Custom functions help validate ownership
-- 7. Audit capabilities are built in
-- 8. Policies are well documented

-- ============================================================================
-- END OF RLS POLICIES
-- ============================================================================ 