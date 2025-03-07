import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  void _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut(); // Supabase Logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to the Doctor Dashboard",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
