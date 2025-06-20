import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/onboarding_service.dart';
import 'services/supabase_service.dart';
import 'services/env_service.dart';
import 'utils/app_router.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration
  // You can change this to 'prod' for production builds
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  await AppConfig.load(environment: environment);

  // Load environment variables
  await EnvService.loadEnv(isProd: environment == 'prod');

  // Debug environment loading
  print('DEBUG: Environment loaded: $environment');
  print('DEBUG: Loading .env.${environment == 'prod' ? 'prod' : 'dev'}');
  print(
      'DEBUG: OPENROUTER_API_KEY present: ${dotenv.env.containsKey('OPENROUTER_API_KEY')}');

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize logging
  await AppLogger.initialize();

  AppLogger.info('Application starting', null, null,
      {'environment': environment, 'version': '1.0.0+1'});

  final prefs = await SharedPreferences.getInstance();
  final onboardingService = OnboardingService(prefs);

  runApp(
    ProviderScope(
      child: MyApp(onboardingService: onboardingService),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final OnboardingService onboardingService;

  const MyApp({
    super.key,
    required this.onboardingService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CardSense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.getRouter(onboardingService, ref),
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
