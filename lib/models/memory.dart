import 'dart:io';

import 'package:flutter/material.dart';

/// Sentiment/meaning associated with a memory
enum MemorySentiment {
  love('Love', '爱'),
  nostalgia('Nostalgia', '怀念'),
  adventure('Adventure', '冒险'),
  happy('Happy', '快乐'),
  grateful('Grateful', '感激'),
  peaceful('Peaceful', '平静');

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
  final String userId; // Foreign key to auth.users
  final String title;
  final String? description;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final MemoryType type;
  final String? itemName;
  final String? category;
  final String? notes;
  final MemorySentiment? sentiment;

  const Memory({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.photoPath,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    this.itemName,
    this.category,
    this.notes,
    this.sentiment,
  });

  /// Create a memory from a decluttered item
  factory Memory.fromDeclutteredItem({
    required String id,
    String userId = 'local_user',
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
      userId: userId,
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
    required String userId,
    required String area,
    required DateTime createdAt,
    String? description,
  }) {
    return Memory(
      id: id,
      userId: userId,
      title: 'Cleaned $area',
      description: description ?? 'A productive cleaning session',
      createdAt: createdAt,
      type: MemoryType.cleaning,
    );
  }

  /// Create a custom memory
  factory Memory.custom({
    required String id,
    required String userId,
    required String title,
    String? description,
    String? photoPath,
    required DateTime createdAt,
    MemorySentiment? sentiment,
  }) {
    return Memory(
      id: id,
      userId: userId,
      title: title,
      description: description,
      photoPath: photoPath,
      createdAt: createdAt,
      type: MemoryType.custom,
      sentiment: sentiment,
    );
  }

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type.name,
      'item_name': itemName,
      'category': category,
      'notes': notes,
      'sentiment': sentiment?.name,
    };
  }

  // Create from JSON from Supabase
  factory Memory.fromJson(Map<String, dynamic> json) {
    // Handle sentiment with backward compatibility for old values
    MemorySentiment? sentiment;
    if (json['sentiment'] != null) {
      try {
        sentiment = MemorySentiment.values.firstWhere(
          (e) => e.name == json['sentiment'],
        );
      } catch (e) {
        // If old sentiment value doesn't match new enum, set to null
        // This handles migration from old sentiments gracefully
        sentiment = null;
      }
    }

    return Memory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      photoPath: json['photo_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      type: MemoryType.values.firstWhere((e) => e.name == json['type']),
      itemName: json['item_name'] as String?,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      sentiment: sentiment,
    );
  }

  Memory copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    MemoryType? type,
    String? itemName,
    String? category,
    String? notes,
    MemorySentiment? sentiment,
  }) {
    return Memory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      sentiment: sentiment ?? this.sentiment,
    );
  }

  /// Check if the memory has a valid photo
  bool get hasPhoto =>
      photoPath != null &&
      photoPath!.isNotEmpty &&
      File(photoPath!).existsSync();

  /// Get the photo file if it exists
  File? get photoFile {
    if (hasPhoto) {
      return File(photoPath!);
    }
    return null;
  }

  /// Get the story (description) of the memory
  String get story => description ?? '';

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
enum MemoryType { decluttering, cleaning, custom, grateful, lesson, celebrate }

extension MemoryTypeExtension on MemoryType {
  String get displayName {
    switch (this) {
      case MemoryType.decluttering:
        return 'Decluttering';
      case MemoryType.cleaning:
        return 'Cleaning';
      case MemoryType.custom:
        return 'Custom';
      case MemoryType.grateful:
        return 'Grateful';
      case MemoryType.lesson:
        return 'Lesson';
      case MemoryType.celebrate:
        return 'Celebrate';
    }
  }

  String label(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isChinese = locale.languageCode.toLowerCase().startsWith('zh');

    switch (this) {
      case MemoryType.decluttering:
        return isChinese ? '整理' : 'Decluttering';
      case MemoryType.cleaning:
        return isChinese ? '清洁' : 'Cleaning';
      case MemoryType.custom:
        return isChinese ? '自定义' : 'Custom';
      case MemoryType.grateful:
        return isChinese ? '感恩' : 'Grateful';
      case MemoryType.lesson:
        return isChinese ? '教训' : 'Lesson';
      case MemoryType.celebrate:
        return isChinese ? '庆祝' : 'Celebrate';
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
      case MemoryType.grateful:
        return '🙏';
      case MemoryType.lesson:
        return '📚';
      case MemoryType.celebrate:
        return '🎉';
    }
  }
}
