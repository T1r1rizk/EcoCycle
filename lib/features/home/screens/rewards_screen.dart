import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/widget/points_display.dart';
import 'package:flutter_application_3/features/home/widgets/offer_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_3/features/home/screens/offer_detail_screen.dart';

class AvailableOffersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> activeOffers;
  final void Function(int) onMarkOfferUsed;
  const AvailableOffersScreen({super.key, required this.activeOffers, required this.onMarkOfferUsed});

  @override
  State<AvailableOffersScreen> createState() => _AvailableOffersScreenState();
}

class _AvailableOffersScreenState extends State<AvailableOffersScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _offers = [];
  int _userPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }
      // Get user points
      final userData = await _supabase
          .from('users')
          .select('total_points')
          .eq('id', user.id)
          .single();
      if (!mounted) return;
      // Get active offers from partners
      final offers = await _supabase
          .from('offers')
          .select('id, title, description, points_required, image, partner_id, partner:partner_id(name, logo)')
          .eq('is_active', true)
          .order('points_required', ascending: true);
      if (!mounted) return;
      setState(() {
        _userPoints = userData['total_points'] ?? 0;
        _offers = List<Map<String, dynamic>>.from(offers);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error loading rewards data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Available Offers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          PointsDisplay(points: _userPoints),
          const SizedBox(height: 8),
          if (widget.activeOffers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Active Offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.activeOffers.length,
                itemBuilder: (context, i) {
                  final offer = widget.activeOffers[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text(offer['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${offer['points_required']} points'),
                      trailing: ElevatedButton(
                              onPressed: () => widget.onMarkOfferUsed(i),
                              child: const Text('Mark as Used'),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _offers.isEmpty
                    ? const Center(child: Text('No rewards available at the moment'))
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _offers.length,
                          itemBuilder: (context, index) {
                            final offer = _offers[index];
                            final partnerData = offer['partner'] as Map<String, dynamic>?;
                            final partnerName = partnerData?['name'] ?? 'Partner';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OfferDetailScreen(
                                        points: offer['points_required'],
                                        description: offer['description'],
                                      ),
                                      settings: RouteSettings(
                                        arguments: {
                                          'offerId': offer['id'],
                                          'title': offer['title'],
                                          'points': offer['points_required'],
                                          'description': offer['description'],
                                          'partnerId': offer['partner_id'],
                                          'partnerName': partnerName,
                                          'userPoints': _userPoints,
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: OfferCard(
                                  title: '$partnerName - ${offer['title']}',
                                  points: offer['points_required'],
                                  description: offer['description'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}