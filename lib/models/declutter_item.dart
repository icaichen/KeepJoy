import 'package:flutter/material.dart';

enum DeclutterCategory {
  clothes('Clothes', '衣物'),
  books('Books', '书籍'),
  papers('Papers', '文件'),
  miscellaneous('Miscellaneous', '杂项'),
  sentimental('Sentimental', '情感纪念品'),
  beauty('Beauty', '美妆用品');

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
  pending('To declutter', '待整理'),
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
    required this.category,
    DateTime? createdAt,
    this.updatedAt,
    required this.status,
    this.photoPath,
    this.notes,
    this.joyLevel,
    this.joyNotes,
    this.purchaseReview,
    this.reviewedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId; // Foreign key to auth.users
  final String name;
  final DeclutterCategory category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DeclutterStatus status;
  final String? photoPath;
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
      'category': category.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status.name,
      'photo_path': photoPath,
      'notes': notes,
      'joy_level': joyLevel,
      'joy_notes': joyNotes,
      'purchase_review': purchaseReview?.name,
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  // Create from JSON from Supabase
  factory DeclutterItem.fromJson(Map<String, dynamic> json) {
    return DeclutterItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: DeclutterCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      status: DeclutterStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      photoPath: json['photo_path'] as String?,
      notes: json['notes'] as String?,
      joyLevel: json['joy_level'] as int?,
      joyNotes: json['joy_notes'] as String?,
      purchaseReview: json['purchase_review'] != null
          ? PurchaseReview.values.firstWhere(
              (e) => e.name == json['purchase_review'],
            )
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  DeclutterItem copyWith({
    String? id,
    String? userId,
    String? name,
    DeclutterCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DeclutterStatus? status,
    String? photoPath,
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
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      joyLevel: joyLevel ?? this.joyLevel,
      joyNotes: joyNotes ?? this.joyNotes,
      purchaseReview: purchaseReview ?? this.purchaseReview,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
