import 'package:flutter/material.dart';
import 'package:thoughtflow/Screens/homeScreen.dart';
import 'package:thoughtflow/Screens/loginScreen.dart';
import 'package:thoughtflow/Screens/post.dart';
import 'package:thoughtflow/Screens/profile.dart';
import 'package:thoughtflow/Screens/signupScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thoughtflow/Screens/Splashscreen.dart';
import 'package:thoughtflow/provider/provider.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_URL'] ?? '',
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: const MyApp(),
  ));
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const Splashscreen(),
        '/login': (context) => const Loginscreen(),
        '/signup': (context) => const Signupscreen(),
        '/home': (context) => const Homescreen(),
        '/post': (context) => const Post(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}
