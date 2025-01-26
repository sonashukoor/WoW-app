import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionButton extends StatefulWidget {
  @override
  _PredictionButtonState createState() => _PredictionButtonState();
}

class _PredictionButtonState extends State<PredictionButton> {
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();

  String _prediction = '';

  Future<void> getPrediction(Map<String, dynamic> userInput) async {
    const String url = "http://127.0.0.1:5000/predict";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userInput),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _prediction = result['prediction'] ?? 'No prediction received';
        });
      } else {
        setState(() {
          _prediction = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Error: $e';
      });
    }
  }

  void _showGuide() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Guide to Enter Values'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Gender: 1 for Male, 0 for Female"),
                Text(
                    "Occupation: 0 = Scientist, 1 = Doctor, 2 = Accountant, etc."),
                Text(
                    "BMI Category: 1 = Underweight, 2 = Normal, 3 = Overweight"),
                Text("Sleep Duration: Hours of sleep per night"),
                Text("Heart Rate: Beats per minute"),
                Text("Daily Steps: Number of steps per day"),
                Text("Systolic BP: Blood pressure in mmHg"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stress Level Analysis",
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(_genderController, "Gender"),
            _buildInputField(_ageController, "Age"),
            _buildInputField(_occupationController, "Occupation"),
            _buildInputField(_sleepController, "Sleep Duration"),
            _buildInputField(_bmiController, "BMI Category"),
            _buildInputField(_heartRateController, "Heart Rate"),
            _buildInputField(_stepsController, "Daily Steps"),
            _buildInputField(_bpController, "Systolic BP"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final Map<String, dynamic> userInput = {
                      "gender": int.parse(_genderController.text),
                      "age": int.parse(_ageController.text),
                      "occupation": int.parse(_occupationController.text),
                      "sleep_duration": double.parse(_sleepController.text),
                      "bmi_category": int.parse(_bmiController.text),
                      "heart_rate": int.parse(_heartRateController.text),
                      "daily_steps": int.parse(_stepsController.text),
                      "systolic_bp": int.parse(_bpController.text),
                    };

                    getPrediction(userInput);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 144, 102, 198),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Get Prediction",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _showGuide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 250, 160, 90),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Guide",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Prediction: $_prediction',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 144, 102, 198),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 250, 160, 90),
            ),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
