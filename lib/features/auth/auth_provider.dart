import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import 'services/profile_service.dart';
import '../../core/logging/app_logger.dart';

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
      final event = data.event;

      AppLogger.info('Auth state change detected', null, null, {
        'event': event.toString(),
        'hasUser': user != null,
        'userId': user?.id,
        'email': user?.email,
      });

      // If user signed in, ensure profile exists
      if (user != null) {
        try {
          await _profileService.ensureUserProfile();
          AppLogger.info(
              'User profile ensured after auth state change', null, null, {
            'userId': user.id,
          });
        } catch (e) {
          // Log but don't fail auth - profile can be created later
          AppLogger.warning('Profile creation failed during auth', null, null, {
            'error': e.toString(),
            'userId': user.id,
          });
        }
      }

      state = AsyncValue.data(user);
    });

    // Set initial state and ensure profile exists for current user
    final currentUser = SupabaseService.currentUser;
    state = AsyncValue.data(currentUser);

    AppLogger.info('Auth provider initialized', null, null, {
      'hasCurrentUser': currentUser != null,
      'userId': currentUser?.id,
    });

    // Ensure profile exists for current user on app start
    if (currentUser != null) {
      _profileService.initializeProfile();
    }
  }

  Future<void> signIn(String email, String password) async {
    AppLogger.info('Starting email sign in', null, null, {
      'email': email,
    });

    state = const AsyncValue.loading();

    try {
      final response = await SupabaseService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        AppLogger.info('Email sign in successful', null, null, {
          'userId': response.user!.id,
          'email': response.user!.email,
        });

        // Ensure profile exists after successful sign in
        try {
          await _profileService.ensureUserProfile();
        } catch (e) {
          AppLogger.warning(
              'Profile creation failed after sign in', null, null, {
            'error': e.toString(),
            'userId': response.user!.id,
          });
        }
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Login failed');
      }
    } catch (error, stackTrace) {
      AppLogger.error('Email sign in failed', error, stackTrace);
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

  Future<void> signInWithGoogle({
    required String idToken,
    required String accessToken,
    String? photoUrl,
    String? displayName,
  }) async {
    AppLogger.info('Starting Google sign in', null, null, {
      'hasIdToken': idToken.isNotEmpty,
      'hasAccessToken': accessToken.isNotEmpty,
      'hasPhotoUrl': photoUrl != null,
      'hasDisplayName': displayName != null,
    });

    state = const AsyncValue.loading();

    try {
      // Validate that we have both required tokens
      if (idToken.isEmpty) {
        throw Exception(
            'ID Token is required for Google authentication but was not provided. This is a common issue on web - please try using a different browser or clearing your browser cache.');
      }

      if (accessToken.isEmpty) {
        throw Exception(
            'Access Token is required for Google authentication but was not provided.');
      }

      final response = await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        AppLogger.info('Google sign in successful', null, null, {
          'userId': response.user!.id,
          'email': response.user!.email,
          'photoUrl': photoUrl,
          'displayName': displayName,
        });

        // Ensure profile exists after successful Google sign in
        try {
          await _profileService.ensureUserProfile(
            googlePhotoUrl: photoUrl,
            googleDisplayName: displayName,
          );
        } catch (e) {
          AppLogger.warning(
              'Profile creation failed after Google sign in', null, null, {
            'error': e.toString(),
            'userId': response.user!.id,
          });
        }
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Google sign in failed - no user returned');
      }
    } catch (error, stackTrace) {
      AppLogger.error('Google sign in failed', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signUpWithGoogle({
    required String idToken,
    required String accessToken,
    String? photoUrl,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Validate that we have both required tokens
      if (idToken.isEmpty) {
        throw Exception(
            'ID Token is required for Google authentication but was not provided. This is a common issue on web - please try using a different browser or clearing your browser cache.');
      }

      if (accessToken.isEmpty) {
        throw Exception(
            'Access Token is required for Google authentication but was not provided.');
      }

      final response = await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        // Ensure profile exists after successful Google sign up
        try {
          await _profileService.ensureUserProfile(
            googlePhotoUrl: photoUrl,
            googleDisplayName: displayName,
          );
        } catch (e) {
          AppLogger.warning(
              'Profile creation failed after Google sign up', null, null, {
            'error': e.toString(),
            'userId': response.user!.id,
          });
        }
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Google sign up failed - no user returned');
      }
    } catch (error, stackTrace) {
      print('Google sign up error: $error');
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
