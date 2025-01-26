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

  // Mock mood data - replace with actual database or state management
  Map<DateTime, String> _moodData = {
    DateTime(2025, 1, 15): 'happy',
    DateTime(2025, 1, 16): 'sad',
    DateTime(2025, 1, 17): 'angry',
    DateTime(2025, 1, 18): 'tired',
    DateTime(2025, 1, 19): 'excited',
  };

  // Mapping of mood emoticons
  final Map<String, String> _moodEmoticons = {
    'happy': 'assets/images/happy.png',
    'sad': 'assets/images/sad.png',
    'angry': 'assets/images/angry.png',
    'tired': 'assets/images/tired.png',
    'excited': 'assets/images/excited.png'
  };

  // Color mapping for moods
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
        title: Text('Mood Analytics'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showDayMoodDetails(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                // Normalize the day to remove time components
                final normalizedDay = DateTime(day.year, day.month, day.day);

                // Find the mood for this specific day
                final mood = _moodData.entries
                    .firstWhere(
                      (entry) =>
                          entry.key.year == normalizedDay.year &&
                          entry.key.month == normalizedDay.month &&
                          entry.key.day == normalizedDay.day,
                      orElse: () => MapEntry(normalizedDay, ''),
                    )
                    .value;

                return Center(
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 243, 240, 240),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: mood.isNotEmpty
                        ? Image.asset(
                            _moodEmoticons[mood]!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          )
                        : Text(
                            day.day.toString(),
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _buildMoodAnalyticsGraph(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddMoodDialog();
        },
      ),
    );
  }

  Widget _buildMoodAnalyticsGraph() {
    // Group moods by month
    Map<String, Map<String, int>> monthlyMoodCounts = {};

    _moodData.forEach((date, mood) {
      String monthKey = '${date.year}-${date.month}';
      if (!monthlyMoodCounts.containsKey(monthKey)) {
        monthlyMoodCounts[monthKey] = {};
      }
      monthlyMoodCounts[monthKey]![mood] =
          (monthlyMoodCounts[monthKey]![mood] ?? 0) + 1;
    });

    // Convert to chart data
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
        title: ChartTitle(text: 'Monthly Mood Distribution'),
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
    // Normalize the day to remove time components
    final normalizedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    // Find the mood for this specific day
    final mood = _moodData.entries
        .firstWhere(
          (entry) =>
              entry.key.year == normalizedDay.year &&
              entry.key.month == normalizedDay.month &&
              entry.key.day == normalizedDay.day,
          orElse: () => MapEntry(normalizedDay, ''),
        )
        .value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mood on ${selectedDay.toLocal()}'),
        content: mood.isNotEmpty
            ? Image.asset(
                _moodEmoticons[mood]!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              )
            : Text('No mood recorded for this day'),
        actions: [
          TextButton(
            child: Text('Close'),
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
        title: Text('Add Mood'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _moodEmoticons.entries
              .map((entry) => ListTile(
                    leading: Image.asset(
                      entry.value,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                    title: Text(entry.key),
                    onTap: () {
                      // Use a normalized DateTime (stripped time components)
                      DateTime today = DateTime.now();
                      final normalizedToday =
                          DateTime(today.year, today.month, today.day);

                      setState(() {
                        // Add new mood for today
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
