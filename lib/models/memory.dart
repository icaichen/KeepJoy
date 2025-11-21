import 'dart:io';

import 'package:flutter/material.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';

/// Sentiment/meaning associated with a memory
enum MemorySentiment {
  love,
  nostalgia,
  adventure,
  happy,
  grateful,
  peaceful;

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case MemorySentiment.love:
        return l10n.sentimentLove;
      case MemorySentiment.nostalgia:
        return l10n.sentimentNostalgia;
      case MemorySentiment.adventure:
        return l10n.sentimentAdventure;
      case MemorySentiment.happy:
        return l10n.sentimentHappy;
      case MemorySentiment.grateful:
        return l10n.sentimentGrateful;
      case MemorySentiment.peaceful:
        return l10n.sentimentPeaceful;
    }
  }
}

/// Represents a memory created from decluttering activities
class Memory {
  final String id;
  final String userId; // Foreign key to auth.users
  final String title;
  final String? description;
  final String? localPhotoPath;
  final String? remotePhotoPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt; // Soft delete timestamp
  final String? deviceId; // Device that made the last change
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
    this.localPhotoPath,
    this.remotePhotoPath,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deviceId,
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
    String? localPhotoPath,
    String? remotePhotoPath,
    String? notes,
    String? description,
    MemorySentiment? sentiment,
  }) {
    return Memory(
      id: id,
      userId: userId,
      title: itemName,
      description: description,
      localPhotoPath: localPhotoPath,
      remotePhotoPath: remotePhotoPath,
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
    String? localPhotoPath,
    String? remotePhotoPath,
    required DateTime createdAt,
    MemorySentiment? sentiment,
  }) {
    return Memory(
      id: id,
      userId: userId,
      title: title,
      description: description,
      localPhotoPath: localPhotoPath,
      remotePhotoPath: remotePhotoPath,
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
      'photo_path': remotePhotoPath, // Supabase stores remote URL only
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'device_id': deviceId,
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

    // Backward compatibility: migrate old photo_path to remote
    String? localPath;
    String? remotePath;
    final photoPath = json['photo_path'] as String?;
    if (photoPath != null && photoPath.isNotEmpty) {
      if (photoPath.startsWith('http')) {
        remotePath = photoPath;
      } else {
        localPath = photoPath;
      }
    }

    return Memory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      localPhotoPath: localPath,
      remotePhotoPath: remotePath,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      deviceId: json['device_id'] as String?,
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
    String? localPhotoPath,
    String? remotePhotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deviceId,
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
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      remotePhotoPath: remotePhotoPath ?? this.remotePhotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      type: type ?? this.type,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      sentiment: sentiment ?? this.sentiment,
    );
  }

  /// Check if the memory has a valid photo
  bool get hasPhoto {
    // Check local first
    if (localPhotoPath != null && localPhotoPath!.isNotEmpty) {
      if (File(localPhotoPath!).existsSync()) {
        return true;
      }
    }
    // Then check remote
    if (remotePhotoPath != null && remotePhotoPath!.isNotEmpty) {
      return true;
    }
    return false;
  }

  /// Get the photo file if it exists (only for local files)
  File? get photoFile {
    if (localPhotoPath == null || localPhotoPath!.isEmpty) {
      return null;
    }
    // For local files, check if they exist
    if (File(localPhotoPath!).existsSync()) {
      return File(localPhotoPath!);
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
    final l10n = AppLocalizations.of(context)!;

    switch (this) {
      case MemoryType.decluttering:
        return l10n.memoryTypeDecluttering;
      case MemoryType.cleaning:
        return l10n.memoryTypeCleaning;
      case MemoryType.custom:
        return l10n.memoryTypeCustom;
      case MemoryType.grateful:
        return l10n.memoryTypeGrateful;
      case MemoryType.lesson:
        return l10n.memoryTypeLesson;
      case MemoryType.celebrate:
        return l10n.memoryTypeCelebrate;
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
