import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum Mood { happy, neutral, sad, excited, tired }

class MoodTrackingApp extends StatefulWidget {
  @override
  _MoodTrackingAppState createState() => _MoodTrackingAppState();
}

class _MoodTrackingAppState extends State<MoodTrackingApp> {
  Map<DateTime, Mood> moodRecords = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMoodSelectionPopup();
    });
  }

  void _showMoodSelectionPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('How are you feeling today?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: Mood.values
                  .map((mood) => ListTile(
                        title: Text(_getMoodString(mood)),
                        onTap: () {
                          Navigator.of(context).pop();
                          _recordMood(mood);
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void _recordMood(Mood mood) {
    setState(() {
      moodRecords[DateTime.now()] = mood;
    });
  }

  String _getMoodString(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return '😊 Happy';
      case Mood.neutral:
        return '😐 Neutral';
      case Mood.sad:
        return '😢 Sad';
      case Mood.excited:
        return '🎉 Excited';
      case Mood.tired:
        return '😴 Tired';
    }
  }

  String _getMoodEmoji(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return '😊';
      case Mood.neutral:
        return '😐';
      case Mood.sad:
        return '😢';
      case Mood.excited:
        return '🎉';
      case Mood.tired:
        return '😴';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MoodAnalyticsPage(moodRecords: moodRecords)),
              );
            },
          )
        ],
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
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final mood = moodRecords[day];
                if (mood != null) {
                  return Center(
                    child: Text(
                      _getMoodEmoji(mood),
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          ElevatedButton(
            child: Text('Log Today\'s Mood'),
            onPressed: _showMoodSelectionPopup,
          ),
        ],
      ),
    );
  }
}

class MoodAnalyticsPage extends StatelessWidget {
  final Map<DateTime, Mood> moodRecords;

  MoodAnalyticsPage({required this.moodRecords});

  @override
  Widget build(BuildContext context) {
    // Count mood frequencies
    Map<Mood, int> moodCounts = {
      Mood.happy: 0,
      Mood.neutral: 0,
      Mood.sad: 0,
      Mood.excited: 0,
      Mood.tired: 0,
    };

    moodRecords.forEach((date, mood) {
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    });

    // Prepare data for charts
    final List<ChartData> chartData = [
      ChartData('Happy', moodCounts[Mood.happy]!, Colors.green),
      ChartData('Neutral', moodCounts[Mood.neutral]!, Colors.blue),
      ChartData('Sad', moodCounts[Mood.sad]!, Colors.red),
      ChartData('Excited', moodCounts[Mood.excited]!, Colors.purple),
      ChartData('Tired', moodCounts[Mood.tired]!, Colors.orange),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Mood Analytics')),
      body: Center(
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'Mood Distribution'),
          series: <CartesianSeries>[
            ColumnSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            )
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final int y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}
