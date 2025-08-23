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
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final OnboardingService onboardingService;

  const LoginScreen({
    super.key,
    required this.onboardingService,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void initState() {
    super.initState();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    // ESSENTIAL: Listen for OAuth callback authentication (primary fix for your issue)
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null && mounted) {
        AppLogger.info(
            'OAuth callback detected on login screen - user authenticated',
            null,
            null, {
          'userId': data.session!.user.id,
          'email': data.session!.user.email,
        });
        widget.onboardingService.setNewUser(false);
        if (mounted) {
          context.go('/home');
        }
      }
    });

    // Check current auth state - if user is already authenticated, redirect immediately
    // Note: Router guards also handle this, but this provides immediate feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentAuthState = ref.read(authProvider);
      if (currentAuthState.hasValue && currentAuthState.value != null) {
        AppLogger.info(
            'User already authenticated on login screen load', null, null, {
          'userId': currentAuthState.value!.id,
          'email': currentAuthState.value!.email,
        });
        widget.onboardingService.setNewUser(false);
        if (mounted) {
          context.go('/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Social Login Button Builder
  Widget _buildSocialLoginButton({
    required VoidCallback? onPressed,
    required String icon,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: TextButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            _getIconForProvider(label),
            color: Colors.white,
            size: 16,
          ),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  IconData _getIconForProvider(String label) {
    if (label.contains('Google')) return Icons.g_mobiledata;
    if (label.contains('Instagram')) return Icons.camera_alt;
    if (label.contains('Facebook')) return Icons.facebook;
    return Icons.login;
  }

  // Placeholder methods for Instagram and Facebook login
  Future<void> _handleInstagramLogin() async {
    // TODO: Implement Instagram login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Instagram login coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _handleFacebookLogin() async {
    // TODO: Implement Facebook login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facebook login coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleUser = await _googleAuthService.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        // Debug logging to see what tokens we have
        print(
            'Google auth tokens - idToken: ${googleAuth.idToken != null}, accessToken: ${googleAuth.accessToken != null}');

        // Add detailed logging for debugging
        AppLogger.info('Preparing to call signInWithGoogle', null, null, {
          'idToken': googleAuth.idToken ?? 'null',
          'accessToken': googleAuth.accessToken ?? 'null',
          'idTokenLength': googleAuth.idToken?.length ?? 0,
          'accessTokenLength': googleAuth.accessToken?.length ?? 0,
          'photoUrl': googleUser.photoUrl,
          'displayName': googleUser.displayName,
        });

        // Check if we have the required tokens for direct authentication
        if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
          AppLogger.warning(
              'ID Token is null or empty, falling back to Supabase OAuth',
              null,
              null, {
            'platform': kIsWeb ? 'web' : 'mobile',
            'hasAccessToken': googleAuth.accessToken != null,
          });

          // Use Supabase's built-in OAuth flow instead
          await _handleSupabaseOAuth();
          return;
        }

        // For web, idToken might be null, but we can still authenticate with accessToken
        // Supabase can work with just accessToken for Google OAuth
        if (googleAuth.accessToken == null) {
          throw Exception('Failed to get access token from Google');
        }

        await ref.read(authProvider.notifier).signInWithGoogle(
              idToken: googleAuth.idToken!, // Now we know it's not null
              accessToken: googleAuth.accessToken!,
              photoUrl: googleUser.photoUrl,
              displayName: googleUser.displayName,
            );

        // OAuth callback listener will handle navigation on successful login
        // Just check for immediate errors
        final authState = ref.read(authProvider);
        if (authState.hasError) {
          AppLogger.error('Google login failed with auth state error',
              authState.error, null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Google login failed: ${authState.error}'),
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
      String errorMessage = 'Google login failed';

      if (error.toString().contains('popup_closed_by_user')) {
        errorMessage = 'Sign-in was cancelled';
      } else if (error.toString().contains('access_denied')) {
        errorMessage = 'Access denied. Please try again.';
      } else if (error.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Google login failed: $error';
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

  Future<void> _handleGoogleLoginWeb() async {
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
        await ref.read(authProvider.notifier).signInWithGoogle(
              idToken: googleAuth.idToken!,
              accessToken: googleAuth.accessToken!,
            );

        final authState = ref.read(authProvider);

        if (authState.hasValue && authState.value != null) {
          if (mounted) {
            context.go('/home');
          }
        } else if (authState.hasError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Google login failed: ${authState.error}'),
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
      String errorMessage = 'Google login failed';

      if (error.toString().contains('popup_closed_by_user')) {
        errorMessage = 'Sign-in was cancelled';
      } else if (error.toString().contains('access_denied')) {
        errorMessage = 'Access denied. Please try again.';
      } else if (error.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Google login failed: $error';
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
      AppLogger.info(
          'Starting Supabase OAuth flow for Google login', null, null, {
        'platform': kIsWeb ? 'web' : 'mobile',
        'redirectUrl': kIsWeb ? Uri.base.toString() : 'null',
      });

      // Use Supabase's built-in OAuth for web when idToken is not available
      final response = await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.toString() : null,
      );

      if (response) {
        // OAuth initiated successfully, user will be redirected
        AppLogger.auth(
            'Supabase OAuth initiated for Google login', null, null, {
          'success': true,
          'platform': kIsWeb ? 'web' : 'mobile',
        });

        // Show success message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirecting to Google for authentication...'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // For login, we don't set up a listener here since the app will restart
        // Instead, we'll handle this in the main app's auth state management
      } else {
        throw Exception('OAuth initiation failed - no response received');
      }
    } catch (error) {
      AppLogger.error('Supabase OAuth failed', error, null, {
        'platform': kIsWeb ? 'web' : 'mobile',
        'errorType': error.runtimeType.toString(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OAuth authentication failed: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      throw Exception('OAuth authentication failed: $error');
    }
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // Auth state changes will trigger navigation via router guards or auth listeners
      // Just check for immediate errors
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        AppLogger.error(
            'Email login failed with auth state error', authState.error, null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${authState.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $error'),
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
      return 'Please enter your password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardSenseTheme.colorScheme.primary,
              cardSenseTheme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with CardSense AI branding
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // CardSense AI Logo and Text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo at center
                        CircleAvatar(
                          radius: 35, // outer circle size
                          backgroundColor: Colors.white, // background color
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/cta_agent_circle.png',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // CardSense AI text centered below logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'CardSense',
                              style: cardSenseTheme.textTheme.headlineLarge?.copyWith(
                                color: cardSenseTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI',
                              style: cardSenseTheme.textTheme.headlineLarge?.copyWith(
                                color: cardSenseTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Tagline centered below CardSense AI
                        Text(
                          'Intelligence Meets Money',
                          style: cardSenseTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: cardSenseTheme.colorScheme.onPrimary.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // // Welcome text
                    // Text(
                    //   'Welcome Back',
                    //   style: cardSenseTheme.textTheme.headlineLarge?.copyWith(
                    //     color: cardSenseTheme.colorScheme.onPrimary,
                    //     fontWeight: FontWeight.w600,
                    //     fontSize: 24,
                    //   ),
                    // ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your smart money journey',
                      style: cardSenseTheme.textTheme.bodyLarge?.copyWith(
                        color: cardSenseTheme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Login Form Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            
                            // Social Login Buttons
                            _buildSocialLoginButton(
                              onPressed: kIsWeb ? _handleGoogleLoginWeb : _handleGoogleLogin,
                              icon: 'assets/icons/google.svg',
                              label: 'Continue with Google',
                              color: const Color(0xFF4285F4),
                            ),
                            const SizedBox(height: 12),
                            _buildSocialLoginButton(
                              onPressed: _handleInstagramLogin,
                              icon: 'assets/icons/instagram.svg',
                              label: 'Continue with Instagram',
                              color: const Color(0xFFE4405F),
                            ),
                            const SizedBox(height: 12),
                            _buildSocialLoginButton(
                              onPressed: _handleFacebookLogin,
                              icon: 'assets/icons/facebook.svg',
                              label: 'Continue with Facebook',
                              color: const Color(0xFF1877F2),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Email Field
                            Text(
                              'Email',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Password Field
                            Text(
                              'Password',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: _validatePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        // TODO: Implement forgot password
                                      },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Login Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.primaryColor,
                                    theme.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleEmailLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading ? null : () => context.go('/signup'),
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
