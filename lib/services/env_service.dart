import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'dev';

  // RAG API Configuration
  static String get oldRagApiBaseUrl =>
      dotenv.env['OLD_RAG_API_BASE_URL'] ??
      'https://cardsense-ai.vercel.app/api/query';
  static String get newRagApiBaseUrl =>
      dotenv.env['NEW_RAG_API_BASE_URL'] ??
      'https://card-sense-ai-rag.vercel.app/chat';
  static bool get useNewRagApi =>
      dotenv.env['USE_NEW_RAG_API']?.toLowerCase() == 'true';
  static String get selectedRagApiBaseUrl =>
      useNewRagApi ? newRagApiBaseUrl : oldRagApiBaseUrl;

  static Future<void> loadEnv({bool isProd = false}) async {
    final envFile = isProd ? '.env.prod' : '.env.dev';
    await dotenv.load(fileName: envFile);
  }

  static bool get isDev => environment == 'dev';
  static bool get isProd => environment == 'prod';
}
