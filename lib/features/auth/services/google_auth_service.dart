import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/logging/app_logger.dart';

class GoogleAuthService {
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    AppLogger.auth('Initializing Google Auth Service', null, null, {
      'platform': kIsWeb ? 'web' : 'mobile',
      'clientId':
          kIsWeb ? AppConfig.googleWebClientId : 'from_google_services_json'
    });

    // For web, we need to specify the client ID and use proper scopes
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? AppConfig.googleWebClientId : null,
      scopes: [
        'openid', // CRITICAL: This is required for idToken on web
        'email',
        'profile',
      ],
    );
  }

  /// Sign in with Google - for web, this will use signInSilently first
  Future<GoogleSignInAccount?> signIn() async {
    AppLogger.auth('Attempting Google sign in');

    try {
      GoogleSignInAccount? account;

      if (kIsWeb) {
        // On web, try signInSilently first (this provides idToken)
        account = await _googleSignIn.signInSilently();

        // If silent sign-in fails, fall back to regular signIn
        if (account == null) {
          AppLogger.auth('Silent sign-in failed, attempting regular sign-in');
          account = await _googleSignIn.signIn();
        }
      } else {
        // On mobile, use regular signIn
        account = await _googleSignIn.signIn();
      }

      if (account != null) {
        // Validate that we have the required tokens for Supabase
        final auth = await account.authentication;

        AppLogger.auth('Google sign in successful', null, null, {
          'userId': account.id,
          'email': account.email,
          'displayName': account.displayName,
          'hasIdToken': auth.idToken != null,
          'hasAccessToken': auth.accessToken != null,
          'platform': kIsWeb ? 'web' : 'mobile',
        });

        // Log a warning if idToken is missing (critical for Supabase)
        if (auth.idToken == null) {
          AppLogger.auth(
              'WARNING: idToken is null - this will cause Supabase authentication to fail');
        }
      } else {
        AppLogger.auth('Google sign in cancelled by user');
      }

      return account;
    } catch (error, stackTrace) {
      AppLogger.error('Error signing in with Google', error, stackTrace,
          {'feature': 'auth', 'action': 'google_sign_in'});
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    AppLogger.auth('Attempting Google sign out');

    try {
      await _googleSignIn.signOut();
      AppLogger.auth('Google sign out successful');
    } catch (error, stackTrace) {
      AppLogger.error('Error signing out from Google', error, stackTrace,
          {'feature': 'auth', 'action': 'google_sign_out'});
    }
  }

  /// Get current signed in user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Listen to authentication state changes
  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  /// Get the GoogleSignIn instance (needed for web button)
  GoogleSignIn get googleSignIn => _googleSignIn;
}
