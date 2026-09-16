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
        date: DateTime.parse(json['date']),
        moodIndex: json['moodIndex'],
        note: json['note'] ?? '',
      );
}