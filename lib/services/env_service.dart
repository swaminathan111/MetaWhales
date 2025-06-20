import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'dev';

  // RAG API Configuration - Now fully environment-driven
  static String get oldRagApiBaseUrl {
    final url = dotenv.env['OLD_RAG_API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
          'OLD_RAG_API_BASE_URL environment variable is required but not set');
    }
    return url;
  }

  static String get newRagApiBaseUrl {
    final url = dotenv.env['NEW_RAG_API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
          'NEW_RAG_API_BASE_URL environment variable is required but not set');
    }
    return url;
  }

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
