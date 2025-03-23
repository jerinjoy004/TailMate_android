import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Notifications"), backgroundColor: Colors.teal),
      body: const Center(child: Text("No notifications yet.")),
    );
  }
}
