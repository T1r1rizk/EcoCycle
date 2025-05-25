import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInit {
  static Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: 'https://kjwlbecbenkclllegqqp.supabase.co',  // Your Supabase project URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtqd2xiZWNiZW5rY2xsbGVncXFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwNjY4MzEsImV4cCI6MjA1OTY0MjgzMX0.gfdIwJ4DMQQEttqQa84v0FsAGoNcBNQpUU5nWiS8WZw',  // Your Supabase anon/public key
      debug: true,  // Only for development
    );
  }
  
  // Access the client instance anywhere in your app after initialization
  static SupabaseClient get client => Supabase.instance.client;
}