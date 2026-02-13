import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';

class UnifiedReportData {
  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<Memory> memories;
  final List<DeepCleaningSession> deepCleaningSessions;
  final int year;

  const UnifiedReportData({
    required this.declutteredItems,
    required this.resellItems,
    required this.memories,
    required this.deepCleaningSessions,
    required this.year,
  });

  List<DeclutterItem> get yearlyDeclutteredItems => declutteredItems
      .where((item) => item.createdAt.year == year)
      .toList();

  List<ResellItem> get yearlyResellItems => resellItems
      .where((item) => item.createdAt.year == year)
      .toList();

  List<Memory> get yearlyMemories => memories
      .where((m) => m.createdAt.year == year)
      .toList();

  List<DeepCleaningSession> get yearlyDeepCleaningSessions => deepCleaningSessions
      .where((s) => s.startTime.year == year)
      .toList();

  DeclutterStats get declutterStats => DeclutterStats.fromItems(yearlyDeclutteredItems);
  MemoryStats get memoryStats => MemoryStats.fromMemories(yearlyMemories);
  ResellStats get resellStats => ResellStats.fromItems(yearlyResellItems, declutteredItems);
  DeepCleaningStats get deepCleaningStats => DeepCleaningStats.fromSessions(yearlyDeepCleaningSessions);

  bool get hasAnyData => yearlyDeclutteredItems.isNotEmpty ||
      yearlyResellItems.isNotEmpty ||
      yearlyMemories.isNotEmpty ||
      yearlyDeepCleaningSessions.isNotEmpty;
}

class DeclutterStats {
  final int totalItems;
  final int keptCount;
  final int resellCount;
  final int donateCount;
  final int recycleCount;
  final int discardCount;
  final double joyRate;
  final int joyCount;
  final Map<DeclutterCategory, int> categoryDistribution;
  final Map<int, int> monthlyDistribution;

  const DeclutterStats({
    required this.totalItems,
    required this.keptCount,
    required this.resellCount,
    required this.donateCount,
    required this.recycleCount,
    required this.discardCount,
    required this.joyRate,
    required this.joyCount,
    required this.categoryDistribution,
    required this.monthlyDistribution,
  });

  factory DeclutterStats.fromItems(List<DeclutterItem> items) {
    final categoryDistribution = <DeclutterCategory, int>{};
    final monthlyDistribution = <int, int>{};
    
    int keptCount = 0, resellCount = 0, donateCount = 0, recycleCount = 0, discardCount = 0;
    int joyCount = 0, totalWithJoy = 0;

    for (final item in items) {
      switch (item.status) {
        case DeclutterStatus.keep: keptCount++;
        case DeclutterStatus.resell: resellCount++;
        case DeclutterStatus.donate: donateCount++;
        case DeclutterStatus.recycle: recycleCount++;
        case DeclutterStatus.discard: discardCount++;
      }
      categoryDistribution[item.category] = (categoryDistribution[item.category] ?? 0) + 1;
      monthlyDistribution[item.createdAt.month] = (monthlyDistribution[item.createdAt.month] ?? 0) + 1;
      
      if (item.joyLevel != null) {
        totalWithJoy++;
        if (item.joyLevel! >= 6) joyCount++;
      }
    }

    final joyRate = totalWithJoy > 0 ? (joyCount / totalWithJoy * 100) : 0.0;

    return DeclutterStats(
      totalItems: items.length,
      keptCount: keptCount,
      resellCount: resellCount,
      donateCount: donateCount,
      recycleCount: recycleCount,
      discardCount: discardCount,
      joyRate: joyRate,
      joyCount: joyCount,
      categoryDistribution: categoryDistribution,
      monthlyDistribution: monthlyDistribution,
    );
  }

  int get processedCount => resellCount + donateCount + recycleCount + discardCount;
}

class MemoryStats {
  final int totalCount;
  final int totalPhotos;
  final Map<MemorySentiment, int> sentimentDistribution;
  final Map<int, int> monthlyDistribution;
  final MemorySentiment? topSentiment;

  const MemoryStats({
    required this.totalCount,
    required this.totalPhotos,
    required this.sentimentDistribution,
    required this.monthlyDistribution,
    this.topSentiment,
  });

  factory MemoryStats.fromMemories(List<Memory> memories) {
    final sentimentDistribution = <MemorySentiment, int>{};
    final monthlyDistribution = <int, int>{};
    MemorySentiment? topSentiment;
    int maxCount = 0;
    int totalPhotos = 0;

    for (final memory in memories) {
      if (memory.localPhotoPath != null || memory.remotePhotoPath != null) totalPhotos++;
      
      if (memory.sentiment != null) {
        final count = (sentimentDistribution[memory.sentiment!] ?? 0) + 1;
        sentimentDistribution[memory.sentiment!] = count;
        if (count > maxCount) {
          maxCount = count;
          topSentiment = memory.sentiment;
        }
      }
      
      monthlyDistribution[memory.createdAt.month] = (monthlyDistribution[memory.createdAt.month] ?? 0) + 1;
    }

    return MemoryStats(
      totalCount: memories.length,
      totalPhotos: totalPhotos,
      sentimentDistribution: sentimentDistribution,
      monthlyDistribution: monthlyDistribution,
      topSentiment: topSentiment,
    );
  }
}

class ResellStats {
  final int totalItems;
  final int soldCount;
  final int listingCount;
  final int toSellCount;
  final double totalRevenue;
  final double averageSoldPrice;
  final double successRate;
  final Map<int, double> monthlyRevenue;

  const ResellStats({
    required this.totalItems,
    required this.soldCount,
    required this.listingCount,
    required this.toSellCount,
    required this.totalRevenue,
    required this.averageSoldPrice,
    required this.successRate,
    required this.monthlyRevenue,
  });

  factory ResellStats.fromItems(List<ResellItem> items, List<DeclutterItem> allDeclutterItems) {
    int soldCount = 0, listingCount = 0, toSellCount = 0;
    double totalRevenue = 0;
    final monthlyRevenue = <int, double>{};

    for (final item in items) {
      switch (item.status) {
        case ResellStatus.sold:
          soldCount++;
          if (item.soldPrice != null) {
            totalRevenue += item.soldPrice!;
            final month = item.soldDate?.month ?? item.createdAt.month;
            monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + item.soldPrice!;
          }
        case ResellStatus.listing: listingCount++;
        case ResellStatus.toSell: toSellCount++;
      }
    }

    final successRate = items.isNotEmpty ? (soldCount / items.length * 100) : 0.0;
    final averageSoldPrice = soldCount > 0 ? totalRevenue / soldCount : 0.0;

    return ResellStats(
      totalItems: items.length,
      soldCount: soldCount,
      listingCount: listingCount,
      toSellCount: toSellCount,
      totalRevenue: totalRevenue,
      averageSoldPrice: averageSoldPrice,
      successRate: successRate,
      monthlyRevenue: monthlyRevenue,
    );
  }
}

class DeepCleaningStats {
  final int totalSessions;
  final int totalDurationMinutes;
  final Map<String, int> areaSessions;

  const DeepCleaningStats({
    required this.totalSessions,
    required this.totalDurationMinutes,
    required this.areaSessions,
  });

  factory DeepCleaningStats.fromSessions(List<DeepCleaningSession> sessions) {
    final areaSessions = <String, int>{};
    int totalDuration = 0;

    for (final session in sessions) {
      areaSessions[session.area] = (areaSessions[session.area] ?? 0) + 1;
      if (session.elapsedSeconds != null) totalDuration += session.elapsedSeconds! ~/ 60;
    }

    return DeepCleaningStats(
      totalSessions: sessions.length,
      totalDurationMinutes: totalDuration,
      areaSessions: areaSessions,
    );
  }
}
