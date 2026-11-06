import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/mood_constants.dart';
import '../utils/mood_messages.dart';
import '../models/mood_entry.dart';
import '../services/storage_service.dart';
import 'mood_message_screen.dart';

class SelectMoodScreen extends StatefulWidget {
  final DateTime date;
  final MoodEntry? existingEntry;

  const SelectMoodScreen({
    super.key,
    required this.date,
    this.existingEntry,
  });

  @override
  State<SelectMoodScreen> createState() => _SelectMoodScreenState();
}

class _SelectMoodScreenState extends State<SelectMoodScreen> {
  late final PageController _pageController;
  late final TextEditingController _noteController;

  late int _currentIndex;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    assert(moods.isNotEmpty, 'moods must not be empty');

    _noteController = TextEditingController(
      text: widget.existingEntry?.note ?? '',
    );

    final savedIndex = widget.existingEntry?.moodIndex ?? 0;
    _currentIndex = moods.isEmpty ? 0 : savedIndex.clamp(0, moods.length - 1);

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
  if (_isSaving) return;

  FocusScope.of(context).unfocus();

  setState(() {
    _isSaving = true;
  });

  try {
    final entry = MoodEntry(
      date: widget.date,
      moodIndex: _currentIndex,
      note: _noteController.text.trim(),
    );

    await StorageService.saveMoodEntry(entry);

    if (!mounted) return;

    final message = randomMessageForMood(_currentIndex);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MoodMessageScreen(message: message),
      ),
    );

    if (!mounted) return;

    Navigator.of(context).pop();
  } catch (error) {
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not save mood: $error')),
    );
  }
}
  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    final currentColor =
        Color.lerp(moods[_currentIndex].color, Colors.white, 0.5)!;

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: currentColor,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: currentColor,
          resizeToAvoidBottomInset: true,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            color: currentColor,
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final keyboardHeight =
                      MediaQuery.of(context).viewInsets.bottom;

                  final moodAreaHeight = keyboardHeight > 0
                      ? constraints.maxHeight * 0.38
                      : constraints.maxHeight * 0.50;

                  return ScrollConfiguration(
                    behavior: const _NoGlowScrollBehavior(),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          children: [
                            _buildAppBar(isEditing),
                            SizedBox(
                              height: moodAreaHeight,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: moods.length,
                                onPageChanged: _onPageChanged,
                                itemBuilder: (context, index) {
                                  final mood = moods[index];
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Image.asset(
                                              mood.imagePath,
                                              height: moodAreaHeight * 0.65,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            mood.label,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: moods.length,
                              effect: const WormEffect(
                                dotHeight: 10,
                                dotWidth: 10,
                                spacing: 8,
                                activeDotColor: Colors.black87,
                                dotColor: Colors.black26,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _noteController,
                                    maxLines: 1,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _saveMood(),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Add a note (optional)',
                                      hintStyle: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withValues(
                                        alpha: 0.60,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.black54,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isSaving ? null : _saveMood,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black87,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            Colors.black54,
                                        disabledForegroundColor:
                                            Colors.white70,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _isSaving
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              isEditing
                                                  ? 'Save Changes'
                                                  : 'Choose',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed:
                _isSaving ? null : () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              isEditing ? 'Edit Mood' : 'How are you feeling?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}