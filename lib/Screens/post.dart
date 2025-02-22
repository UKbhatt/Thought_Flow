import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../component/imagepicker.dart';
import 'package:http/http.dart' as http;
import '../provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
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
    } else {
      setState(() {
        _image = null;
      });
    }
  }

  Future<void> _upload() async {
    final userid = Provider.of<UserProvider>(context, listen: false).userId;
    final String url = "${dotenv.env['Url']}/post/upload";

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and content cannot be empty")),
      );
      return;
    }
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));

      request.files.add(
        await http.MultipartFile.fromPath(
          'post_image',
          _image!.path,
          filename: path.basename(_image!.path),
          contentType:
              MediaType.parse(lookupMimeType(_image!.path) ?? 'image/jpeg'),
        ),
      );

      request.fields['post_text'] = _contentController.text;
      request.fields['post_title'] = _titleController.text;
      request.fields['id'] = userid ?? '';
      request.fields['visible'] = "public";

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Post uploaded successfully: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post uploaded successfully")),
        );
        Navigator.pushNamed(context, "/home");
      } else {
        print("❌ Failed to upload. Status: ${response.statusCode}");
        print("Response Body: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload: $responseBody")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print("❌ Upload Error: $e");
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
                prefixIcon: const Icon(Icons.title, color: Colors.black),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _contentController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "What's on your Mind?",
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 100, 95, 95)),
                prefixIcon:
                    const Icon(Icons.text_fields_outlined, color: Colors.black),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _image != null
                ? Image.file(_image!, height: 100)
                : const Text("No image selected"),
            const SizedBox(height: 20),
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
