import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInit {
  static Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: 'your url',  // Your project URL
      anonKey: 'your key',  // Your anon/public key
      debug: true,  // Only for development
    );
  }
  
  // Access the client instance anywhere in your app after initialization
  static SupabaseClient get client => Supabase.instance.client;
}
