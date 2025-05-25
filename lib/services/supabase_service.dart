import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // User Management
  static Future<User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }

  static Future<String?> getCurrentUserId() async {
    return _client.auth.currentUser?.id;
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    
    return response;
  }

  static Future<void> updateUserProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
    String? profilePicture,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('users').upsert({
      'id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phoneNumber,
      'address': address,
      'profile_picture': profilePicture,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Points Management
  static Future<int> getTotalPoints() async {
    final user = await getUserProfile();
    return user?['total_points'] ?? 0;
  }

  static Future<void> addPoints(int points) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get current points
    final user = await getUserProfile();
    final currentPoints = user?['total_points'] ?? 0;
    final totalItems = user?['total_items_recycled'] ?? 0;

    // Update user points
    await _client.from('users').update({
      'total_points': currentPoints + points,
      'total_items_recycled': totalItems + 1,
    }).eq('id', userId);
  }

  // QR Code Scanning
  static Future<void> recordScan(String qrCodeId, int pointsEarned) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('scans').insert({
      'user_id': userId,
      'qr_code_id': qrCodeId,
      'scanned_at': DateTime.now().toIso8601String(),
      'points_earned': pointsEarned,
    });

    // Add points to user
    await addPoints(pointsEarned);
  }

  // Offers and Redemptions
  static Future<List<Map<String, dynamic>>> getOffers() async {
    final response = await _client
        .from('offers')
        .select('*, partners:partner_id(*)')
        .eq('is_active', true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> getOfferDetails(String offerId) async {
    final response = await _client
        .from('offers')
        .select('*, partners:partner_id(*)')
        .eq('id', offerId)
        .single();
    
    return response;
  }

  static Future<void> redeemOffer(String offerId) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get offer details
    final offer = await getOfferDetails(offerId);
    final pointsRequired = offer['points_required'] ?? 0;

    // Check if user has enough points
    final userPoints = await getTotalPoints();
    if (userPoints < pointsRequired) {
      throw Exception('Not enough points to redeem this offer');
    }

    // Record redemption
    await _client.from('redemptions').insert({
      'user_id': userId,
      'offer_id': offerId,
      'redeemed_at': DateTime.now().toIso8601String(),
    });

    // Deduct points from user
    await _client.from('users').update({
      'total_points': userPoints - pointsRequired,
    }).eq('id', userId);
  }

  // Pickup Requests
  static Future<void> requestPickup(LatLng location) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Since we're using PostGIS, create a point in WKT format
    String pointWKT = 'POINT(${location.longitude} ${location.latitude})';

    await _client.from('pickup_requests').insert({
      'user_id': userId,
      'location': pointWKT,
      'status': 'pending',
      'requested_at': DateTime.now().toIso8601String(),
    });
  }

  // Notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await _client.from('notifications').update({
      'is_read': true,
    }).eq('id', notificationId);
  }

  // Environmental Impact
  static Future<Map<String, dynamic>> getEnvironmentalImpact() async {
    final user = await getUserProfile();
    return {
      'impact': user?['environmental_impact'] ?? 0,
      'items_recycled': user?['total_items_recycled'] ?? 0,
    };
  }

  // Fetch the most recent redemption for the current user, including offer details
  static Future<Map<String, dynamic>?> getMostRecentRedemption() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    final response = await _client
        .from('redemptions')
        .select('*, offer:offer_id(*)')
        .eq('user_id', userId)
        .order('redeemed_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }

  // Fetch all active redemptions for the current user, including offer details
  static Future<List<Map<String, dynamic>>> getActiveRedemptions() async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    final response = await _client
        .from('redemptions')
        .select('*, offer:offer_id(*)')
        .eq('user_id', userId)
        .eq('used', false)
        .order('redeemed_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Mark a redemption as used
  static Future<void> markRedemptionAsUsed(String redemptionId) async {
    await _client
        .from('redemptions')
        .update({
          'used': true,
          'used_at': DateTime.now().toIso8601String(),
        })
        .eq('id', redemptionId);
  }

  // Get used offers for the current user
  static Future<List<Map<String, dynamic>>> getUsedOffers() async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    final response = await _client
        .from('redemptions')
        .select('*, offer:offer_id(*)')
        .eq('user_id', userId)
        .eq('used', true)
        .order('used_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Unified profile fetcher for user or partner
  static Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final role = user.userMetadata != null ? user.userMetadata!['role'] ?? 'user' : 'user';
    if (role == 'partner') {
      // Fetch from partners table
      final partner = await _client
          .from('partners')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (partner == null) return null;
      return {
        'name': partner['name'] ?? '',
        'email': partner['email'] ?? '',
        'phone': partner['phone'] ?? '',
        'imagePath': partner['profile_picture'] ?? '',
        'role': 'partner',
      };
    } else {
      // Fetch from users table
      final userProfile = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (userProfile == null) return null;
      return {
        'name': userProfile['full_name'] ?? '',
        'email': userProfile['email'] ?? '',
        'phone': userProfile['phone'] ?? '',
        'imagePath': userProfile['profile_picture'] ?? '',
        'role': 'user',
      };
    }
  }
}