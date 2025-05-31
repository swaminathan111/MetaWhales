import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/onboarding_service.dart';
import 'utils/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingService = OnboardingService(prefs);

  runApp(MyApp(onboardingService: onboardingService));
}

class MyApp extends StatelessWidget {
  final OnboardingService onboardingService;

  const MyApp({
    super.key,
    required this.onboardingService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CardSense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.getRouter(onboardingService),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome to CardSense!'),
      ),
    );
  }
}
