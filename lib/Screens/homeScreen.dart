import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../component/postModel.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late Future<List<ModelPost>> postsFuture;
  late String Url = ' ${dotenv.env['Url']}/post';

  Future<void> _like() async {
    try {
      final url = '$Url/like';
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        throw Exception('Error liking post: ${response.statusCode}');
      }
    } catch (e) {
      print("Error occured: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    postsFuture = _getPosts();
  }

  Future<List<ModelPost>> _getPosts() async {
    try {
      final url = '$Url/getPosts';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print(res);

        if (res['data'] is List) {
          List<ModelPost> posts = (res['data'] as List)
              .map((json) => ModelPost.fromJson(json))
              .toList();

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
        title: Text("Though Flow",
            style: GoogleFonts.tiroKannada(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                )),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: reloadPosts,
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 98, 151, 243),
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
            child: Stack(
              children: [
                Container(
                  color: const Color.fromARGB(255, 104, 140, 169),
                ),
                ListView.builder(
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
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
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
                                      onTap: () => _like(),
                                      child: Icon(
                                          post.isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      post.likeCount.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/post"),
        backgroundColor: Colors.blue.shade300,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
