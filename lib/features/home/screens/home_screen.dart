import 'package:flutter/material.dart';
import 'package:flutter_application_3/features/account/screens/account_screen.dart';
import 'package:flutter_application_3/features/account/screens/active_offers_screen.dart';
// import 'package:flutter_application_3/features/home/screens/redeem_screen.dart';
import 'package:flutter_application_3/features/home/screens/scan_qr_screen.dart';
import 'package:flutter_application_3/features/home/screens/pickup_screen.dart';
import 'package:flutter_application_3/features/home/widgets/points_card.dart';
import 'dart:convert';
import 'package:flutter_application_3/features/account/screens/qr_display_screen.dart';
import 'package:flutter_application_3/features/home/screens/redeem_screen.dart';
import 'package:flutter_application_3/features/home/screens/add_offer_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_3/core/utils/routes.dart';
import 'package:flutter_application_3/services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _activeOffers = [];

  void _addActiveOffer(Map<String, dynamic> offer) {
    setState(() {
      _activeOffers.add(offer);
    });
  }

  void _removeExpiredOffers() {
    setState(() {
      _activeOffers.removeWhere((offer) => offer['expiresAt'].isBefore(DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    _removeExpiredOffers();
    final user = Supabase.instance.client.auth.currentUser;
    final role = user?.userMetadata != null ? user!.userMetadata!['role'] ?? 'user' : 'user';
    final isPartner = role == 'partner';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeContent(
              onAddActiveOffer: _addActiveOffer,
              activeOffers: _activeOffers,
            ),
            if (!isPartner)
              ActiveOffersScreen(
                activeOffers: _activeOffers,
                onMarkOfferUsed: (int index) {
                  setState(() {
                    _activeOffers[index]['used'] = true;
                  });
                },
              ),
            if (isPartner)
              AddOfferScreen(),
            AccountScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: const Color.fromARGB(255, 121, 121, 121),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: isPartner
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add Offer'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.star_rate_sharp), label: 'Active Offers'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAddActiveOffer;
  final List<Map<String, dynamic>> activeOffers;
  const HomeContent({super.key, required this.onAddActiveOffer, required this.activeOffers});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _userPoints = 0;
  int _totalItemsRecycled = 0;
  Map<String, dynamic>? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _refreshUserStats();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await SupabaseService.getCurrentProfile();
    setState(() {
      _profile = profile;
      _isLoadingProfile = false;
    });
  }

  Future<void> _refreshUserStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final role = user.userMetadata != null ? user.userMetadata!['role'] ?? 'user' : 'user';
    if (role == 'partner') {
      // Fetch from partners table
      final partnerData = await Supabase.instance.client.from('partners').select('points').eq('id', user.id).maybeSingle();
      setState(() {
        _userPoints = partnerData?['points'] ?? 0;
        // Optionally set _totalItemsRecycled = 0 or fetch if you have that for partners
      });
    } else {
      // Fetch from users table
      final userData = await Supabase.instance.client.from('users').select('total_points, total_items_recycled').eq('id', user.id).maybeSingle();
      if (userData != null) {
        setState(() {
          _userPoints = userData['total_points'] ?? 0;
          _totalItemsRecycled = userData['total_items_recycled'] ?? 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final role = user?.userMetadata != null ? user!.userMetadata!['role'] ?? 'user' : 'user';
    final isPartner = role == 'partner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _refreshUserStats();
              await _fetchProfile();
              if (mounted) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data refreshed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, ${_profile?['name'] ?? ''}', style: Theme.of(context).textTheme.headlineMedium),
                  Text("Let's save the world", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  PointsCard(points: _userPoints),
                  const SizedBox(height: 24),
                  _buildEnvironmentalImpact(),
                  const SizedBox(height: 24),
                  _buildActionGrid(context),
                  if (isPartner)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                      child: Center(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {}, // Non-functional
                            icon: const Icon(Icons.attach_money),
                            label: const Text('Withdraw cash'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEnvironmentalImpact() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Environmental Impact', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Icon(Icons.recycling, color: Colors.green, size: 40),
                  const SizedBox(height: 8),
                  Text('$_totalItemsRecycled', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Items Recycled', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.amber, size: 40),
                  const SizedBox(height: 8),
                  Text('${(_totalItemsRecycled * 0.5).toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('CO₂ Saved', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 40),
                  const SizedBox(height: 8),
                  Text('${(_totalItemsRecycled * 2).toStringAsFixed(0)} L', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Water Saved', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final role = user?.userMetadata != null ? user!.userMetadata!['role'] ?? 'user' : 'user';
    final isPartner = role == 'partner';

    List<Widget> actionCards = [];

    if (isPartner) {
      // Partner-specific actions
      actionCards = [
        _buildActionCard(context, Icons.qr_code_scanner, 'Partner Scanner', () async {
          final result = await Navigator.pushNamed(context, AppRoutes.partnerScanner);
          if (result == true) {
            await _refreshUserStats();
          }
        }),
        _buildActionCard(context, Icons.local_shipping, 'Pickup Request', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PickupScreen(),
            ),
          );
        }),
      ];
    } else {
      // User-specific actions
      actionCards = [
        _buildActionCard(context, Icons.qr_code_scanner, 'Scan QR Code', () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanQrScreen(),
            ),
          );
          if (result == true) {
            await _refreshUserStats();
          }
        }),
        _buildActionCard(context, Icons.card_giftcard, 'Redeem Offer', () async {
          final user = Supabase.instance.client.auth.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You must be logged in to redeem an offer.')),
            );
            return;
          }
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RedeemScreen(userPoints: _userPoints),
            ),
          );
          await _refreshUserStats();
          if (!mounted) return;
          if (result != null) {
            final offer = result as Map<String, dynamic>;
            if (offer.isNotEmpty) {
              final qrData = {
                'offerId': offer['id'],
                'userId': user.id,
                'timestamp': DateTime.now().toIso8601String(),
              };
              final qrDataString = jsonEncode(qrData);
              if (!mounted) return;
              Navigator.push(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                  builder: (context) => QRDisplayScreen(data: qrDataString),
                ),
              );
            }
          }
        }),
        _buildActionCard(context, Icons.star_rate_sharp, 'Active Offers', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActiveOffersScreen(
                activeOffers: widget.activeOffers,
                onMarkOfferUsed: (int index) {
                  setState(() {
                    widget.activeOffers[index]['used'] = true;
                  });
                },
              ),
            ),
          );
        }),
        _buildActionCard(context, Icons.local_shipping, 'Pickup', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PickupScreen(),
            ),
          );
        }),
      ];
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: actionCards,
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(icon, size: 50, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}