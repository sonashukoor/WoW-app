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
          title: const Text('How are you feeling today?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: Mood.values
                .map((mood) => ListTile(
                      leading: Text(_getMoodEmoji(mood),
                          style: const TextStyle(fontSize: 24)),
                      title: Text(_getMoodString(mood)),
                      onTap: () {
                        Navigator.of(context).pop();
                        _recordMood(mood);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  void _recordMood(Mood mood) {
    setState(() {
      moodRecords[DateTime.now()] = mood;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mood recorded: ${_getMoodString(mood)}')),
    );
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
        title: const Text('Mood Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MoodAnalyticsPage(moodRecords: moodRecords)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final mood = moodRecords[day];
                if (mood != null) {
                  return Center(
                    child: Text(
                      _getMoodEmoji(mood),
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showMoodSelectionPopup,
            child: const Text("Log Today's Mood"),
          ),
        ],
      ),
    );
  }
}

class MoodAnalyticsPage extends StatelessWidget {
  final Map<DateTime, Mood> moodRecords;

  const MoodAnalyticsPage({Key? key, required this.moodRecords})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Count mood frequencies
    final Map<Mood, int> moodCounts = {
      Mood.happy: 0,
      Mood.neutral: 0,
      Mood.sad: 0,
      Mood.excited: 0,
      Mood.tired: 0,
    };

    for (var mood in moodRecords.values) {
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    // Prepare data for charts
    final List<ChartData> chartData = [
      ChartData('Happy', moodCounts[Mood.happy]!, Colors.green),
      ChartData('Neutral', moodCounts[Mood.neutral]!, Colors.blue),
      ChartData('Sad', moodCounts[Mood.sad]!, Colors.red),
      ChartData('Excited', moodCounts[Mood.excited]!, Colors.purple),
      ChartData('Tired', moodCounts[Mood.tired]!, Colors.orange),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'Mood Distribution'),
          legend: Legend(isVisible: true),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries>[
            ColumnSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
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
