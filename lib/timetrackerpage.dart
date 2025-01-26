import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'firebase_options.dart';

class TimeEntryPage extends StatefulWidget {
  @override
  _TimeEntryPageState createState() => _TimeEntryPageState();
}

class _TimeEntryPageState extends State<TimeEntryPage> {
  final TextEditingController workTimeController = TextEditingController();
  final TextEditingController familyTimeController = TextEditingController();
  final TextEditingController choresTimeController = TextEditingController();
  final TextEditingController meTimeController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> timeEntries = [];

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _fetchTimeEntries();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<void> _fetchTimeEntries() async {
    final querySnapshot = await _firestore.collection('time_entries').get();
    timeEntries = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {});
  }

  void _saveToFirestore() async {
    final currentDay = DateTime.now().weekday.toString();
    final dataToSave = {
      "day": currentDay,
      "Work": int.tryParse(workTimeController.text) ?? 0,
      "Family": int.tryParse(familyTimeController.text) ?? 0,
      "Chores": int.tryParse(choresTimeController.text) ?? 0,
      "Me Time": int.tryParse(meTimeController.text) ?? 0,
    };
    await _firestore.collection('time_entries').doc(currentDay).set(dataToSave);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved to Firestore!')),
    );
  }

  @override
  void dispose() {
    workTimeController.dispose();
    familyTimeController.dispose();
    choresTimeController.dispose();
    meTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Entry"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
                workTimeController, "Work Time (hours)", Icons.work),
            const SizedBox(height: 10),
            _buildTextField(familyTimeController, "Family Time (hours)",
                Icons.family_restroom),
            const SizedBox(height: 10),
            _buildTextField(choresTimeController, "Chores Time (hours)",
                Icons.cleaning_services),
            const SizedBox(height: 10),
            _buildTextField(meTimeController, "Me Time (hours)", Icons.spa),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 144, 102, 198),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Save to Firestore",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: TimeEntryGraph(timeEntries: timeEntries)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 144, 102, 198)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orangeAccent),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }
}

class TimeEntryGraph extends StatelessWidget {
  final List<Map<String, dynamic>> timeEntries;

  const TimeEntryGraph({Key? key, required this.timeEntries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = _calculateAverages();
    return BarChart(
      BarChartData(
        maxY: 100,
        barGroups: data
            .map((entry) => BarChartGroupData(
                  x: data.indexOf(entry),
                  barRods: [
                    BarChartRodData(
                      toY: entry.average,
                      width: 20,
                      color: const Color.fromARGB(255, 144, 102, 198),
                      borderRadius: BorderRadius.circular(5),
                    )
                  ],
                ))
            .toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text('${value.toInt()}%'),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(data[value.toInt()].category),
            ),
          ),
        ),
      ),
    );
  }

  List<_TimeEntryAverage> _calculateAverages() {
    final totalTime = timeEntries.fold<num>(
      0,
      (total, entry) =>
          total +
          (entry["Work"] ?? 0) +
          (entry["Family"] ?? 0) +
          (entry["Chores"] ?? 0) +
          (entry["Me Time"] ?? 0),
    );

    final percentageByCategory = timeEntries.fold<Map<String, num>>(
      {"Work": 0, "Family": 0, "Chores": 0, "Me Time": 0},
      (acc, entry) {
        acc["Work"] = acc["Work"]! + (entry["Work"] ?? 0);
        acc["Family"] = acc["Family"]! + (entry["Family"] ?? 0);
        acc["Chores"] = acc["Chores"]! + (entry["Chores"] ?? 0);
        acc["Me Time"] = acc["Me Time"]! + (entry["Me Time"] ?? 0);
        return acc;
      },
    );

    return percentageByCategory.entries
        .map((e) => _TimeEntryAverage(
              e.key,
              totalTime > 0 ? (e.value / totalTime) * 100 : 0,
            ))
        .toList();
  }
}

class _TimeEntryAverage {
  final String category;
  final double average;

  _TimeEntryAverage(this.category, this.average);
}
