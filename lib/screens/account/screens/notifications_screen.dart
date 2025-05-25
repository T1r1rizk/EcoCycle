// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Create a list to store the switch states
  List<bool> switchStates = [true, true, true, true]; // Default all to true

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // light background
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _NotificationTile(
            title: "Allow Notifications",
            subtitle: "Lorem ipsum dolor sit amet, consectetur sadipscing elitr",
            switchValue: switchStates[0],
            onChanged: (value) {
              setState(() {
                switchStates[0] = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _NotificationTile(
            title: "Email Notifications",
            subtitle: "Lorem ipsum dolor sit amet, consectetur sadipscing elitr",
            switchValue: switchStates[1],
            onChanged: (value) {
              setState(() {
                switchStates[1] = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _NotificationTile(
            title: "Order Notifications",
            subtitle: "Lorem ipsum dolor sit amet, consectetur sadipscing elitr",
            switchValue: switchStates[2],
            onChanged: (value) {
              setState(() {
                switchStates[2] = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _NotificationTile(
            title: "General Notifications",
            subtitle: "Lorem ipsum dolor sit amet, consectetur sadipscing elitr",
            switchValue: switchStates[3],
            onChanged: (value) {
              setState(() {
                switchStates[3] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: switchValue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
