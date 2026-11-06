import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';
import '../services/storage_service.dart';
import '../utils/mood_constants.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => StatsTabState();
}

class StatsTabState extends State<StatsTab>
    with SingleTickerProviderStateMixin {
  List<MoodEntry> _allEntries = [];
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  int _touchedIndex = -1;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEntries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> reload() => _loadEntries();

  Future<void> _loadEntries() async {
    final entries = await StorageService.getAllEntries();
    if (!mounted) return;
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
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta);
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
    final total = counts.values.fold<int>(0, (sum, c) => sum + c);

    final chartData = <_MoodStat>[];
    for (int i = 0; i < moods.length; i++) {
      final count = counts[i] ?? 0;
      if (count > 0) {
        chartData.add(_MoodStat(
          mood: moods[i].label,
          count: count,
          percent: total == 0 ? 0.0 : (count / total) * 100,
          color: moods[i].color,
        ));
      }
    }
    chartData.sort((a, b) => b.count.compareTo(a.count));

    final maxCount = chartData.isEmpty
        ? 1
        : chartData.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    return Container(
      color: Colors.white.withOpacity(0.75),
      child: Column(
        children: [
          // Header (title + month selector)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood Stats',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      _monthLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black45,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'By Count'),
                Tab(text: 'By Percentage'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tab views
          Expanded(
            child: chartData.isEmpty
                ? const Center(
                    child: Text('No mood entries for this month yet'),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // ---- By Count ----
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  maxY: (maxCount + 1).toDouble(),
                                  barGroups: List.generate(
                                    chartData.length,
                                    (i) {
                                      final d = chartData[i];
                                      return BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: d.count.toDouble(),
                                            color: d.color,
                                            width: 28,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index < 0 ||
                                              index >= chartData.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 6),
                                            child: Text(
                                              chartData[index].mood,
                                              style: const TextStyle(
                                                  fontSize: 11),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData:
                                      const FlGridData(show: false),
                                  borderData:
                                      FlBorderData(show: false),
                                ),
                                duration:
                                    const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLegend(chartData),
                          ],
                        ),
                      ),

                      // ---- By Percentage ----
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 50,
                                  pieTouchData: PieTouchData(
                                    touchCallback: (event, response) {
                                      setState(() {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            response == null ||
                                            response.touchedSection ==
                                                null) {
                                          _touchedIndex = -1;
                                          return;
                                        }
                                        _touchedIndex = response
                                            .touchedSection!
                                            .touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  sections: List.generate(
                                    chartData.length,
                                    (i) {
                                      final d = chartData[i];
                                      final isTouched = i == _touchedIndex;
                                      final radius =
                                          isTouched ? 70.0 : 60.0;
                                      return PieChartSectionData(
                                        value: d.percent,
                                        color: d.color,
                                        radius: radius,
                                        title:
                                            '${d.percent.toStringAsFixed(0)}%',
                                        titleStyle: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                duration:
                                    const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLegend(chartData),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<_MoodStat> chartData) {
    return Wrap(
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
                color: d.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              d.mood,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _MoodStat {
  final String mood;
  final int count;
  final double percent;
  final Color color;

  const _MoodStat({
    required this.mood,
    required this.count,
    required this.percent,
    required this.color,
  });
}