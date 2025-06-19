# Google Authentication Setup Guide

## Overview
This guide documents the complete setup process for Google Sign-In authentication in a Flutter app with Supabase backend, including all issues encountered and their solutions.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Google Cloud Console Setup](#google-cloud-console-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Supabase Configuration](#supabase-configuration)
5. [Flutter Dependencies](#flutter-dependencies)
6. [Environment Configuration](#environment-configuration)
7. [Code Implementation](#code-implementation)
8. [Common Issues and Solutions](#common-issues-and-solutions)
9. [Testing and Validation](#testing-and-validation)
10. [Production Deployment](#production-deployment)

## Prerequisites
- Google Cloud Console account
- Firebase project
- Supabase project
- Flutter development environment

## Google Cloud Console Setup

### 1. Create OAuth 2.0 Client ID
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project or create a new one
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**
5. Configure the consent screen if not already done
6. Select **Web application** as application type
7. Add authorized redirect URIs:
   ```
   http://localhost:8080
   http://localhost:3000
   https://your-domain.com
   https://your-supabase-project-id.supabase.co/auth/v1/callback
   ```

### 2. Enable Required APIs
1. Navigate to **APIs & Services** → **Library**
2. Enable the following APIs:
   - Google+ API
   - Google People API
   - Google Identity Services API

### 3. Configure OAuth Consent Screen
1. Go to **APIs & Services** → **OAuth consent screen**
2. Choose **External** user type
3. Fill in required information:
   - App name
   - User support email
   - Developer contact information
4. Add scopes:
   - `email`
   - `profile`
   - `openid`

## Firebase Configuration

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable Google Sign-In in **Authentication** → **Sign-in method**

### 2. Configure Web App
1. Add a web app to your Firebase project
2. Copy the configuration object
3. Download `google-services.json` for Android
4. Download `GoogleService-Info.plist` for iOS

### 3. Add Web Client ID
1. In Firebase Console, go to **Project Settings**
2. Under **General** tab, find your web app
3. Copy the **Web client ID** - this will be used in your Flutter app

## Supabase Configuration

### 1. Enable Google Provider
1. Go to your Supabase dashboard
2. Navigate to **Authentication** → **Providers**
3. Enable **Google** provider
4. Add your Google OAuth client ID and secret
5. Configure redirect URL: `https://your-project-id.supabase.co/auth/v1/callback`

### 2. Update Site URL
1. Go to **Authentication** → **Settings**
2. Set **Site URL** to your production domain
3. Add additional redirect URLs if needed

## Flutter Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.6
  google_sign_in: ^6.2.1
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  flutter_dotenv: ^5.1.0
  shared_preferences: ^2.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Environment Configuration

### 1. Create Environment Files
Create `.env.dev` and `.env.prod` files:

```env
# .env.dev
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com

# Other configuration...
OPENROUTER_API_KEY=your-openrouter-key
RAG_API_BASE_URL=your-rag-api-url
```

### 2. Update Web Index.html
Add Google Sign-In meta tag to `web/index.html`:

```html
<meta name="google-signin-client_id" content="your-web-client-id.apps.googleusercontent.com">
```

## Code Implementation

### 1. Google Auth Service
```dart
// lib/features/auth/services/google_auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/logging/app_logger.dart';

class GoogleAuthService {
  late final GoogleSignIn googleSignIn;

  GoogleAuthService() {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    final clientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    
    googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: [
        'email',
        'profile',
        'openid',
      ],
    );
    
    AppLogger.auth('Google Auth Service initialized', null, null, {
      'platform': 'web',
      'clientId': clientId,
    });
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Try silent sign-in first
      var account = await googleSignIn.signInSilently();
      
      // If no existing authentication, prompt user
      if (account == null) {
        account = await googleSignIn.signIn();
      }
      
      return account;
    } catch (error) {
      AppLogger.error('Google sign-in failed', error, null);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
  }
}
```

### 2. Auth Provider
```dart
// lib/features/auth/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../core/logging/app_logger.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    state = AsyncValue.data(SupabaseService.client.auth.currentUser);
    
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      state = AsyncValue.data(data.session?.user);
    });
  }

  Future<void> signInWithGoogle({
    required String idToken,
    required String accessToken,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      if (response.user != null) {
        state = AsyncValue.data(response.user);
        AppLogger.auth('Google sign-in successful', null, null, {
          'userId': response.user!.id,
          'email': response.user!.email,
        });
      } else {
        throw Exception('Authentication failed');
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      AppLogger.error('Google sign-in failed', error, null);
    }
  }

  Future<void> signUpWithGoogle({
    required String idToken,
    required String accessToken,
  }) async {
    // Same implementation as signInWithGoogle for OAuth
    await signInWithGoogle(idToken: idToken, accessToken: accessToken);
  }
}
```

### 3. Authentication Screens
```dart
// lib/features/auth/screens/signup_screen.dart
Future<void> _handleGoogleSignupWeb() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Try to get tokens from Google Sign-In
    var googleUser = await _googleAuthService.googleSignIn.signInSilently();
    
    if (googleUser == null) {
      googleUser = await _googleAuthService.googleSignIn.signIn();
    }

    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      
      // Check if we have idToken
      if (googleAuth.idToken == null) {
        // Use Supabase OAuth flow
        await _handleSupabaseOAuth();
        return;
      }

      // Direct authentication with tokens
      await ref.read(authProvider.notifier).signUpWithGoogle(
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      // Handle success/error states...
    }
  } catch (error) {
    // Error handling...
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

Future<void> _handleSupabaseOAuth() async {
  try {
    // Set new user flag for proper onboarding flow
    widget.onboardingService.setNewUser(true);
    
    final response = await SupabaseService.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? Uri.base.toString() : null,
    );
    
    if (response) {
      AppLogger.auth('Supabase OAuth initiated for Google sign-up');
    }
  } catch (error) {
    AppLogger.error('Supabase OAuth failed', error, null);
    throw Exception('OAuth authentication failed: $error');
  }
}
```

### 4. OAuth Callback Handling
```dart
// lib/features/landing/screens/landing_screen.dart
class LandingScreen extends ConsumerStatefulWidget {
  final OnboardingService onboardingService;
  
  const LandingScreen({
    super.key,
    required this.onboardingService,
  });

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthState();
  }

  void _handleAuthState() {
    // Listen for OAuth callback
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null && mounted) {
        AppLogger.auth('OAuth callback processed - user authenticated');
        _navigateBasedOnUserStatus();
      }
    });

    // Check existing auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.hasValue && authState.value != null) {
        _navigateBasedOnUserStatus();
      }
    });
  }

  void _navigateBasedOnUserStatus() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final isNewUser = widget.onboardingService.isNewUser;
        final hasCompletedOnboarding = widget.onboardingService.hasCompletedOnboarding;
        
        if (isNewUser && !hasCompletedOnboarding) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      }
    } catch (error) {
      AppLogger.error('Navigation error', error, null);
      context.go('/login');
    }
  }
}
```

## Common Issues and Solutions

### Issue 1: `redirect_uri_mismatch`
**Problem**: OAuth redirect URI not authorized in Google Cloud Console.

**Solution**: 
1. Add all possible redirect URIs to Google Cloud Console
2. Include Supabase callback URL: `https://your-project-id.supabase.co/auth/v1/callback`
3. Add local development URLs: `http://localhost:8080`, `http://localhost:3000`

### Issue 2: `idToken` is null on web
**Problem**: Google Identity Services SDK on web doesn't provide `idToken` with standard sign-in.

**Solution**: 
1. Implement fallback to Supabase OAuth flow
2. Use `signInSilently()` first to check for existing authentication
3. Handle both direct token authentication and OAuth redirect flows

### Issue 3: People API access denied
**Problem**: Google People API not enabled or insufficient permissions.

**Solution**:
1. Enable Google People API in Google Cloud Console
2. Add required scopes: `email`, `profile`, `openid`
3. Ensure OAuth consent screen is properly configured

### Issue 4: Authentication state not persisting
**Problem**: User authentication state lost after OAuth redirect.

**Solution**:
1. Implement proper auth state listener in landing screen
2. Use onboarding service to track new user status
3. Handle navigation based on user status and onboarding completion

### Issue 5: Web client ID configuration
**Problem**: Incorrect or missing web client ID configuration.

**Solution**:
1. Use the correct web client ID from Firebase/Google Cloud Console
2. Add meta tag to `web/index.html`
3. Configure client ID in environment variables

## Testing and Validation

### 1. Development Testing
```bash
# Run in debug mode
flutter run -d chrome --web-port 8080

# Test OAuth flow
# 1. Navigate to signup page
# 2. Click "Sign up with Google"
# 3. Complete OAuth flow
# 4. Verify navigation to onboarding
```

### 2. Verify Authentication
```dart
// Check authentication state
final user = SupabaseService.client.auth.currentUser;
print('User authenticated: ${user != null}');
print('User ID: ${user?.id}');
print('User email: ${user?.email}');
```

### 3. Database Verification
```sql
-- Check users table in Supabase
SELECT id, email, created_at, raw_app_meta_data 
FROM auth.users 
WHERE raw_app_meta_data->>'provider' = 'google';
```

## Production Deployment

### 1. Environment Setup
1. Create production environment file (`.env.prod`)
2. Update Supabase project settings with production URLs
3. Configure Google Cloud Console with production domains

### 2. Domain Configuration
1. Add production domain to Google Cloud Console authorized origins
2. Update Supabase site URL to production domain
3. Configure proper CORS settings

### 3. Security Considerations
1. Use environment variables for sensitive data
2. Implement proper error handling and logging
3. Set up monitoring for authentication failures
4. Regular security audits of OAuth configuration

### 4. Deployment Checklist
- [ ] Production environment variables configured
- [ ] Google Cloud Console updated with production URLs
- [ ] Supabase settings updated for production
- [ ] OAuth consent screen approved for production use
- [ ] Error logging and monitoring configured
- [ ] Authentication flow tested in production environment

## Troubleshooting Commands

### Check Supabase Connection
```bash
# Test Supabase connection
curl -H "apikey: YOUR_ANON_KEY" \
     -H "Authorization: Bearer YOUR_ANON_KEY" \
     https://your-project-id.supabase.co/rest/v1/
```

### Verify Google OAuth Configuration
```bash
# Test OAuth endpoint
curl "https://accounts.google.com/.well-known/openid_configuration"
```

### Debug Authentication State
```dart
// Add to your app for debugging
SupabaseService.client.auth.onAuthStateChange.listen((data) {
  print('Auth state changed: ${data.event}');
  print('Session: ${data.session?.user?.email}');
});
```

## Conclusion

This guide provides a complete setup process for Google authentication in Flutter with Supabase. The key to success is proper configuration across all platforms (Google Cloud Console, Firebase, Supabase) and handling the differences between direct token authentication and OAuth redirect flows, especially for web platforms.

For production use, ensure all security best practices are followed and thoroughly test the authentication flow across all target platforms and environments. 