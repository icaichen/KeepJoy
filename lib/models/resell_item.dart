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
    required this.declutterItemId,
    required this.status,
    required this.createdAt,
    this.platform,
    this.sellingPrice,
    this.soldPrice,
    this.soldDate,
  });

  final String id;
  final String declutterItemId; // Reference to DeclutterItem
  final ResellStatus status;
  final ResellPlatform? platform; // Set when status = listing
  final double? sellingPrice; // Optional: set when status = listing
  final double? soldPrice; // Required when status = sold
  final DateTime? soldDate; // Auto-set when status = sold
  final DateTime createdAt;

  ResellItem copyWith({
    String? id,
    String? declutterItemId,
    ResellStatus? status,
    ResellPlatform? platform,
    double? sellingPrice,
    double? soldPrice,
    DateTime? soldDate,
    DateTime? createdAt,
  }) {
    return ResellItem(
      id: id ?? this.id,
      declutterItemId: declutterItemId ?? this.declutterItemId,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      soldPrice: soldPrice ?? this.soldPrice,
      soldDate: soldDate ?? this.soldDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
