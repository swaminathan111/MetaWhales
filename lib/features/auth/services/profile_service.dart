import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logging/app_logger.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ensure user profile exists, create if missing
  Future<void> ensureUserProfile({
    String? googlePhotoUrl,
    String? googleDisplayName,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        AppLogger.warning('No authenticated user found');
        return;
      }

      AppLogger.debug('Checking profile for user: ${user.id}');

      // Check if profile already exists
      final existingProfile = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile != null) {
        AppLogger.debug('User profile already exists');
        return;
      }

      // Create new user profile
      AppLogger.info('Creating new user profile for: ${user.id}');

      // Determine the best full name to use
      String fullName = googleDisplayName ??
          user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          user.email?.split('@')[0] ??
          'User';

      // Determine the best avatar URL to use
      String? avatarUrl = googlePhotoUrl ??
          user.userMetadata?['avatar_url'] ??
          user.userMetadata?['picture'];

      AppLogger.info(
          'Profile creation data - userId: ${user.id}, fullName: $fullName, avatarUrl: $avatarUrl, googlePhotoUrl: $googlePhotoUrl, googleDisplayName: $googleDisplayName');

      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'notification_preferences': {
          'push_notifications': true,
          'email_alerts': true,
          'chat_notifications': true,
        },
        'privacy_settings': {
          'data_sharing': false,
          'analytics': true,
        },
        'ai_chat_enabled': true,
        'speech_to_text_enabled': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_active_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('user_profiles').insert(profileData);

      AppLogger.info('User profile created successfully for: ${user.id}');
    } catch (e) {
      AppLogger.error('Failed to ensure user profile', e, null);

      // If it's a unique constraint violation, the profile might already exist
      if (e.toString().contains('duplicate key') ||
          e.toString().contains('unique constraint')) {
        AppLogger.info(
            'Profile already exists (unique constraint), continuing...');
        return;
      }

      // For other errors, rethrow
      rethrow;
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      AppLogger.error('Failed to get user profile', e, null);
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('user_profiles').update(updates).eq('id', user.id);

      AppLogger.info('User profile updated successfully');
    } catch (e) {
      AppLogger.error('Failed to update user profile', e, null);
      rethrow;
    }
  }

  /// Delete user profile (for account deletion)
  Future<void> deleteUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _supabase.from('user_profiles').delete().eq('id', user.id);

      AppLogger.info('User profile deleted successfully');
    } catch (e) {
      AppLogger.error('Failed to delete user profile', e, null);
      rethrow;
    }
  }

  /// Initialize profile on app start
  Future<void> initializeProfile() async {
    try {
      await ensureUserProfile();
      AppLogger.info('Profile initialization completed');
    } catch (e) {
      AppLogger.error('Profile initialization failed', e, null);
      // Don't rethrow - app should still work even if profile creation fails
    }
  }
}

// Riverpod provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// Provider to get current user profile
final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  final profileService = ref.read(profileServiceProvider);
  return profileService.getCurrentUserProfile();
});
