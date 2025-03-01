import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final String url = "${dotenv.env['Url']}/post/upload";

  Future<void> _upload() async {
    final userid = Provider.of<UserProvider>(context, listen: false).userId;

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
      request.fields['userId'] = userid ?? '';
      request.fields['visible'] = "public";

      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post uploaded successfully")),
        );
        Navigator.pushNamed(context, "/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload: $responseBody")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _upload,
            color: Colors.green,
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Create Post",
                style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold, fontSize: 35),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Post Title",
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
                labelText: "Description",
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
            InkWell(
              onTap: _chooseImage,
              child: _image != null
                  ? Image.file(
                      _image!,
                      height: height * 0.4,
                      width: width * 0.4,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.add_a_photo_rounded,
                      size: 100,
                      color: Colors.grey,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
