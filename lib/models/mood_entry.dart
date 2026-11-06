class MoodEntry {
  final DateTime date;
  final int moodIndex;
  final String note;

  const MoodEntry({
    required this.date,
    required this.moodIndex,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'moodIndex': moodIndex,
        'note': note,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        date: DateTime.parse(json['date'] as String),
        moodIndex: (json['moodIndex'] as num).toInt(),
        note: (json['note'] as String?) ?? '',
      );
}