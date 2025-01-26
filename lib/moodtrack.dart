import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MoodAnalyticsPage extends StatefulWidget {
  @override
  _MoodAnalyticsPageState createState() => _MoodAnalyticsPageState();
}

class _MoodAnalyticsPageState extends State<MoodAnalyticsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, String> _moodData = {
    DateTime(2025, 1, 15): 'happy',
    DateTime(2025, 1, 16): 'sad',
    DateTime(2025, 1, 17): 'angry',
    DateTime(2025, 1, 18): 'tired',
    DateTime(2025, 1, 19): 'excited',
  };

  final Map<String, String> _moodEmoticons = {
    'happy': 'assets/images/happy.png',
    'sad': 'assets/images/sad.png',
    'angry': 'assets/images/angry.png',
    'tired': 'assets/images/tired.png',
    'excited': 'assets/images/excited.png',
  };

  final Map<String, Color> _moodColors = {
    'happy': const Color.fromARGB(255, 241, 192, 15),
    'sad': const Color.fromARGB(255, 78, 212, 65),
    'angry': Colors.red,
    'tired': const Color.fromARGB(255, 41, 205, 226),
    'excited': const Color.fromARGB(255, 171, 60, 204),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mood Analytics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showDayMoodDetails(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final mood = _moodData[normalizedDay];

                  return Stack(
                    children: [
                      Center(
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      if (mood != null)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Image.asset(
                              _moodEmoticons[mood]!,
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildMoodAnalyticsGraph()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 144, 102, 198),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddMoodDialog,
      ),
    );
  }

  Widget _buildMoodAnalyticsGraph() {
    Map<String, Map<String, int>> monthlyMoodCounts = {};

    _moodData.forEach((date, mood) {
      String monthKey = '${date.year}-${date.month}';
      if (!monthlyMoodCounts.containsKey(monthKey)) {
        monthlyMoodCounts[monthKey] = {};
      }
      monthlyMoodCounts[monthKey]![mood] =
          (monthlyMoodCounts[monthKey]![mood] ?? 0) + 1;
    });

    List<MoodData> chartData = [];
    monthlyMoodCounts.forEach((monthKey, moodCounts) {
      moodCounts.forEach((mood, count) {
        chartData.add(MoodData(mood, count, _moodColors[mood] ?? Colors.grey));
      });
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(
          text: 'Monthly Mood Distribution',
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        legend: Legend(isVisible: true),
        series: <CartesianSeries>[
          ColumnSeries<MoodData, String>(
            dataSource: chartData,
            xValueMapper: (MoodData mood, _) => mood.mood,
            yValueMapper: (MoodData mood, _) => mood.count,
            pointColorMapper: (MoodData mood, _) => mood.color,
            name: 'Mood Frequency',
          )
        ],
      ),
    );
  }

  void _showDayMoodDetails(DateTime selectedDay) {
    final normalizedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    final mood = _moodData[normalizedDay] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 250, 160, 90),
        title: Text(
          'Mood on ${selectedDay.toLocal()}',
          style: const TextStyle(color: Colors.white),
        ),
        content: mood.isNotEmpty
            ? Image.asset(
                _moodEmoticons[mood]!,
                width: 70,
                height: 70,
              )
            : const Text(
                'No mood recorded for this day',
                style: TextStyle(color: Colors.white),
              ),
        actions: [
          TextButton(
            child: const Text('Close', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void _showAddMoodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Mood'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _moodEmoticons.entries
              .map((entry) => ListTile(
                    leading: Image.asset(
                      entry.value,
                      width: 30,
                      height: 30,
                    ),
                    title: Text(entry.key),
                    onTap: () {
                      DateTime today = DateTime.now();
                      final normalizedToday =
                          DateTime(today.year, today.month, today.day);
                      setState(() {
                        _moodData[normalizedToday] = entry.key;
                      });
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class MoodData {
  final String mood;
  final int count;
  final Color color;
  MoodData(this.mood, this.count, this.color);
}
