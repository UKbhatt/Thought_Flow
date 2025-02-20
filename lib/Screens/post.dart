import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../component/imagepicker.dart';
import 'package:http/http.dart' as http;
import '../provider/provider.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final String url = "http://192.168.137.35:5000/post";
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  File? _image;

  Future<void> _chooseImage() async {
    final imagePicker = Imagepicker();
    File? image = await imagePicker.pickImage(fromGallery: true);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _upload() async {
    final userid = Provider.of<UserProvider>(context).userId;

    try {
      final response = await http.post(Uri.parse(url), headers: {
        "Content-Type": "application/json"
      }, body: {
        "image": _image,
        "text": _contentController.text,
        "title": _titleController.text,
        "id": userid
      });

      if (response.statusCode == 201) {
        print("Post has been created successfully");
        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error:$e"), duration: const Duration(seconds: 2)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 100, 95, 95)),
                prefixIcon: const Icon(Icons.title, color: Colors.white),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _contentController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "What's on your Mind?",
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 100, 95, 95)),
                prefixIcon:
                    const Icon(Icons.text_fields_outlined, color: Colors.white),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _image != null
                ? Image.file(_image!, height: 100)
                : const Text("No image selected"),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              onPressed: _chooseImage,
              label: const Text("Pick Image"),
            ),
            ElevatedButton(onPressed: _upload, child: const Text("Upload")),
          ],
        ),
      ),
    );
  }
}
