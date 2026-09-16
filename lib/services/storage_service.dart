import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class StorageService {
  static const _keyPrefix = 'mood_entry_';

  // Turns a date into a consistent key, ignoring time-of-day
  static String _keyForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '$_keyPrefix${normalized.toIso8601String()}';
  }
    static Future<void> saveMoodEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(entry.date);
    await prefs.setString(key, jsonEncode(entry.toJson()));
  }

    static Future<List<MoodEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    final entries = <MoodEntry>[];

    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw != null) {
        entries.add(MoodEntry.fromJson(jsonDecode(raw)));
      }
    }
    return entries;
  }

  static Future<MoodEntry?> getMoodEntry(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date);
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return MoodEntry.fromJson(jsonDecode(raw));
  }

  static Future<bool> hasEntryForToday() async {
    final entry = await getMoodEntry(DateTime.now());
    return entry != null;
  }
}