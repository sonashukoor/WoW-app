import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wow_app/moodtrack.dart'; // Ensure this import is correct
import 'package:wow_app/login_page.dart'; // Ensure correct import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WoW App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Start with login
      routes: {
        '/moodtracker': (context) => MoodAnalyticsPage(),
      },
    );
  }
}
