import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';

class NormalUserDashboard extends StatefulWidget {
  const NormalUserDashboard({super.key});

  @override
  _NormalUserDashboardState createState() => _NormalUserDashboardState();
}

class _NormalUserDashboardState extends State<NormalUserDashboard> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();

  void _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    final response = await _supabase
        .from('posts')
        .select('id, user_id, image_url, description, created_at')
        .order('created_at', ascending: false);
    return response;
  }

  Future<List<Map<String, dynamic>>> _fetchComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select('comment_text, created_at')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return response;
  }

  void _addComment(String postId, String commentText) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to comment")),
      );
      return;
    }

    if (commentText.isNotEmpty) {
      await _supabase.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'comment_text': commentText,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Manually refresh UI
      setState(() {});
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
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to upload a post")),
      );
      return;
    }

    if (_selectedImage == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select an image and enter a description")),
      );
      return;
    }

    try {
      // Read image as bytes
      Uint8List imageBytes = await _selectedImage!.readAsBytes();

      // Generate unique file name
      final fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload image to Supabase Storage
      await _supabase.storage.from('images').uploadBinary(fileName, imageBytes);

      // Get public URL
      final imageUrl = _supabase.storage.from('images').getPublicUrl(fileName);

      // Insert post into database
      await _supabase.from('posts').insert({
        'user_id': user.id,
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
                              future: _fetchComments(post['id'].toString()),
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
                                      onSubmitted: (value) => _addComment(
                                          post['id'].toString(), value),
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
    );
  }
}
