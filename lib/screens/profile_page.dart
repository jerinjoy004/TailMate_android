import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar:
          AppBar(title: const Text("Profile"), backgroundColor: Colors.teal),
      body: Center(
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Email: ${user.email}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      Navigator.pop(context);
                    },
                    child: const Text("Logout"),
                  ),
                ],
              )
            : const Text("User not logged in."),
      ),
    );
  }
}
