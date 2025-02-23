import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../component/postModel.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  bool isliked = false;
  final String Base_url = '${dotenv.env['Url']}';

  late Future<List<Modelpost>> postsFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = _getPosts();
  }

  Future<int> _liked(String postId) async {
    final String url = '$Base_url/post/liked';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"post_id": postId}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        return responseData['count'] ?? -1;
      } else {
        return -5;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("ErroR $e"),
        duration: const Duration(seconds: 3),
      ));
      return -6;
    }
  }

  Future<int> _like(String postId, String userId) async {
    final String url = '$Base_url/post/like';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"post_id": postId, "user_id": userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['count'] ?? -2;
      } else {
        return -3;
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("ErroR $error"),
        duration: const Duration(seconds: 3),
      ));
      return -4;
    }
  }

  Future<List<Modelpost>> _getPosts() async {
    final String url = '$Base_url/post/getPosts';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res['data'] is List) {
          return (res['data'] as List)
              .map((json) => Modelpost.fromJson(json))
              .toList();
        } else {
          throw Exception("Invalid response format: Expected List");
        }
      } else {
        throw Exception('Error fetching posts: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error Post fetching : $e"),
        duration: const Duration(seconds: 3),
      ));
      throw Exception('Failed to load posts');
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
      body: FutureBuilder<List<Modelpost>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts found"));
          }

          List<Modelpost> posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          Text(
                            post.title,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Uploaded By: ${post.displayName.isNotEmpty ? post.displayName : 'Unknown'}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Text(post.content,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  isliked = !isliked;
                                  _like(post.id, post.authorId);
                                },
                                child: Icon(
                                  isliked
                                      ? Icons.thumb_up_alt_rounded
                                      : Icons.thumb_up_off_alt,
                                ),
                              ),
                              FutureBuilder<int>(
                                future: _liked(post.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text("...");
                                  } else if (snapshot.hasError) {
                                    return const Text("Error");
                                  } else {
                                    return Text(snapshot.data.toString());
                                  }
                                },
                              ),
                            ],
                          )
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
