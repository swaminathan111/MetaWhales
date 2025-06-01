-- ============================================================================
-- CardSense AI Database Schema - Supabase Storage Configuration
-- ============================================================================
-- 
-- Purpose: Configure Supabase storage buckets and policies for file uploads
-- Version: 1.0.0
-- Compatible with: Supabase Storage
-- 
-- Storage Features:
-- - User profile images
-- - Document uploads (receipts, statements)
-- - Chat attachments
-- - Secure file access with RLS
-- 
-- ============================================================================

-- ============================================================================
-- CREATE STORAGE BUCKETS
-- ============================================================================

-- Create bucket for user profile images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profile-images',
    'profile-images',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
);

-- Create bucket for document uploads (receipts, statements)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'documents',
    'documents',
    false, -- Private bucket
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf', 'text/plain']
);

-- Create bucket for chat attachments
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'chat-attachments',
    'chat-attachments',
    false, -- Private bucket
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'application/pdf']
);

-- ============================================================================
-- STORAGE POLICIES FOR PROFILE IMAGES
-- ============================================================================

-- Users can view their own profile images and public images
CREATE POLICY "Users can view profile images" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'profile-images' AND (
            auth.uid()::text = (storage.foldername(name))[1] OR
            bucket_id = 'profile-images' -- Public bucket
        )
    );

-- Users can upload their own profile images
CREATE POLICY "Users can upload profile images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'profile-images' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        (storage.extension(name)) IN ('jpg', 'jpeg', 'png', 'webp', 'gif')
    );

-- Users can update their own profile images
CREATE POLICY "Users can update profile images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'profile-images' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can delete their own profile images
CREATE POLICY "Users can delete profile images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'profile-images' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- ============================================================================
-- STORAGE POLICIES FOR DOCUMENTS
-- ============================================================================

-- Users can view their own documents only
CREATE POLICY "Users can view own documents" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'documents' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can upload their own documents
CREATE POLICY "Users can upload documents" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'documents' AND
        auth.uid()::text = (storage.foldername(name))[1] AND
        (storage.extension(name)) IN ('jpg', 'jpeg', 'png', 'webp', 'pdf', 'txt')
    );

-- Users can update their own documents
CREATE POLICY "Users can update documents" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'documents' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Users can delete their own documents
CREATE POLICY "Users can delete documents" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'documents' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- ============================================================================
-- STORAGE POLICIES FOR CHAT ATTACHMENTS
-- ============================================================================

-- Users can view chat attachments from their conversations
CREATE POLICY "Users can view chat attachments" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'chat-attachments' AND
        EXISTS (
            SELECT 1 FROM chat_conversations cc
            WHERE cc.user_id = auth.uid()
            AND cc.id::text = (storage.foldername(name))[1]
        )
    );

-- Users can upload chat attachments to their conversations
CREATE POLICY "Users can upload chat attachments" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'chat-attachments' AND
        EXISTS (
            SELECT 1 FROM chat_conversations cc
            WHERE cc.user_id = auth.uid()
            AND cc.id::text = (storage.foldername(name))[1]
        ) AND
        (storage.extension(name)) IN ('jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf')
    );

-- Users can delete chat attachments from their conversations
CREATE POLICY "Users can delete chat attachments" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'chat-attachments' AND
        EXISTS (
            SELECT 1 FROM chat_conversations cc
            WHERE cc.user_id = auth.uid()
            AND cc.id::text = (storage.foldername(name))[1]
        )
    );

-- ============================================================================
-- HELPER FUNCTIONS FOR STORAGE
-- ============================================================================

-- Function to get user's profile image URL
CREATE OR REPLACE FUNCTION get_profile_image_url(user_uuid UUID)
RETURNS TEXT AS $$
DECLARE
    image_path TEXT;
    public_url TEXT;
BEGIN
    -- Look for user's profile image
    SELECT name INTO image_path
    FROM storage.objects
    WHERE bucket_id = 'profile-images'
    AND (storage.foldername(name))[1] = user_uuid::text
    ORDER BY created_at DESC
    LIMIT 1;
    
    IF image_path IS NOT NULL THEN
        -- Return the public URL for the image
        RETURN 'https://your-project.supabase.co/storage/v1/object/public/profile-images/' || image_path;
    ELSE
        -- Return default avatar URL
        RETURN 'https://your-project.supabase.co/storage/v1/object/public/profile-images/default-avatar.png';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean up orphaned files
CREATE OR REPLACE FUNCTION cleanup_orphaned_files()
RETURNS VOID AS $$
BEGIN
    -- Clean up profile images for deleted users
    DELETE FROM storage.objects
    WHERE bucket_id = 'profile-images'
    AND NOT EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id::text = (storage.foldername(name))[1]
    );
    
    -- Clean up documents for deleted users
    DELETE FROM storage.objects
    WHERE bucket_id = 'documents'
    AND NOT EXISTS (
        SELECT 1 FROM user_profiles up
        WHERE up.id::text = (storage.foldername(name))[1]
    );
    
    -- Clean up chat attachments for deleted conversations
    DELETE FROM storage.objects
    WHERE bucket_id = 'chat-attachments'
    AND NOT EXISTS (
        SELECT 1 FROM chat_conversations cc
        WHERE cc.id::text = (storage.foldername(name))[1]
    );
    
    RAISE NOTICE 'Orphaned files cleanup completed';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- STORAGE TRIGGERS
-- ============================================================================

-- Function to handle file upload notifications
CREATE OR REPLACE FUNCTION handle_file_upload()
RETURNS TRIGGER AS $$
DECLARE
    user_uuid UUID;
    file_type TEXT;
BEGIN
    -- Determine file type based on bucket
    CASE NEW.bucket_id
        WHEN 'profile-images' THEN
            file_type := 'profile_image';
            user_uuid := (storage.foldername(NEW.name))[1]::UUID;
        WHEN 'documents' THEN
            file_type := 'document';
            user_uuid := (storage.foldername(NEW.name))[1]::UUID;
        WHEN 'chat-attachments' THEN
            file_type := 'chat_attachment';
            -- For chat attachments, get user from conversation
            SELECT cc.user_id INTO user_uuid
            FROM chat_conversations cc
            WHERE cc.id::text = (storage.foldername(NEW.name))[1];
        ELSE
            RETURN NEW;
    END CASE;
    
    -- Create notification for file upload
    IF user_uuid IS NOT NULL THEN
        PERFORM create_notification(
            user_uuid,
            'file_uploaded',
            'File Uploaded',
            'A new ' || file_type || ' has been uploaded successfully.',
            jsonb_build_object(
                'file_name', NEW.name,
                'file_size', NEW.metadata->>'size',
                'file_type', file_type,
                'bucket', NEW.bucket_id
            )
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for file upload notifications
CREATE TRIGGER on_file_upload
    AFTER INSERT ON storage.objects
    FOR EACH ROW
    EXECUTE FUNCTION handle_file_upload();

-- ============================================================================
-- STORAGE UTILITY VIEWS
-- ============================================================================

-- View for user file statistics
CREATE OR REPLACE VIEW user_file_stats AS
SELECT 
    up.id as user_id,
    up.email,
    COUNT(CASE WHEN so.bucket_id = 'profile-images' THEN 1 END) as profile_images_count,
    COUNT(CASE WHEN so.bucket_id = 'documents' THEN 1 END) as documents_count,
    COUNT(CASE WHEN so.bucket_id = 'chat-attachments' THEN 1 END) as chat_attachments_count,
    COALESCE(SUM((so.metadata->>'size')::bigint), 0) as total_storage_used,
    MAX(so.created_at) as last_upload_at
FROM user_profiles up
LEFT JOIN storage.objects so ON (
    (so.bucket_id = 'profile-images' AND up.id::text = (storage.foldername(so.name))[1]) OR
    (so.bucket_id = 'documents' AND up.id::text = (storage.foldername(so.name))[1]) OR
    (so.bucket_id = 'chat-attachments' AND EXISTS (
        SELECT 1 FROM chat_conversations cc 
        WHERE cc.user_id = up.id 
        AND cc.id::text = (storage.foldername(so.name))[1]
    ))
)
GROUP BY up.id, up.email;

-- ============================================================================
-- STORAGE CONFIGURATION NOTES
-- ============================================================================

-- File Organization:
-- - profile-images/{user_id}/{filename}
-- - documents/{user_id}/{filename}
-- - chat-attachments/{conversation_id}/{filename}

-- Security Features:
-- - RLS policies ensure users can only access their own files
-- - File type restrictions based on MIME types
-- - Size limits to prevent abuse
-- - Automatic cleanup of orphaned files

-- Best Practices:
-- - Use UUIDs for folder names to prevent enumeration
-- - Implement client-side file validation
-- - Consider image optimization for profile pictures
-- - Regular cleanup of old/unused files

-- ============================================================================
-- STORAGE MAINTENANCE FUNCTIONS
-- ============================================================================

-- Function to get storage usage statistics
CREATE OR REPLACE FUNCTION get_storage_stats()
RETURNS TABLE(
    bucket_name TEXT,
    file_count BIGINT,
    total_size BIGINT,
    avg_file_size NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        so.bucket_id as bucket_name,
        COUNT(*) as file_count,
        COALESCE(SUM((so.metadata->>'size')::bigint), 0) as total_size,
        COALESCE(AVG((so.metadata->>'size')::bigint), 0) as avg_file_size
    FROM storage.objects so
    GROUP BY so.bucket_id
    ORDER BY total_size DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to find large files
CREATE OR REPLACE FUNCTION find_large_files(size_threshold BIGINT DEFAULT 5242880)
RETURNS TABLE(
    bucket_id TEXT,
    name TEXT,
    size BIGINT,
    created_at TIMESTAMPTZ,
    owner_folder TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        so.bucket_id,
        so.name,
        (so.metadata->>'size')::bigint as size,
        so.created_at,
        (storage.foldername(so.name))[1] as owner_folder
    FROM storage.objects so
    WHERE (so.metadata->>'size')::bigint > size_threshold
    ORDER BY (so.metadata->>'size')::bigint DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- END OF STORAGE SETUP
-- ============================================================================ 