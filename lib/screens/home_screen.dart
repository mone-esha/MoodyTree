import 'package:flutter/material.dart';
import 'calendar_tab.dart';
import 'stats_tab.dart';
import 'name_input_screen.dart';
import '../services/export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  String _userName = '';

  final GlobalKey<CalendarTabState> _calendarKey =
      GlobalKey<CalendarTabState>();
  final GlobalKey<StatsTabState> _statsKey = GlobalKey<StatsTabState>();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
    });
  }

  

  Future<void> _changeName() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NameInputScreen()),
    );
    if (!mounted) return;
    await _loadUserName();
  }

  Future<void> _exportData() async {
    try {
      await ExportService.exportAsJson();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export complete.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 50, 50, 50),
        title: Text(_userName.isEmpty ? 'MoodyTree' : 'Hi, $_userName'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'MoodyTree',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _tabIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Change Name'),
                onTap: () {
                  Navigator.pop(context);
                  _changeName();
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Download Data'),
                onTap: () {
                  Navigator.pop(context);
                  _exportData();
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _tabIndex == 0
              ? CalendarTab(key: _calendarKey)
              : StatsTab(key: _statsKey),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
        ),
      ],
    ),
      
    );
  }
}