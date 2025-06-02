import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  /// Ensure user profile exists, create if missing
  Future<void> ensureUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _logger.w('No authenticated user found');
        return;
      }

      _logger.d('Checking profile for user: ${user.id}');

      // Check if profile already exists
      final existingProfile = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile != null) {
        _logger.d('User profile already exists');
        return;
      }

      // Create new user profile
      _logger.i('Creating new user profile for: ${user.id}');

      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'User',
        'avatar_url': user.userMetadata?['avatar_url'],
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

      _logger.i('User profile created successfully for: ${user.id}');
    } catch (e) {
      _logger.e('Failed to ensure user profile: $e');

      // If it's a unique constraint violation, the profile might already exist
      if (e.toString().contains('duplicate key') ||
          e.toString().contains('unique constraint')) {
        _logger.i('Profile already exists (unique constraint), continuing...');
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
      _logger.e('Failed to get user profile: $e');
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

      _logger.i('User profile updated successfully');
    } catch (e) {
      _logger.e('Failed to update user profile: $e');
      rethrow;
    }
  }

  /// Delete user profile (for account deletion)
  Future<void> deleteUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _supabase.from('user_profiles').delete().eq('id', user.id);

      _logger.i('User profile deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete user profile: $e');
      rethrow;
    }
  }

  /// Initialize profile on app start
  Future<void> initializeProfile() async {
    try {
      await ensureUserProfile();
      _logger.i('Profile initialization completed');
    } catch (e) {
      _logger.e('Profile initialization failed: $e');
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
