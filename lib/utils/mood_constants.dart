import 'package:flutter/material.dart';

class Mood {
  final String label;
  final String imagePath;
  final Color color;

  const Mood({
    required this.label,
    required this.imagePath,
    required this.color,
  });
}

const List<Mood> moods = [
  Mood(
    label: 'Energetic',
    imagePath: 'assets/images/tree energetic.png',
    color: Color.fromRGBO(224, 167, 31, 1)  ),
  Mood(
    label: 'Happy',
    imagePath: 'assets/images/tree happy.png',
    color: Color.fromRGBO(227, 239, 119, 1)  ),
  Mood(
    label: 'Calm',
    imagePath: 'assets/images/tree calm.png',
    color: Color.fromRGBO(101, 182, 116, 1), 
  ),
  Mood(
    label: 'Sad',
    imagePath: 'assets/images/tree sad.png',
    color: Color.fromRGBO(75, 131, 202, 1),
  ),
  Mood(
    label: 'Annoyed',
    imagePath: 'assets/images/tree annoyed.png',
    color: Color.fromRGBO(178, 66, 57, 1), 
  ),
  Mood(
    label: 'Tired',
    imagePath: 'assets/images/tree tired.png',
    color: Color.fromRGBO(156, 107, 81, 1), 
  ),
];