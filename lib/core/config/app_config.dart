import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> load({String environment = 'dev'}) async {
    final fileName = '.env.$environment';
    await dotenv.load(fileName: fileName);
  }

  // Environment
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'dev';

  // Google Authentication
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Logging Configuration
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'INFO';

  static bool get logToConsole =>
      dotenv.env['LOG_TO_CONSOLE']?.toLowerCase() == 'true';

  static bool get logToFile =>
      dotenv.env['LOG_TO_FILE']?.toLowerCase() == 'true';

  // Validation
  static bool get isConfigured =>
      googleWebClientId.isNotEmpty &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  static bool get isGoogleAuthConfigured => googleWebClientId.isNotEmpty;
}
