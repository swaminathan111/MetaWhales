import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../../services/onboarding_service.dart';
import '../auth_provider.dart';
import '../services/google_auth_service.dart';
import '../../../core/logging/app_logger.dart';
import '../../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import for web-specific Google Sign-In button
import 'package:google_sign_in_web/google_sign_in_web.dart'
    if (dart.library.io) 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final OnboardingService onboardingService;

  const SignupScreen({
    super.key,
    required this.onboardingService,
  });

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleUser = await _googleAuthService.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        // Debug logging to see what tokens we have
        AppLogger.auth('Google authentication tokens received', null, null, {
          'hasIdToken': googleAuth.idToken != null,
          'hasAccessToken': googleAuth.accessToken != null,
          'idTokenLength': googleAuth.idToken?.length ?? 0,
          'accessTokenLength': googleAuth.accessToken?.length ?? 0,
        });

        // For web, idToken might be null, but we can still authenticate with accessToken
        // Supabase can work with just accessToken for Google OAuth
        if (googleAuth.accessToken == null) {
          throw Exception('Failed to get access token from Google');
        }

        await ref.read(authProvider.notifier).signUpWithGoogle(
              idToken: googleAuth.idToken ?? '', // Provide empty string if null
              accessToken: googleAuth.accessToken!,
            );

        final authState = ref.read(authProvider);

        if (authState.hasValue && authState.value != null) {
          widget.onboardingService.setNewUser(true);
          if (mounted) {
            context.go('/onboarding');
          }
        } else if (authState.hasError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Google signup failed: ${authState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // User cancelled the sign-in
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google sign-in was cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (error) {
      String errorMessage = 'Google signup failed';

      if (error.toString().contains('popup_closed_by_user')) {
        errorMessage = 'Sign-in was cancelled';
      } else if (error.toString().contains('access_denied')) {
        errorMessage = 'Access denied. Please try again.';
      } else if (error.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Google signup failed: $error';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // Check if signup was successful
      final authState = ref.read(authProvider);

      if (authState.hasValue && authState.value != null) {
        widget.onboardingService.setNewUser(true);
        if (mounted) {
          context.go('/onboarding');
        }
      } else if (authState.hasError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup failed: ${authState.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignupWeb() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For web, we need to use a different approach to get idToken
      // First, try to sign in silently to get existing authentication
      var googleUser = await _googleAuthService.googleSignIn.signInSilently();

      // If no existing authentication, prompt user to sign in
      if (googleUser == null) {
        googleUser = await _googleAuthService.googleSignIn.signIn();
      }

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        // Log what we received
        AppLogger.auth(
            'Web Google authentication tokens received', null, null, {
          'hasIdToken': googleAuth.idToken != null,
          'hasAccessToken': googleAuth.accessToken != null,
          'idTokenLength': googleAuth.idToken?.length ?? 0,
          'accessTokenLength': googleAuth.accessToken?.length ?? 0,
        });

        // For web, if we still don't have idToken, we need to use Supabase's OAuth flow
        if (googleAuth.idToken == null) {
          // Use Supabase's built-in OAuth instead of trying to get idToken
          await _handleSupabaseOAuth();
          return;
        }

        // If we have both tokens, proceed with normal flow
        await ref.read(authProvider.notifier).signUpWithGoogle(
              idToken: googleAuth.idToken!,
              accessToken: googleAuth.accessToken!,
            );

        final authState = ref.read(authProvider);

        if (authState.hasValue && authState.value != null) {
          widget.onboardingService.setNewUser(true);
          if (mounted) {
            context.go('/onboarding');
          }
        } else if (authState.hasError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Google signup failed: ${authState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // User cancelled the sign-in
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google sign-in was cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (error) {
      String errorMessage = 'Google signup failed';

      if (error.toString().contains('popup_closed_by_user')) {
        errorMessage = 'Sign-in was cancelled';
      } else if (error.toString().contains('access_denied')) {
        errorMessage = 'Access denied. Please try again.';
      } else if (error.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Google signup failed: $error';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSupabaseOAuth() async {
    try {
      // Set new user flag before OAuth since the app will restart
      widget.onboardingService.setNewUser(true);

      // Use Supabase's built-in OAuth for web when idToken is not available
      final response = await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.toString() : null,
      );

      if (response) {
        // OAuth initiated successfully, user will be redirected
        AppLogger.auth(
            'Supabase OAuth initiated for Google sign-up - new user flag set');

        // For signup, we don't set up a listener here since the app will restart
        // Instead, we'll handle this in the main app's auth state management
      }
    } catch (error) {
      AppLogger.error('Supabase OAuth failed', error, null);
      throw Exception('OAuth authentication failed: $error');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                // Use web-specific Google Sign-In approach for proper idToken support
                kIsWeb
                    ? Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : TextButton.icon(
                                  onPressed: _handleGoogleSignupWeb,
                                  icon: SvgPicture.asset(
                                    'lib/features/auth/assets/icons/google.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                  label: const Text('Continue with Google'),
                                ),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignup,
                        icon: SvgPicture.asset(
                          'lib/features/auth/assets/icons/google.svg',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'or',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Text.rich(
                  TextSpan(
                    text: 'By signing up, you agree to our ',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go('/login'),
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
