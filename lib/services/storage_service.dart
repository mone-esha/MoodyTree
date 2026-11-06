import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class StorageService {
  static const _keyPrefix = 'mood_entry_';

  static String _keyForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '$_keyPrefix${normalized.toIso8601String()}';
  }

  static Future<void> saveMoodEntry(MoodEntry entry) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _keyForDate(entry.date);
  debugPrint('STORAGE save key = "$key"');

  final normalizedEntry = MoodEntry(
    date: DateTime(entry.date.year, entry.date.month, entry.date.day),
    moodIndex: entry.moodIndex,
    note: entry.note,
  );

  final json = jsonEncode(normalizedEntry.toJson());
  debugPrint('STORAGE save json = $json');

  await prefs.setString(key, json);
  debugPrint('STORAGE save done');
}

static Future<List<MoodEntry>> getAllEntries() async {
  final prefs = await SharedPreferences.getInstance();
  final allKeys = prefs.getKeys();
  debugPrint('STORAGE all prefs keys = $allKeys');

  final keys = allKeys.where((k) => k.startsWith(_keyPrefix));
  debugPrint('STORAGE mood keys = $keys');

  final entries = <MoodEntry>[];
  for (final key in keys) {
    final raw = prefs.getString(key);
    debugPrint('STORAGE read key="$key" raw=$raw');
    if (raw == null) continue;
    try {
      entries.add(
        MoodEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    } catch (e, st) {
      debugPrint('STORAGE SKIP "$key": $e\n$st');
    }
  }
  return entries;
}

  static Future<MoodEntry?> getMoodEntry(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForDate(date));
    if (raw == null) return null;
    try {
      return MoodEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Bad mood entry for $date: $e');
      return null;
    }
  }

  static Future<bool> hasEntryForToday() async {
    final entry = await getMoodEntry(DateTime.now());
    return entry != null;
  }
}