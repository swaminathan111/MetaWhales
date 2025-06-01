-- ============================================================================
-- CardSense AI Database Schema - Extensions Setup
-- ============================================================================
-- 
-- Purpose: Enable required PostgreSQL extensions for the CardSense AI application
-- Version: 1.0.0
-- Compatible with: PostgreSQL 13+, Supabase
-- 
-- Extensions enabled:
-- - uuid-ossp: For UUID generation (primary keys)
-- - pgcrypto: For encryption and hashing functions
-- 
-- ============================================================================

-- Enable UUID generation extension
-- Required for generating UUID primary keys across all tables
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable cryptographic functions
-- Required for password hashing and data encryption
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Verify extensions are installed
DO $$
BEGIN
    -- Check if uuid-ossp is available
    IF NOT EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp'
    ) THEN
        RAISE EXCEPTION 'Failed to install uuid-ossp extension';
    END IF;
    
    -- Check if pgcrypto is available
    IF NOT EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto'
    ) THEN
        RAISE EXCEPTION 'Failed to install pgcrypto extension';
    END IF;
    
    RAISE NOTICE 'All required extensions installed successfully';
END $$;

-- ============================================================================
-- Extension Usage Notes:
-- 
-- uuid-ossp functions used:
-- - uuid_generate_v4(): Generate random UUIDs for primary keys
-- 
-- pgcrypto functions used:
-- - crypt(): Hash passwords and sensitive data
-- - gen_salt(): Generate salt for password hashing
-- - encrypt/decrypt(): Encrypt sensitive data fields
-- ============================================================================ 