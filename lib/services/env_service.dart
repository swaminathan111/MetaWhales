import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'dev';

  static Future<void> loadEnv({bool isProd = false}) async {
    final envFile = isProd ? '.env.prod' : '.env.dev';
    await dotenv.load(fileName: envFile);
  }

  static bool get isDev => environment == 'dev';
  static bool get isProd => environment == 'prod';
}
