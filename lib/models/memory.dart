import 'dart:io';

import 'package:flutter/material.dart';

/// Sentiment/meaning associated with a memory
enum MemorySentiment {
  childhoodMemory('Childhood Memory', '童年回忆'),
  grownTogether('Grown Together', '伴随成长'),
  missionCompleted('Mission Completed', '完成使命');

  const MemorySentiment(this.english, this.chinese);
  final String english;
  final String chinese;

  String label(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return chinese;
    }
    return english;
  }
}

/// Represents a memory created from decluttering activities
class Memory {
  final String id;
  final String title;
  final String? description;
  final String? photoPath;
  final DateTime createdAt;
  final MemoryType type;
  final String? itemName;
  final String? category;
  final String? notes;
  final MemorySentiment? sentiment;

  const Memory({
    required this.id,
    required this.title,
    this.description,
    this.photoPath,
    required this.createdAt,
    required this.type,
    this.itemName,
    this.category,
    this.notes,
    this.sentiment,
  });

  /// Create a memory from a decluttered item
  factory Memory.fromDeclutteredItem({
    required String id,
    required String itemName,
    required String category,
    required DateTime createdAt,
    String? photoPath,
    String? notes,
    String? description,
    MemorySentiment? sentiment,
  }) {
    return Memory(
      id: id,
      title: 'Letting go of $itemName',
      description: description ?? 'A meaningful moment of decluttering',
      photoPath: photoPath,
      createdAt: createdAt,
      type: MemoryType.decluttering,
      itemName: itemName,
      category: category,
      notes: notes,
      sentiment: sentiment,
    );
  }

  /// Create a memory from a cleaning session
  factory Memory.fromCleaningSession({
    required String id,
    required String area,
    required DateTime createdAt,
    String? description,
  }) {
    return Memory(
      id: id,
      title: 'Cleaned $area',
      description: description ?? 'A productive cleaning session',
      createdAt: createdAt,
      type: MemoryType.cleaning,
    );
  }

  /// Create a custom memory
  factory Memory.custom({
    required String id,
    required String title,
    String? description,
    String? photoPath,
    required DateTime createdAt,
    MemorySentiment? sentiment,
  }) {
    return Memory(
      id: id,
      title: title,
      description: description,
      photoPath: photoPath,
      createdAt: createdAt,
      type: MemoryType.custom,
      sentiment: sentiment,
    );
  }

  Memory copyWith({
    String? id,
    String? title,
    String? description,
    String? photoPath,
    DateTime? createdAt,
    MemoryType? type,
    String? itemName,
    String? category,
    String? notes,
    MemorySentiment? sentiment,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      sentiment: sentiment ?? this.sentiment,
    );
  }

  /// Check if the memory has a valid photo
  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty && File(photoPath!).existsSync();

  /// Get the photo file if it exists
  File? get photoFile {
    if (hasPhoto) {
      return File(photoPath!);
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Memory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Memory(id: $id, title: $title, type: $type, createdAt: $createdAt)';
  }
}

/// Types of memories that can be created
enum MemoryType {
  decluttering,
  cleaning,
  custom,
}

extension MemoryTypeExtension on MemoryType {
  String get displayName {
    switch (this) {
      case MemoryType.decluttering:
        return 'Decluttering';
      case MemoryType.cleaning:
        return 'Cleaning';
      case MemoryType.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case MemoryType.decluttering:
        return '🎯';
      case MemoryType.cleaning:
        return '🧹';
      case MemoryType.custom:
        return '💭';
    }
  }
}
