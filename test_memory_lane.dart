import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/features/insights/memory_lane_report_screen.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MemoryLaneReportScreen(
          memories: _generateTestMemories(),
        ),
      ),
    );
  }

  List<Memory> _generateTestMemories() {
    final now = DateTime.now();
    return List.generate(20, (index) {
      return Memory(
        id: 'test_$index',
        userId: 'test_user',
        title: 'Memory $index',
        description: 'This is a test memory description',
        category: index % 2 == 0 ? 'Personal' : 'Work',
        sentiment: MemorySentiment.values[index % MemorySentiment.values.length],
        createdAt: now.subtract(Duration(days: index * 10)),
        updatedAt: now.subtract(Duration(days: index * 10)),
        type: MemoryType.custom,
      );
    });
  }
}