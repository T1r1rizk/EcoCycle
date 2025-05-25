import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const String baseUrl = 'http://your-api-url/api';
  static String? _token;

  get authStateChanges => null;

  Future<User?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      _token = response.headers['authorization'];
      return user;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<User?> register({
    required String username,
    required String password,
    String? location,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'location': location,
      }),
    );

    if (response.statusCode == 201) {
      final user = User.fromJson(jsonDecode(response.body));
      _token = response.headers['authorization'];
      return user;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      _token = null;
    } else {
      throw Exception('Failed to logout');
    }
  }

  Future<User?> getCurrentUser() async {
    if (_token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw Exception('Failed to get current user');
    }
  }
}