import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login.dart';
import 'screens/user_dashboard.dart';
import 'screens/volunteer_dashboard.dart';
import 'screens/doctor_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await supabase.Supabase.initialize(
    url: 'https://svusoeaykfxhxhuyazfb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN2dXNvZWF5a2Z4aHhodXlhemZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MzQwOTAsImV4cCI6MjA1NDMxMDA5MH0.ankq3_TwIBaLpT6LwDBEkI2yQNbaVwoVnG8s8undpbY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TailMate',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: AuthHandler(), // 🔥 Handles Authentication Persistence
    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                String userType = userSnapshot.data!['userType'];

                if (userType == "Volunteer") {
                  return VolunteerDashboard();
                } else if (userType == "Doctor") {
                  return DoctorDashboard();
                } else {
                  return NormalUserDashboard();
                }
              } else {
                return const LoginPage(); // User type unknown, redirect to login
              }
            },
          );
        }

        return const LoginPage(); // Not signed in, show login
      },
    );
  }
}
