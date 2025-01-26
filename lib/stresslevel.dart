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
  String _uniqueId = '';  // New state variable to store the unique ID

  // Function to send data to the backend and get the prediction
  Future<void> getPrediction(Map<String, dynamic> userInput) async {
    const String url = "http://127.0.0.1:5000/predict"; // Local backend URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userInput),
      );

      if (response.statusCode == 200) {
        // Debugging: Print the raw response for inspection
        print('Response body: ${response.body}');

        final result = jsonDecode(response.body);
        print('Decoded Response: $result');
        setState(() {
          _prediction = result['prediction'] ?? 'No prediction received';
          _uniqueId = result['id'] ?? 'No ID received';  // Capture the unique ID
          
        });
      } else {
        setState(() {
          _prediction = 'Error: ${response.statusCode}';
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _prediction = 'Error: $e';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stress Level Analysis')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _genderController,
              decoration:
                  InputDecoration(labelText: "Gender (1 = Male, 0 = Female)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _occupationController,
              decoration: InputDecoration(
                  labelText: "Occupation (Enter code for occupation)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _sleepController,
              decoration: InputDecoration(labelText: "Sleep Duration (hours)"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _bmiController,
              decoration: InputDecoration(labelText: "BMI Category"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heartRateController,
              decoration: InputDecoration(labelText: "Heart Rate (beats/min)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _stepsController,
              decoration: InputDecoration(labelText: "Daily Steps"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _bpController,
              decoration: InputDecoration(labelText: "Systolic BP (mmHg)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
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
              child: Text('Get Prediction'),
            ),
            SizedBox(height: 20),
            Text(
              'Prediction: $_prediction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
