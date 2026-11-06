import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mood_entry.dart';
import '../services/storage_service.dart';
import '../utils/mood_constants.dart';
import 'select_mood_screen.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => CalendarTabState();
}

class CalendarTabState extends State<CalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, MoodEntry> _entriesByDate = {};

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  
  Future<void> reload() => _loadEntries();

  Future<void> _loadEntries() async {
    final entries = await StorageService.getAllEntries();
    if (!mounted) return;

    final map = <DateTime, MoodEntry>{};
    for (final entry in entries) {
      final normalized =
          DateTime(entry.date.year, entry.date.month, entry.date.day);
      map[normalized] = entry;
    }
    setState(() {
      _entriesByDate = map;
    });
  }

  MoodEntry? _entryForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _entriesByDate[normalized];
  }

  Future<void> _openMoodScreen(DateTime day) async {
    final today = DateTime.now();
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (normalizedDay.isAfter(normalizedToday)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can't log a mood for a future date."),
        ),
      );
      return;
    }

    final existing = _entryForDay(day);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectMoodScreen(date: day, existingEntry: existing),
      ),
    );

    if (!mounted) return;
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntry =
        _selectedDay != null ? _entryForDay(_selectedDay!) : null;

    return Container(
      color: Colors.white.withOpacity(0.75),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              rowHeight: 70,
              daysOfWeekHeight: 32,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _openMoodScreen(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              
              calendarStyle: const CalendarStyle(
                cellMargin: EdgeInsets.all(6),
                todayDecoration: BoxDecoration(),
                selectedDecoration: BoxDecoration(),
                outsideDecoration: BoxDecoration(),
                defaultDecoration: BoxDecoration(),
                rangeStartDecoration: BoxDecoration(),
                rangeEndDecoration: BoxDecoration(),
                withinRangeDecoration: BoxDecoration(),
                disabledDecoration: BoxDecoration(),
              ),
              calendarBuilders: CalendarBuilders(
                
                selectedBuilder: (context, day, focusedDay) {
                  final entry = _entryForDay(day);

                  if (entry == null) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black87,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final mood = moods[entry.moodIndex];
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: mood.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },

                
                todayBuilder: (context, day, focusedDay) {
                  final entry = _entryForDay(day);

                  if (entry == null) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }

                  final mood = moods[entry.moodIndex];
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: mood.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },

                
                defaultBuilder: (context, day, focusedDay) {
                  final entry = _entryForDay(day);
                  if (entry == null) return null;

                  final mood = moods[entry.moodIndex];
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: mood.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (selectedEntry != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Note: ${selectedEntry.note.isEmpty ? "(no note)" : selectedEntry.note}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}