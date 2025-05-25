import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RedeemScreen extends StatefulWidget {
  final int userPoints;
  const RedeemScreen({super.key, required this.userPoints});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  late int _userPoints;
  User? user;
  List<Map<String, dynamic>> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userPoints = widget.userPoints;
    user = Supabase.instance.client.auth.currentUser;
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() { _isLoading = true; });
    try {
      final offers = await Supabase.instance.client
          .from('offers')
          .select('id, title, points_required, description')
          .eq('is_active', true)
          .order('points_required', ascending: true);
      setState(() {
        _offers = List<Map<String, dynamic>>.from(offers);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load offers: \n${e.toString()}')),
      );
    }
  }

  void _redeem(Map<String, dynamic> offer) {
    final points = (offer['points_required'] ?? 0) as int;
    if (_userPoints < points) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough points to redeem ${offer['title']}.')),
      );
      return;
    }
    setState(() {
      _userPoints -= points;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redeemed ${offer['title']} for $points points!')),
    );
    // Notify parent to update points and add to active offers (with UUID)
    Navigator.of(context).pop(offer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Offers'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Points: $_userPoints', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _offers.length,
                      itemBuilder: (context, index) {
                        final offer = _offers[index];
                        return _buildOfferCard(offer);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final points = (offer['points_required'] ?? 0) as int;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer['title'] ?? '', 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('$points points', 
                          style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _redeem(offer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Redeem'),
                ),
              ],
            ),
            if (offer['description'] != null) ...[
              const SizedBox(height: 12),
              Text(offer['description'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}