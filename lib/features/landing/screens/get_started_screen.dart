import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Cards Illustration
            SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: Image.asset(
                      'lib/features/landing/assets/images/landing.png',
                      width: 320,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Title
            const Text(
              'CardSense AI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF23235B),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'One stop solution to all your payment\nrealted problems',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB6B6B6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Spacer(),
            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement navigation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F75F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
