import 'package:flutter/material.dart';

enum DeclutterCategory {
  clothes('Clothes', '衣物'),
  booksDocuments('Books & Documents', '书籍/文档'),
  electronics('Electronics', '电子产品'),
  beauty('Beauty', '美妆用品'),
  sentimental('Sentimental', '情感纪念品'),
  miscellaneous('Miscellaneous', '杂项');

  const DeclutterCategory(this.english, this.chinese);
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

enum DeclutterStatus {
  keep('Kept', '保留'),
  discard('Discarded', '丢弃'),
  donate('Donated', '捐赠'),
  recycle('Recycled', '回收'),
  resell('Resell', '转售');

  const DeclutterStatus(this.english, this.chinese);
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

enum PurchaseReview {
  worthIt('Worth it', '值得购买'),
  wouldBuyAgain('Would buy again', '会再入手'),
  neutral('Neutral', '无感'),
  wasteMoney('Waste of money', '浪费金钱');

  const PurchaseReview(this.english, this.chinese);
  final String english;
  final String chinese;

  String label(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return chinese;
    }
    return english;
  }

  String get emoji {
    switch (this) {
      case PurchaseReview.worthIt:
        return '⭐';
      case PurchaseReview.wouldBuyAgain:
        return '🔄';
      case PurchaseReview.neutral:
        return '😐';
      case PurchaseReview.wasteMoney:
        return '💸';
    }
  }
}

class DeclutterItem {
  DeclutterItem({
    required this.id,
    this.userId = 'local_user',
    required this.name,
    this.nameLocalizations,
    required this.category,
    DateTime? createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deviceId,
    required this.status,
    this.localPhotoPath,
    this.remotePhotoPath,
    this.notes,
    this.joyLevel,
    this.joyNotes,
    this.purchaseReview,
    this.reviewedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId; // Foreign key to auth.users
  final String name;
  final Map<String, String>? nameLocalizations;
  final DeclutterCategory category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt; // Soft delete timestamp
  final String? deviceId; // Device that made the last change
  final DeclutterStatus status;
  final String? localPhotoPath;
  final String? remotePhotoPath;
  final String? notes;
  final int? joyLevel; // Joy Index: 1-10 (怦然心动指数)
  final String? joyNotes; // Why it sparks joy (为什么带来快乐)
  final PurchaseReview? purchaseReview; // Purchase review (消费复盘)
  final DateTime? reviewedAt; // When the purchase was reviewed

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'name_localizations': nameLocalizations,
      'category': category.name,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
      'device_id': deviceId,
      'status': status.name,
      'photo_path': remotePhotoPath, // Supabase stores remote URL only
      'notes': notes,
      'joy_level': joyLevel,
      'joy_notes': joyNotes,
      'purchase_review': purchaseReview?.name,
      'reviewed_at': reviewedAt?.toUtc().toIso8601String(),
    };
  }

  // Create from JSON from Supabase
  factory DeclutterItem.fromJson(Map<String, dynamic> json) {
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

    return DeclutterItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      nameLocalizations: (json['name_localizations'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key.toString(), value.toString())),
      category: DeclutterCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String).toLocal()
          : null,
      deviceId: json['device_id'] as String?,
      status: DeclutterStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      localPhotoPath: localPath,
      remotePhotoPath: remotePath,
      notes: json['notes'] as String?,
      joyLevel: json['joy_level'] as int?,
      joyNotes: json['joy_notes'] as String?,
      purchaseReview: json['purchase_review'] != null
          ? PurchaseReview.values.firstWhere(
              (e) => e.name == json['purchase_review'],
            )
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String).toLocal()
          : null,
    );
  }

  DeclutterItem copyWith({
    String? id,
    String? userId,
    String? name,
    Map<String, String>? nameLocalizations,
    DeclutterCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deviceId,
    DeclutterStatus? status,
    String? localPhotoPath,
    String? remotePhotoPath,
    String? notes,
    int? joyLevel,
    String? joyNotes,
    PurchaseReview? purchaseReview,
    DateTime? reviewedAt,
  }) {
    return DeclutterItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      nameLocalizations: nameLocalizations ?? this.nameLocalizations,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      remotePhotoPath: remotePhotoPath ?? this.remotePhotoPath,
      notes: notes ?? this.notes,
      joyLevel: joyLevel ?? this.joyLevel,
      joyNotes: joyNotes ?? this.joyNotes,
      purchaseReview: purchaseReview ?? this.purchaseReview,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}

extension DeclutterItemLocalization on DeclutterItem {
  String displayName(BuildContext context) {
    return displayNameForLocale(Localizations.localeOf(context));
  }

  String displayNameForLocale(Locale locale) {
    final normalized = _normalizeLocale(locale);
    if (nameLocalizations == null || nameLocalizations!.isEmpty) {
      return name;
    }

    final directMatch = nameLocalizations![normalized];
    if (directMatch != null && directMatch.isNotEmpty) {
      return directMatch;
    }

    final baseMatch = nameLocalizations![locale.languageCode.toLowerCase()];
    if (baseMatch != null && baseMatch.isNotEmpty) {
      return baseMatch;
    }

    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      final zhEntry = nameLocalizations!.entries.firstWhere(
        (entry) =>
            entry.key.toLowerCase().startsWith('zh') && entry.value.isNotEmpty,
        orElse: () => MapEntry('', ''),
      );
      if (zhEntry.key.isNotEmpty) {
        return zhEntry.value;
      }
    }

    return nameLocalizations!['en'] ??
        nameLocalizations!.values.firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => name,
        );
  }

  Map<String, String> updatedLocalizationsForLocale(
    Locale locale,
    String value,
  ) {
    final normalized = _normalizeLocale(locale);
    final base = locale.languageCode.toLowerCase();
    return {
      if (nameLocalizations != null) ...nameLocalizations!,
      base: value,
      normalized: value,
    }..removeWhere((key, val) => val.isEmpty);
  }

  static String _normalizeLocale(Locale locale) {
    final language = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toLowerCase();
    return country == null || country.isEmpty ? language : '$language-$country';
  }
}
