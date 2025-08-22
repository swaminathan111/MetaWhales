import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Navigate to landing screen after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardSenseTheme.colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Card icon with dots
                  Row(
                    children: [
                      // Card icon
                      Image.asset(
                        'assets/icons/cardsense_icon_white.png',
                        width: 50,
                        height: 50,
                      ),
                       const SizedBox(width: 12),
                      // Vertical line
                      Container(
                        width: 1,
                        height: 40,
                        color: cardSenseTheme.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // CardSense AI text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'CardSense',
                            style: cardSenseTheme.textTheme.headlineLarge?.copyWith(
                              color: cardSenseTheme.colorScheme.onPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'AI',
                            style: cardSenseTheme.textTheme.headlineLarge?.copyWith(
                              color: cardSenseTheme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Intelligence Meets Money',
                        style: cardSenseTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: cardSenseTheme.colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
