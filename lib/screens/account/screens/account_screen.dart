import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/account/widgets/profile_header.dart';
import 'package:flutter_application_3/screens/account/widgets/menu_item.dart';
import 'package:flutter_application_3/screens/account/screens/history_screen.dart';
import 'package:flutter_application_3/services/supabase_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await SupabaseService.getCurrentProfile();
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'My Account',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
                ProfileHeader(
                  name: _profile?['name'],
                  email: _profile?['email'],
                  phone: _profile?['phone'],
                  imagePath: _profile?['imagePath'],
          ),
          const SizedBox(height: 20),
          _buildCardMenu([
            MenuItem(
              icon: Icons.person,
              label: 'About Me',
              route: '/about-me',
            ),
            MenuItem(
              icon: Icons.home,
              label: 'My Address',
              route: '/address',
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history, color: Colors.green),
              ),
              title: const Text('History', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            MenuItem(
              icon: Icons.notifications,
              label: 'Notifications',
              route: '/notifications',
            ),
          ]),
          const SizedBox(height: 20),
          _buildCardMenu([
            MenuItem(
              icon: Icons.logout,
              label: 'Sign Out',
              route: '/logout',
              isDestructive: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildCardMenu(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}
