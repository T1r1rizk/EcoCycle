// ignore: unused_import
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Getter methods to retrieve values from environment variables with fallbacks
  static String get url => dotenv.env['SUPABASE_URL'] ?? 'https://kjwlbecbenkclllegqqp.supabase.co';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtqd2xiZWNiZW5rY2xsbGVncXFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwNjY4MzEsImV4cCI6MjA1OTY0MjgzMX0.gfdIwJ4DMQQEttqQa84v0FsAGoNcBNQpUU5nWiS8WZw';

  // Static fields for use with loadConfig
  static late String baseUrl;
  static late String baseAnonKey;

  static Future<void> loadConfig(String environment) async {
    // Load different configurations based on environment
    if (environment == 'prod') {
      baseUrl = 'https://kjwlbecbenkclllegqqp.supabase.co';
      baseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtqd2xiZWNiZW5rY2xsbGVncXFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwNjY4MzEsImV4cCI6MjA1OTY0MjgzMX0.gfdIwJ4DMQQEttqQa84v0FsAGoNcBNQpUU5nWiS8WZw';
    }
   }
  }