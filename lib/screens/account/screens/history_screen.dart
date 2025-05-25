import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/supabase_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _usedOffers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsedOffers();
  }

  Future<void> _fetchUsedOffers() async {
    setState(() { _isLoading = true; });
    try {
      final usedOffers = await SupabaseService.getUsedOffers();
      setState(() {
        _usedOffers = usedOffers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching used offers: $e');
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Offer History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsedOffers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usedOffers.isEmpty
              ? const Center(child: Text('No offer history yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _usedOffers.length,
                  itemBuilder: (context, index) {
                    final redemption = _usedOffers[index];
                    final offer = redemption['offer'] as Map<String, dynamic>;
                    final redeemedAt = redemption['redeemed_at'];
                    final usedAt = redemption['used_at'];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                        ),
                        title: Text(
                          offer['title'] ?? 'Unknown Offer',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                              'Points: ${offer['points_required'] ?? '-'}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            if (redeemedAt != null)
                              Text(
                                'Redeemed: ${DateTime.parse(redeemedAt).toLocal().toString().replaceFirst('T', ' ').substring(0, 16)}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            if (usedAt != null)
                              Text(
                                'Used: ${usedAt.toString().split("T").first}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                          ],
                        ),
                        trailing: const Chip(
                          label: Text('Used'),
                          backgroundColor: Colors.blue,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
