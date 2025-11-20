import 'package:flutter/material.dart';

enum ResellStatus {
  toSell('To Sell', '待售'),
  listing('Listing', '在售'),
  sold('Sold', '售出');

  const ResellStatus(this.english, this.chinese);
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

enum ResellPlatform {
  xianyu('Xianyu', '闲鱼'),
  zhuanzhuan('Zhuanzhuan', '转转'),
  ebay('eBay', 'eBay'),
  facebookMarketplace('Facebook Marketplace', 'Facebook Marketplace'),
  craigslist('Craigslist', 'Craigslist'),
  other('Other', '其他');

  const ResellPlatform(this.english, this.chinese);
  final String english;
  final String chinese;

  String label(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return chinese;
    }
    return english;
  }

  // Get platform options based on locale
  static List<ResellPlatform> forLocale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('zh')) {
      return [xianyu, zhuanzhuan, other];
    }
    return [ebay, facebookMarketplace, craigslist, other];
  }
}

class ResellItem {
  ResellItem({
    required this.id,
    required this.userId,
    required this.declutterItemId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.platform,
    this.sellingPrice,
    this.soldPrice,
    this.soldDate,
  });

  final String id;
  final String userId; // Foreign key to auth.users
  final String declutterItemId; // Reference to DeclutterItem
  final ResellStatus status;
  final ResellPlatform? platform; // Set when status = listing
  final double? sellingPrice; // Optional: set when status = listing
  final double? soldPrice; // Required when status = sold
  final DateTime? soldDate; // Auto-set when status = sold
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'declutter_item_id': declutterItemId,
      'status': status.name,
      'platform': platform?.name,
      'selling_price': sellingPrice,
      'sold_price': soldPrice,
      'sold_date': soldDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON from Supabase
  factory ResellItem.fromJson(Map<String, dynamic> json) {
    return ResellItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      declutterItemId: json['declutter_item_id'] as String,
      status: ResellStatus.values.firstWhere((e) => e.name == json['status']),
      platform: json['platform'] != null
          ? ResellPlatform.values.firstWhere((e) => e.name == json['platform'])
          : null,
      sellingPrice: json['selling_price'] as double?,
      soldPrice: json['sold_price'] as double?,
      soldDate: json['sold_date'] != null
          ? DateTime.parse(json['sold_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  ResellItem copyWith({
    String? id,
    String? userId,
    String? declutterItemId,
    ResellStatus? status,
    ResellPlatform? platform,
    double? sellingPrice,
    double? soldPrice,
    DateTime? soldDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResellItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      declutterItemId: declutterItemId ?? this.declutterItemId,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      soldPrice: soldPrice ?? this.soldPrice,
      soldDate: soldDate ?? this.soldDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
