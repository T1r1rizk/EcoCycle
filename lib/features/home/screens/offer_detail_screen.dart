import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfferDetailScreen extends StatefulWidget {
  final int points;
  final String description;

  const OfferDetailScreen({
    super.key,
    required this.points,
    required this.description,
  });

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  final _supabase = Supabase.instance.client;
  bool _isRedeeming = false;
  late Map<String, dynamic> _offerDetails;
  late int _userPoints;
  String? _offerId;
  String? _title;
  
  // Partner data
  String? _partnerName;
  String? _partnerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments passed from rewards screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      _offerId = args['offerId'];
      _partnerId = args['partnerId'];
      _title = args['title'];
      _userPoints = args['userPoints'] ?? 0;
      _partnerName = args['partnerName'] ?? 'Partner';
      _offerDetails = {
        'points': args['points'] ?? widget.points,
        'description': args['description'] ?? widget.description,
      };
    } else {
      _offerDetails = {
        'points': widget.points,
        'description': widget.description,
      };
      _userPoints = 0;
      _partnerName = 'Partner';
    }
    
    // If we have a partnerId but no partner name, fetch the partner details
    if (_partnerId != null && (_partnerName == null || _partnerName == 'Partner')) {
      _fetchPartnerDetails();
    }
  }

  // Fetch partner details if needed
  Future<void> _fetchPartnerDetails() async {
    // Only proceed if partnerId is not null
    if (_partnerId == null) {
      debugPrint('Cannot fetch partner details: partnerId is null');
      return;
    }
    
    try {
      final response = await _supabase
          .from('Partner')
          .select('Partner_name')
          .eq('Partner_ID', _partnerId!)
          .single();
      if (!mounted) return;
        setState(() {
          _partnerName = response['Partner_name'];
        });
    } catch (e) {
      debugPrint('Error fetching partner details: $e');
    }
  }

  Future<void> _redeemOffer() async {
    if (_offerId == null || _userPoints < _offerDetails['points']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough points to redeem this offer!')),
      );
      return;
    }

    setState(() {
      _isRedeeming = true;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create redemption record
      await _supabase.from('redemptions').insert({
        'user_id': user.id,
        'offer_id': _offerId,
        'redeemed_at': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      // Update user points
      final newPoints = _userPoints - _offerDetails['points'];
      await _supabase
          .from('users')
          .update({'total_points': newPoints})
          .eq('id', user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer redeemed successfully!')),
      );

      // Go back to previous screen after successful redemption
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error redeeming offer: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to redeem offer: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRedeeming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canRedeem = _userPoints >= _offerDetails['points'];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light background
      appBar: AppBar(
        title: Text(
          _title ?? 'Offer Details',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_offerDetails['points']} points',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Your points: $_userPoints',
                    style: TextStyle(
                      color: canRedeem ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partner: $_partnerName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _offerDetails['description'],
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canRedeem && !_isRedeeming ? _redeemOffer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green color
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRedeeming
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        canRedeem ? 'Redeem Offer' : 'Not Enough Points',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}