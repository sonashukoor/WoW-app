import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'timetrackerpage.dart';
import 'moodtrack.dart';
import 'stresslevel.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            _buildNavButton(
              context,
              "Mood Tracker",
              Icons.mood,
              MoodAnalyticsPage(),
              Colors.orangeAccent, // Orange hint
            ),
            const SizedBox(height: 20),
            _buildNavButton(
              context,
              "Time Tracker",
              Icons.access_time,
              TimeEntryPage(),
              Colors.orangeAccent, // Orange hint
            ),
            const SizedBox(height: 20),
            _buildNavButton(
              context,
              "Stress Level Tracker",
              Icons.self_improvement,
              PredictionButton(),
              Colors.orangeAccent, // Orange hint
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, IconData icon,
      Widget page, Color accentColor) {
    return SizedBox(
      width: double.infinity,
      height: 90, // Bigger size for better interaction
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 144, 102, 198),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Softer rounded corners
          ),
          padding: const EdgeInsets.all(16),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
