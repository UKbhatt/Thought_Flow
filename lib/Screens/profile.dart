import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:thoughtflow/provider/provider.dart';
import '../component/imageGallery.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  String? _profileImage;

  Future<void> _chooseImageGallery() async {
    final ImagePicker = Imagepicker();
    File? image = await ImagePicker.pickImage(fromGallery: true);

    if (image != null) {
      setState(() {
        _image = image;
      });
      showDialog(
          context: (context),
          builder: (context) {
            return AlertDialog(
              actions: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.file(_image!),
                ),
                InkWell(onTap: _upload, child: const Text("Upload"))
              ],
            );
          });
    } else {
      setState(() {
        _image = null;
      });
    }
  }

  Future<void> _upload() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image")));
    } else {
      final String url = "${dotenv.env['Url']}/Profile/PostImage";
      final userid = Provider.of<UserProvider>(context, listen: false).userId;

      try {
        var request = http.MultipartRequest("POST", Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          filename: path.basename(_image!.path),
          contentType:
              MediaType.parse(lookupMimeType(_image!.path) ?? 'image/jpeg'),
        ));
        request.fields['user_id'] = userid ?? '';

        var response = await request.send();

        var responseBody = await response.stream.bytesToString();
        if (response.statusCode == 200) {
          print(responseBody);
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
        print(e);
      }
    }
  }

  Future<void> _accessProfileImage() async {
    final String url = "${dotenv.env['Url']}/Profile/GetImage";
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        setState(() {
          _profileImage = res['data']['profile_image'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: const Text("Profil Image Not Found")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Profile Image Error: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    _accessProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Upload Profile Image"),
                          content: const Text("Choose an option"),
                          actions: [
                            TextButton(
                                onPressed: _chooseImageGallery,
                                child: const Text("Gallery")),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.add_photo_alternate_outlined))
          ],
        ),
        body: Stack(
          children: [
            _profileImage == null
                ? const SpinKitChasingDots(color: Colors.blue)
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_profileImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ],
        ));
  }
}
