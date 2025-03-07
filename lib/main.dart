import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login.dart';
import 'screens/user_dashboard.dart';
import 'screens/volunteer_dashboard.dart';
import 'screens/doctor_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
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
      home: const AuthHandler(),
    );
  }
}

class AuthHandler extends StatefulWidget {
  const AuthHandler({super.key});

  @override
  _AuthHandlerState createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {}); // Rebuild when auth state changes
    });
  }

  Future<Widget> _getUserDashboard() async {
    final user = supabase.auth.currentUser;

    if (user == null) return const LoginPage(); // Not signed in

    final response = await supabase
        .from('users')
        .select('userType')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null || response['userType'] == null) {
      return const LoginPage();
    }

    switch (response['userType']) {
      case 'Volunteer':
        return const VolunteerDashboard();
      case 'Doctor':
        return const DoctorDashboard();
      default:
        return const NormalUserDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getUserDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return snapshot.data ?? const LoginPage();
      },
    );
  }
}
