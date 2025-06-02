import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import 'services/profile_service.dart';

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final ProfileService _profileService = ProfileService();

  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    SupabaseService.client.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user;

      // If user signed in, ensure profile exists
      if (user != null) {
        try {
          await _profileService.ensureUserProfile();
        } catch (e) {
          // Log but don't fail auth - profile can be created later
          print('Profile creation failed during auth: $e');
        }
      }

      state = AsyncValue.data(user);
    });

    // Set initial state and ensure profile exists for current user
    final currentUser = SupabaseService.currentUser;
    state = AsyncValue.data(currentUser);

    // Ensure profile exists for current user on app start
    if (currentUser != null) {
      _profileService.initializeProfile();
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final response = await SupabaseService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Ensure profile exists after successful sign in
        try {
          await _profileService.ensureUserProfile();
        } catch (e) {
          print('Profile creation failed after sign in: $e');
        }
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Login failed');
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final response = await SupabaseService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Ensure profile exists after successful sign up
        try {
          await _profileService.ensureUserProfile();
        } catch (e) {
          print('Profile creation failed after sign up: $e');
        }
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Sign up failed');
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Auth provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.asData?.value != null;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.asData?.value;
});
