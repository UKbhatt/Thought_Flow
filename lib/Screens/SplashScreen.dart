import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final supabase = Supabase.instance.client;
    await Future.delayed(const Duration(seconds: 3));
    final user = supabase.auth.currentUser;
    Timer(const Duration(seconds: 2), () {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Thought Flow',
            style: TextStyle(
              letterSpacing: 0.6,
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: height * 0.05),
          const SpinKitChasingDots(
            color: Colors.black,
            size: 50.0,
          ),
        ],
      ),
    );
  }
}
