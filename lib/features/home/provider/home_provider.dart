import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Model classes
class EcoPointTransaction {
  final String id;
  final String title;
  final int points;
  final DateTime date;
  final String? partnerLogo;

  EcoPointTransaction({
    required this.id,
    required this.title,
    required this.points,
    required this.date,
    this.partnerLogo,
  });

  factory EcoPointTransaction.fromMap(Map<String, dynamic> map) {
    return EcoPointTransaction(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown',
      points: map['points'] ?? 0,
      date: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      partnerLogo: map['partner_logo'],
    );
  }
}

class HomeState {
  final int totalPoints;
  final List<EcoPointTransaction> recentTransactions;
  final bool isLoading;
  final String? error;

  HomeState({
    this.totalPoints = 0,
    this.recentTransactions = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    int? totalPoints,
    List<EcoPointTransaction>? recentTransactions,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      totalPoints: totalPoints ?? this.totalPoints,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Provider
class HomeNotifier extends StateNotifier<HomeState> {
  final SupabaseClient _supabaseClient;
  
  HomeNotifier(this._supabaseClient) : super(HomeState()) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // 1. Get current user
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // 2. Fetch user points from the users table
      final userResponse = await _supabaseClient
          .from('users')
          .select('points')
          .eq('id', userId)
          .single();
      
      final points = userResponse['points'] as int? ?? 0;
      
      // 3. Fetch recent transactions
      final transactionsResponse = await _supabaseClient
          .from('eco_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);
      
      final transactions = (transactionsResponse as List)
          .map((item) => EcoPointTransaction.fromMap(item))
          .toList();
      
      state = state.copyWith(
        totalPoints: points,
        recentTransactions: transactions,
        isLoading: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addPoints(int points) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // 1. Update user points in a transaction using RPC function
      // Note: You would need to create this function in Supabase
      // ignore: unused_local_variable
      final result = await _supabaseClient
          .rpc('add_user_points', params: {
            'user_id': userId,
            'points_amount': points
          });
      
      // 2. Record transaction
      await _supabaseClient.from('eco_transactions').insert({
        'user_id': userId,
        'title': 'QR Code Scan',
        'points': points,
        'type': 'earned'
      });
      
      // 3. Update local state
      state = state.copyWith(
        totalPoints: state.totalPoints + points,
        isLoading: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

// Provider declarations
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return HomeNotifier(supabaseClient);
});

// Helper providers
final totalPointsProvider = Provider<int>((ref) {
  return ref.watch(homeProvider.select((state) => state.totalPoints));
});

final recentTransactionsProvider = Provider<List<EcoPointTransaction>>((ref) {
  return ref.watch(homeProvider.select((state) => state.recentTransactions));
});