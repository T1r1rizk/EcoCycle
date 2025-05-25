// ignore: unused_import
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Getter methods to retrieve values from environment variables with fallbacks
  static String get url => dotenv.env['SUPABASE_URL'] ?? 'your.url.here';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'your.api.key.here';

  // Static fields for use with loadConfig
  static late String baseUrl;
  static late String baseAnonKey;

  static Future<void> loadConfig(String environment) async {
    // Load different configurations based on environment
    if (environment == 'prod') {
      baseUrl = 'your.url.here';
      baseAnonKey = 'your.api.key.here';
    }
   }
  }