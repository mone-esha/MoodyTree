import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'name_input_screen.dart';
import 'select_mood_screen.dart';
import 'home_screen.dart';
import '../services/storage_service.dart';

class StartupDecider extends StatefulWidget {
  const StartupDecider({super.key});

  @override
  State<StartupDecider> createState() => _StartupDeciderState();
}

class _StartupDeciderState extends State<StartupDecider> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');

      if (!mounted) return;

      
      if (name == null || name.isEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NameInputScreen()),
        );
        if (!mounted) return;
      }

      
      final hasToday = await StorageService.hasEntryForToday();
      if (!mounted) return;

      if (!hasToday) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SelectMoodScreen(date: DateTime.now()),
          ),
        );
        if (!mounted) return;
      }

     
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}