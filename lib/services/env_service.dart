import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'dev';

  // RAG API Configuration
  static String get ragApiBaseUrl {
    final url = dotenv.env['RAG_API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
          'RAG_API_BASE_URL environment variable is required but not set');
    }
    return url;
  }

  // For backward compatibility, keep the selectedRagApiBaseUrl getter
  static String get selectedRagApiBaseUrl => ragApiBaseUrl;

  static Future<void> loadEnv({bool isProd = false}) async {
    final envFile = isProd ? '.env.prod' : '.env.dev';
    await dotenv.load(fileName: envFile);
  }

  static bool get isDev => environment == 'dev';
  static bool get isProd => environment == 'prod';
}
