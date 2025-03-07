import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();

  String? _selectedUserType;
  bool _isLoading = false;

  final List<String> _userTypes = ["Normal User", "Volunteer", "Doctor"];

  void _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String locality = _localityController.text.trim();
    String licenseNumber = _licenseNumberController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        _selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    if ((_selectedUserType == "Volunteer" || _selectedUserType == "Doctor") &&
        locality.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your locality.")),
      );
      return;
    }

    if (_selectedUserType == "Doctor" && licenseNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your license number.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Register user with Supabase Authentication
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw "User registration failed.";

      // Store user data in Supabase Database
      final Map<String, dynamic> userData = {
        'id': user.id, // Ensuring correct user ID
        'name': name,
        'email': email,
        'userType': _selectedUserType, // Ensure correct column name
      };

      if (_selectedUserType == "Volunteer" || _selectedUserType == "Doctor") {
        userData['locality'] = locality;
      }
      if (_selectedUserType == "Doctor") {
        userData['licenseNumber'] = licenseNumber;
        userData['isVerified'] = false; // Boolean instead of string
      }

      await supabase.from('users').insert(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Registration successful! Please log in.")),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUserType,
                items: _userTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUserType = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Select User Type",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedUserType == "Volunteer" ||
                  _selectedUserType == "Doctor")
                Column(
                  children: [
                    TextField(
                      controller: _localityController,
                      decoration: const InputDecoration(
                        labelText: "Enter Locality",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              if (_selectedUserType == "Doctor")
                Column(
                  children: [
                    TextField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: "Enter License Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register", style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text("Already have an account? Login here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
