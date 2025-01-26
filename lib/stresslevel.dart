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
            _buildInputField(
                _genderController, "Gender (1 = Male, 0 = Female)"),
            _buildInputField(_ageController, "Age"),
            _buildInputField(_occupationController, "Occupation (Enter code)"),
            _buildInputField(_sleepController, "Sleep Duration (hours)"),
            _buildInputField(_bmiController, "BMI Category"),
            _buildInputField(_heartRateController, "Heart Rate (beats/min)"),
            _buildInputField(_stepsController, "Daily Steps"),
            _buildInputField(_bpController, "Systolic BP (mmHg)"),
            const SizedBox(height: 20),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Get Prediction",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
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
