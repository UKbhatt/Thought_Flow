import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:thoughtflow/provider/provider.dart';
import '../component/postModel.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final String baseUrl = dotenv.env['Url']!;
  late Future<List<ModelPost>> postsFuture;
  late final UserProvider UserId;
  late String userId;


  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false) as String;
    postsFuture = _getPosts();
  }

  Future<List<ModelPost>> _getPosts() async {
    final String url = '$baseUrl/post/getPosts';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['data'] is List) {
          return (res['data'] as List)
              .map((json) => ModelPost.fromJson(json))
              .toList();
        } else {
          throw Exception("Invalid response format: Expected List");
        }
      } else {
        throw Exception('Error fetching posts: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching posts: $e")),
      );
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _toggleLike(String postId) async {
    final String url = '$baseUrl/post/like';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"post_id": postId, "user_id": userId}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to like/unlike post");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ThoughFlow"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child:
                GestureDetector(onTap: () {}, child: const Icon(Icons.person)),
          ),
        ],
      ),
      body: FutureBuilder<List<ModelPost>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts found"));
          }

          List<ModelPost> posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(post.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post Title
                          Text(
                            post.title,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),

                          // Uploaded By
                          Text(
                            "Uploaded By: ${post.displayName.isNotEmpty ? post.displayName : 'Unknown'}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 10),

                          // Post Content
                          Text(post.content,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),

                          // Like Button and Count
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _toggleLike(post.id);
                                  });
                                },
                                child: Icon(
                                  post.isLiked
                                      ? Icons.thumb_up_alt_rounded
                                      : Icons.thumb_up_off_alt,
                                  color:
                                      post.isLiked ? Colors.blue : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(post.likeCount.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/post"),
        backgroundColor: Colors.blue.shade300,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
