import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/supabase_service.dart';

class ActiveOffersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> activeOffers;
  final Function(int) onMarkOfferUsed;

  const ActiveOffersScreen({
    super.key,
    required this.activeOffers,
    required this.onMarkOfferUsed,
  });

  @override
  State<ActiveOffersScreen> createState() => _ActiveOffersScreenState();
}

class _ActiveOffersScreenState extends State<ActiveOffersScreen> {
  List<Map<String, dynamic>> redemptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveRedemptions();
  }

  Future<void> _fetchActiveRedemptions() async {
    setState(() { _isLoading = true; });
    final fetchedRedemptions = await SupabaseService.getActiveRedemptions();
    setState(() {
      redemptions = fetchedRedemptions;
      _isLoading = false;
    });
  }

  Future<void> _markOfferAsUsed(Map<String, dynamic> redemption) async {
    try {
      // Update the redemption in Supabase
      await SupabaseService.markRedemptionAsUsed(redemption['id']);
      
      // No need to update parent list anymore

      // Refresh the list
      await _fetchActiveRedemptions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer marked as used successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking offer as used: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Offers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchActiveRedemptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'These are your currently active (redeemed and not yet used) offers.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: redemptions.isEmpty
                      ? const Center(child: Text('No active offers.'))
                      : ListView.builder(
                          itemCount: redemptions.length,
        itemBuilder: (context, index) {
                            final redemption = redemptions[index];
                            final offer = redemption['offer'] as Map<String, dynamic>;
                            final redeemedAt = redemption['redeemed_at'];
                            final expiresAt = redemption['expires_at'];
                            final isUsed = redemption['used'] == true;
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        offer['title'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isUsed ? Colors.grey : Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isUsed ? 'Used' : 'Active',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (offer['description'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                                        child: Text(
                                          offer['description'],
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    Text(
                                      'Points required: ${offer['points_required'] ?? '-'}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    if (redeemedAt != null)
                                      Text(
                                        'Redeemed: ${redeemedAt.toString().split("T").first}',
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    if (expiresAt != null)
                                      Text(
                                        'Expires: ${expiresAt.toString().split("T").first}',
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                  ],
                                ),
                                trailing: isUsed
                                    ? const Icon(Icons.check_circle, color: Colors.grey)
                                    : ElevatedButton(
                                        onPressed: () => _markOfferAsUsed(redemption),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Mark as Used'),
                                      ),
                                isThreeLine: true,
                    ),
                  );
                },
                        ),
              ),
              ],
      ),
    );
  }
} 