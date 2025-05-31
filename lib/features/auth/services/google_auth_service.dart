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

    // For web, we need to specify the client ID
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? AppConfig.googleWebClientId : null,
      scopes: [
        'email',
        'profile',
      ],
    );
  }

  /// Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    AppLogger.auth('Attempting Google sign in');

    try {
      final account = await _googleSignIn.signIn();

      if (account != null) {
        AppLogger.auth('Google sign in successful', null, null, {
          'userId': account.id,
          'email': account.email,
          'displayName': account.displayName
        });
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
}
