import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';
import '../services/storage_service.dart';
import '../utils/mood_constants.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  List<MoodEntry> _allEntries = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await StorageService.getAllEntries();
    setState(() {
      _allEntries = entries;
    });
  }

  List<MoodEntry> get _entriesForSelectedMonth {
    return _allEntries.where((e) {
      return e.date.year == _selectedMonth.year &&
          e.date.month == _selectedMonth.month;
    }).toList();
  }

  Map<int, int> get _countsForSelectedMonth {
    final counts = <int, int>{};
    for (final entry in _entriesForSelectedMonth) {
      counts[entry.moodIndex] = (counts[entry.moodIndex] ?? 0) + 1;
    }
    return counts;
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
      _touchedIndex = -1;
    });
  }

  String get _monthLabel {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final counts = _countsForSelectedMonth;
    final total = counts.values.fold(0, (sum, c) => sum + c);

    final chartData = <Map<String, dynamic>>[];
    for (int i = 0; i < moods.length; i++) {
      final count = counts[i] ?? 0;
      if (count > 0) {
        chartData.add({
          'mood': moods[i].label,
          'count': count,
          'percent': total == 0 ? 0.0 : (count / total) * 100,
          'color': moods[i].color,
        });
      }
    }

    chartData.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    final maxCount = chartData.isEmpty
        ? 1
        : chartData.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b);

    return Container(
      color: Colors.white.withOpacity(0.75),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Mood Stats', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              Text(_monthLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (chartData.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No mood entries for this month yet')),
            )
          else ...[
            const Text('By Count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  maxY: (maxCount + 1).toDouble(),
                  barGroups: List.generate(chartData.length, (i) {
                    final d = chartData[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (d['count'] as int).toDouble(),
                          color: d['color'] as Color,
                          width: 28,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= chartData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              chartData[index]['mood'] as String,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              ),
            ),

            const SizedBox(height: 32),

            const Text('By Percentage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: List.generate(chartData.length, (i) {
                    final d = chartData[i];
                    final isTouched = i == _touchedIndex;
                    final radius = isTouched ? 70.0 : 60.0;
                    final percent = d['percent'] as double;

                    return PieChartSectionData(
                      value: percent,
                      color: d['color'] as Color,
                      radius: radius,
                      title: '${percent.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              ),
            ),

            const SizedBox(height: 24),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: chartData.map((d) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: d['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(d['mood'] as String, style: const TextStyle(fontSize: 13)),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}