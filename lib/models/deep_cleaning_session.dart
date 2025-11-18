import 'package:flutter/material.dart';

enum CleaningArea {
  livingRoom('Living Room', '客厅', 'living_room'),
  bedroom('Bedroom', '卧室', 'bedroom'),
  wardrobe('Wardrobe', '衣柜', 'wardrobe'),
  bookshelf('Bookshelf', '书柜', 'bookshelf'),
  kitchen('Kitchen', '厨房', 'kitchen'),
  desk('Desk', '书桌', 'desk');

  const CleaningArea(this.english, this.chinese, this.key);
  final String english;
  final String chinese;
  final String key;

  String label(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return chinese;
    }
    return english;
  }

  static CleaningArea? fromString(String value) {
    // Try to match by key first
    for (final area in CleaningArea.values) {
      if (area.key == value) return area;
    }
    // Handle old keys for backward compatibility
    if (value == 'closet') return CleaningArea.wardrobe;
    if (value == 'study') return CleaningArea.bookshelf;
    if (value == 'bathroom') return null; // Bathroom was removed, no direct mapping

    // Try to match by English or Chinese name (for backward compatibility)
    for (final area in CleaningArea.values) {
      if (area.english == value || area.chinese == value) return area;
    }

    // Additional backward compatibility for old string values
    if (value == 'Closet' || value == '衣柜') return CleaningArea.wardrobe;
    if (value == 'Study' || value == '书房') return CleaningArea.bookshelf;

    return null;
  }

  static String getDisplayName(String storedValue, BuildContext context) {
    final area = fromString(storedValue);
    if (area != null) {
      return area.label(context);
    }
    // Fallback to stored value if no match found
    return storedValue;
  }
}

class DeepCleaningSession {
  final String id;
  final String userId; // Foreign key to auth.users
  final String area;
  final DateTime startTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? beforePhotoPath;
  String? afterPhotoPath;
  int? elapsedSeconds;
  int? itemsCount;
  int? focusIndex; // 1-10
  int? moodIndex; // 1-10
  double? beforeMessinessIndex; // AI analysis
  double? afterMessinessIndex; // AI analysis

  DeepCleaningSession({
    required this.id,
    required this.userId,
    required this.area,
    required this.startTime,
    DateTime? createdAt,
    this.updatedAt,
    this.beforePhotoPath,
    this.afterPhotoPath,
    this.elapsedSeconds,
    this.itemsCount,
    this.focusIndex,
    this.moodIndex,
    this.beforeMessinessIndex,
    this.afterMessinessIndex,
  }) : createdAt = createdAt ?? startTime;

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'area': area,
      'start_time': startTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'before_photo_path': beforePhotoPath,
      'after_photo_path': afterPhotoPath,
      'elapsed_seconds': elapsedSeconds,
      'items_count': itemsCount,
      'focus_index': focusIndex,
      'mood_index': moodIndex,
      'before_messiness_index': beforeMessinessIndex,
      'after_messiness_index': afterMessinessIndex,
    };
  }

  // Create from JSON from Supabase
  factory DeepCleaningSession.fromJson(Map<String, dynamic> json) {
    return DeepCleaningSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      area: json['area'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      beforePhotoPath: json['before_photo_path'] as String?,
      afterPhotoPath: json['after_photo_path'] as String?,
      elapsedSeconds: json['elapsed_seconds'] as int?,
      itemsCount: json['items_count'] as int?,
      focusIndex: json['focus_index'] as int?,
      moodIndex: json['mood_index'] as int?,
      beforeMessinessIndex: json['before_messiness_index'] as double?,
      afterMessinessIndex: json['after_messiness_index'] as double?,
    );
  }

  DeepCleaningSession copyWith({
    String? id,
    String? userId,
    String? area,
    DateTime? startTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? beforePhotoPath,
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  }) {
    return DeepCleaningSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      area: area ?? this.area,
      startTime: startTime ?? this.startTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      beforePhotoPath: beforePhotoPath ?? this.beforePhotoPath,
      afterPhotoPath: afterPhotoPath ?? this.afterPhotoPath,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      itemsCount: itemsCount ?? this.itemsCount,
      focusIndex: focusIndex ?? this.focusIndex,
      moodIndex: moodIndex ?? this.moodIndex,
      beforeMessinessIndex: beforeMessinessIndex ?? this.beforeMessinessIndex,
      afterMessinessIndex: afterMessinessIndex ?? this.afterMessinessIndex,
    );
  }
}
