import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class NormalUserDashboard extends StatefulWidget {
  const NormalUserDashboard({super.key});

  @override
  _NormalUserDashboardState createState() => _NormalUserDashboardState();
}

class _NormalUserDashboardState extends State<NormalUserDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    final response = await _supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    return response;
  }

  Future<List<Map<String, dynamic>>> _fetchComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return response;
  }

  void _addComment(String postId, String commentText) async {
    if (commentText.isNotEmpty) {
      await _supabase.from('comments').insert({
        'post_id': postId,
        'user_id': _auth.currentUser?.uid,
        'comment_text': commentText,
        'created_at': DateTime.now().toIso8601String(),
      });
      setState(() {}); // Refresh UI
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedImage == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select an image and enter a description")),
      );
      return;
    }

    try {
      final fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageResponse = await _supabase.storage
          .from('images')
          .upload(fileName, _selectedImage!);

      // Instead of checking for null, check if it's an empty string
      if (storageResponse.isEmpty) {
        throw Exception("Failed to upload image");
      }

      final imageUrl = _supabase.storage.from('images').getPublicUrl(fileName);

      await _supabase.from('posts').insert({
        'user_id': _auth.currentUser?.uid,
        'image_url': imageUrl,
        'description': _descriptionController.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        _selectedImage = null;
        _descriptionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading post: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_selectedImage != null)
                  Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                TextField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(hintText: "Enter description"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("Pick Image"),
                    ),
                    ElevatedButton(
                      onPressed: _uploadPost,
                      child: const Text("Upload Post"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPosts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data!;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post['image_url'] != null)
                            Image.network(post['image_url'], fit: BoxFit.cover),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(post['description'] ?? '',
                                style: const TextStyle(fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: _fetchComments(post['id']),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                final comments = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Comments:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    ...comments.map((comment) => Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                              "- ${comment['comment_text']}"),
                                        )),
                                    TextField(
                                      decoration: const InputDecoration(
                                          hintText: "Add a comment..."),
                                      onSubmitted: (value) =>
                                          _addComment(post['id'], value),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: "Donate"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          // Future functionality for navigation
        },
      ),
    );
  }
}
