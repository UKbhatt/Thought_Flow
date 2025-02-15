import 'package:flutter/material.dart';
import 'package:thoughtflow/Screens/homeScreen.dart';
import 'package:thoughtflow/Screens/loginScreen.dart';
import 'package:thoughtflow/Screens/signupScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThoughtFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Loginscreen(),
        '/home': (context) => const Homescreen(),
        '/Signup': (context) => const Signupscreen(),
      },
    );
  }
}
