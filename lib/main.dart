import 'package:flutter/material.dart';
import 'moodtrack.dart'; // Ensure this import matches your file name

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MoodTrackingApp(), // Changed to MoodTrackingApp
    );
  }
}
