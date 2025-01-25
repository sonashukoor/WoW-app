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
    DateTime(2025, 1, 15): 'assets/images/happy.png',
    DateTime(2025, 1, 16): 'assets/images/sad.png',
    DateTime(2025, 1, 17): 'assets/images/angry.png',
    DateTime(2025, 1, 18): 'assets/images/tired.png',
    DateTime(2025, 1, 19): 'assets/images/excited.png',
  };

  // Mapping of mood emoticons
  final Map<String, String> _moodEmoticons = {
    'happy': 'assets/images/happy.png',
    'sad': 'assets/images/sad.png',
    'angry': 'assets/images/angry.png',
    'tired': 'assets/images/tired.png',
    'excited': 'assets/images/excited.png'
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
                // Fetch the mood image path for the given day
                final moodImagePath =
                    _moodData[DateTime(day.year, day.month, day.day)];

                return Center(
                  child: Container(
                    width: 45, // Adjust the size of the background
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      shape: BoxShape.circle, // Circular background
                    ),
                    alignment: Alignment
                        .center, // Centers the content within the circle
                    child: moodImagePath != null
                        ? Padding(
                            padding: const EdgeInsets.all(
                                4.0), // Add padding for the image
                            child: Image.asset(
                              moodImagePath, // Load image from assets
                              fit: BoxFit
                                  .contain, // Ensure it fits within the circle
                            ),
                          )
                        : Text(
                            day.day
                                .toString(), // Fallback: Displays the day of the month
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _buildMoodSummary(),
          ),
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

    _moodData.values.forEach((moodImagePath) {
      // Extract mood label based on the image path
      String mood = moodImagePath
          .split('/')
          .last
          .split('.')
          .first; // Example: happy.png => happy
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
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/images/${entry.key}.png', // Assuming mood images are named like happy.png
                        width: 20, // Adjust size of image
                        height: 20,
                      ),
                      SizedBox(width: 8),
                      Text('${entry.key}: ${entry.value} days'),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  void _showDayMoodDetails(DateTime selectedDay) {
    String? moodImagePath = _moodData[selectedDay];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mood on ${selectedDay.toLocal()}'),
        content: moodImagePath != null
            ? Image.asset(
                moodImagePath, // Show the mood image
                width: 50, // Adjust size as needed
                height: 50,
                fit: BoxFit.cover, // Ensure it fits well
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
                      entry.value, // Show the image next to the mood label
                      width: 30, // Adjust size as needed
                      height: 30,
                      fit: BoxFit.cover, // Ensure it fits well
                    ),
                    title: Text(entry.key),
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
