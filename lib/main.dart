import 'package:flutter/material.dart';
import 'package:wow_app/moodtrack.dart'; // Ensure this import is correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WoW App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          MoodAnalyticsPage(), // Changed to MoodAnalyticsPage from the moodtrack.dart file
    );
  }
}
