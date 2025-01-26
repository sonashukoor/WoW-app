class TimeEntry {
  String? id;
  int workTime;
  int familyTime;
  int choresTime;
  int meTime;

  TimeEntry({
    this.id,
    required this.workTime,
    required this.familyTime,
    required this.choresTime,
    required this.meTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'workTime': workTime,
      'familyTime': familyTime,
      'choresTime': choresTime,
      'meTime': meTime,
    };
  }

  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      id: map['id'] as String?,
      workTime: map['workTime'] as int,
      familyTime: map['familyTime'] as int,
      choresTime: map['choresTime'] as int,
      meTime: map['meTime'] as int,
    );
  }
}
