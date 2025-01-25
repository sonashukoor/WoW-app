import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
    DateTime(2025, 1, 15): '😊',
    DateTime(2025, 1, 16): '😢',
    DateTime(2025, 1, 17): '😡',
    DateTime(2025, 1, 18): '😴',
    DateTime(2025, 1, 19): '🤩',
  };

  // Mapping of mood emoticons
  final Map<String, String> _moodEmoticons = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😡',
    'tired': '😴',
    'neutral': '😐',
    'anxious': '😰',
    'excited': '🤩'
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
                String? mood =
                    _moodData[DateTime(day.year, day.month, day.day)];
                return Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              markerBuilder: (context, day, events) {
                String? mood =
                    _moodData[DateTime(day.year, day.month, day.day)];
                return mood != null
                    ? Center(
                        child: Text(
                          mood,
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : Container();
              },
            ),
          ),
          Expanded(
            child: _buildMoodSummary(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add mood entry functionality
          _showAddMoodDialog();
        },
      ),
    );
  }

  Widget _buildMoodSummary() {
    // Count mood occurrences
    Map<String, int> moodCounts = {};
    _moodData.values.forEach((mood) {
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    });

    return ListView(
      children: [
        Text(
          'Mood Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        ...moodCounts.entries
            .map((entry) => ListTile(
                  title: Text('${entry.key}: ${entry.value} days'),
                ))
            .toList(),
      ],
    );
  }

  void _showDayMoodDetails(DateTime selectedDay) {
    String? mood = _moodData[selectedDay];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mood on ${selectedDay.toLocal()}'),
        content: mood != null
            ? Text('Mood: $mood')
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
                    title: Text(entry.key),
                    trailing: Text(entry.value),
                    onTap: () {
                      setState(() {
                        _moodData[DateTime.now()] = entry.value;
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