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
  late Future<List<ModelPost>> postsFuture;
  late String url;

  @override
  void initState() {
    super.initState();
    url = '${dotenv.env['Url']}/post/getPosts'; // Ensure URL is loaded
    postsFuture = _getPosts();
  }

  Future<List<ModelPost>> _getPosts() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res['data'] is List) {
          List<ModelPost> posts = (res['data'] as List)
              .map((json) => ModelPost.fromJson(json))
              .toList();
          // for (var post in res['data']) {
          //   print(
          //       "Display Name: ${post['profiles']?['display_name'] ?? 'Unknown'}");
          // }

          return posts;
        } else {
          throw Exception("Invalid response format: Expected List");
        }
      } else {
        throw Exception('Error fetching posts: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  void reloadPosts() {
    setState(() {
      postsFuture = _getPosts();
    });
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: reloadPosts, // Reload function on button press
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

          return RefreshIndicator(
            onRefresh: () async {
              reloadPosts();
            },
            child: ListView.builder(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
