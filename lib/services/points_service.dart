import 'package:supabase_flutter/supabase_flutter.dart';

class PointsService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get current user points from `users` table
  Future<int> getCurrentPoints() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in.');

    final response = await _client
        .from('users')
        .select('points')
        .eq('id', userId)
        .single();

    return response['points'] ?? 0;
  }

  /// Add points to the current user in the `users` table
  Future<void> addPoints(int pointsToAdd) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in.');

    final currentPoints = await getCurrentPoints();
    final newPoints = currentPoints + pointsToAdd;

    final response = await _client
        .from('users')
        .update({'points': newPoints})
        .eq('id', userId);

    if (response.error != null) {
      throw Exception('Failed to update points: ${response.error!.message}');
    }
  }

  /// Create a pickup request in the `pickups` table
  Future<void> createPickupRequest(Map<String, dynamic> data) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in.');

    final request = {
      ...data,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _client.from('pickups').insert(request);

    if (response.error != null) {
      throw Exception('Failed to create pickup request: ${response.error!.message}');
    }
  }
}
