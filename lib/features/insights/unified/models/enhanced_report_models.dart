import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';

/// Enhanced unified report data with comprehensive analytics
class EnhancedUnifiedReportData {
  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<Memory> memories;
  final List<DeepCleaningSession> deepCleaningSessions;
  final int year;

  const EnhancedUnifiedReportData({
    required this.declutteredItems,
    required this.resellItems,
    required this.memories,
    required this.deepCleaningSessions,
    required this.year,
  });

  // Filtered data for selected year
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

  // Stats getters
  EnhancedDeclutterStats get declutterStats => 
      EnhancedDeclutterStats.fromItems(yearlyDeclutteredItems);
  EnhancedMemoryStats get memoryStats => 
      EnhancedMemoryStats.fromMemories(yearlyMemories);
  EnhancedResellStats get resellStats => 
      EnhancedResellStats.fromItems(yearlyResellItems, yearlyDeclutteredItems);
  DeepCleaningStats get deepCleaningStats => 
      DeepCleaningStats.fromSessions(yearlyDeepCleaningSessions);

  bool get hasAnyData => yearlyDeclutteredItems.isNotEmpty ||
      yearlyResellItems.isNotEmpty ||
      yearlyMemories.isNotEmpty ||
      yearlyDeepCleaningSessions.isNotEmpty;
}

/// Enhanced declutter statistics with comprehensive metrics
class EnhancedDeclutterStats {
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
  
  // Enhanced metrics
  final Map<PurchaseReview, int> purchaseReviewDistribution;
  final Map<int, int> joyLevelDistribution; // joyLevel -> count
  final double averageProcessingDays;
  final List<CategoryTrend> categoryTrends; // Monthly trend by category
  final List<TopCategory> topCategories; // Top categories by count
  final ProcessingEfficiency efficiency;

  const EnhancedDeclutterStats({
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
    required this.purchaseReviewDistribution,
    required this.joyLevelDistribution,
    required this.averageProcessingDays,
    required this.categoryTrends,
    required this.topCategories,
    required this.efficiency,
  });

  factory EnhancedDeclutterStats.fromItems(List<DeclutterItem> items) {
    final categoryDistribution = <DeclutterCategory, int>{};
    final monthlyDistribution = <int, int>{};
    final purchaseReviewDistribution = <PurchaseReview, int>{};
    final joyLevelDistribution = <int, int>{};
    final categoryByMonth = <DeclutterCategory, Map<int, int>>{};
    
    int keptCount = 0, resellCount = 0, donateCount = 0, 
        recycleCount = 0, discardCount = 0;
    int joyCount = 0, totalWithJoy = 0;
    int totalProcessingDays = 0;
    int processedCount = 0;

    for (final item in items) {
      // Status counts
      switch (item.status) {
        case DeclutterStatus.keep: keptCount++;
        case DeclutterStatus.resell: resellCount++;
        case DeclutterStatus.donate: donateCount++;
        case DeclutterStatus.recycle: recycleCount++;
        case DeclutterStatus.discard: discardCount++;
      }

      // Category distribution
      categoryDistribution[item.category] = 
          (categoryDistribution[item.category] ?? 0) + 1;

      // Monthly distribution
      monthlyDistribution[item.createdAt.month] = 
          (monthlyDistribution[item.createdAt.month] ?? 0) + 1;

      // Category by month for trends
      categoryByMonth.putIfAbsent(item.category, () => {});
      categoryByMonth[item.category]![item.createdAt.month] = 
          (categoryByMonth[item.category]![item.createdAt.month] ?? 0) + 1;

      // Joy level
      if (item.joyLevel != null) {
        totalWithJoy++;
        if (item.joyLevel! >= 6) joyCount++;
        joyLevelDistribution[item.joyLevel!] = 
            (joyLevelDistribution[item.joyLevel!] ?? 0) + 1;
      }

      // Purchase review
      if (item.purchaseReview != null) {
        purchaseReviewDistribution[item.purchaseReview!] = 
            (purchaseReviewDistribution[item.purchaseReview!] ?? 0) + 1;
      }

      // Processing time (for processed items)
      if (item.status != DeclutterStatus.keep && item.updatedAt != null) {
        final days = item.updatedAt!.difference(item.createdAt).inDays;
        totalProcessingDays += days;
        processedCount++;
      }
    }

    final joyRate = totalWithJoy > 0 ? (joyCount / totalWithJoy * 100) : 0.0;
    final avgProcessingDays = processedCount > 0 
        ? totalProcessingDays / processedCount 
        : 0.0;

    // Build category trends
    final trends = categoryByMonth.entries.map((entry) {
      return CategoryTrend(
        category: entry.key,
        monthlyData: entry.value,
      );
    }).toList();

    // Build top categories
    final sortedCategories = categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCats = sortedCategories.take(5).map((e) => 
      TopCategory(category: e.key, count: e.value, percentage: 
        items.isNotEmpty ? e.value / items.length * 100 : 0)
    ).toList();

    // Calculate efficiency
    final efficiency = ProcessingEfficiency(
      totalProcessed: processedCount,
      averageDays: avgProcessingDays,
      monthlyRate: items.isNotEmpty ? items.length / 12 : 0,
    );

    return EnhancedDeclutterStats(
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
      purchaseReviewDistribution: purchaseReviewDistribution,
      joyLevelDistribution: joyLevelDistribution,
      averageProcessingDays: avgProcessingDays,
      categoryTrends: trends,
      topCategories: topCats,
      efficiency: efficiency,
    );
  }

  int get processedCount => resellCount + donateCount + recycleCount + discardCount;
  int get pendingCount => totalItems - processedCount - keptCount;
}

/// Category trend data
class CategoryTrend {
  final DeclutterCategory category;
  final Map<int, int> monthlyData; // month -> count

  const CategoryTrend({
    required this.category,
    required this.monthlyData,
  });
}

/// Top category info
class TopCategory {
  final DeclutterCategory category;
  final int count;
  final double percentage;

  const TopCategory({
    required this.category,
    required this.count,
    required this.percentage,
  });
}

/// Processing efficiency metrics
class ProcessingEfficiency {
  final int totalProcessed;
  final double averageDays;
  final double monthlyRate;

  const ProcessingEfficiency({
    required this.totalProcessed,
    required this.averageDays,
    required this.monthlyRate,
  });
}

/// Enhanced memory statistics
class EnhancedMemoryStats {
  final int totalCount;
  final int totalPhotos;
  final int totalVideos;
  final int photoCount;
  final int videoCount;
  final int textCount;
  final int mixedCount;
  final int locationsCount;
  final int tagsCount;
  final int favoriteCount;
  final Map<String, int> emotionDistribution;
  final Map<String, int> tagDistribution;
  final Map<int, int> hourlyDistribution;
  final Map<int, int> monthlyCount;
  final MonthlyComparison monthlyComparison;

  const EnhancedMemoryStats({
    required this.totalCount,
    required this.totalPhotos,
    required this.totalVideos,
    required this.photoCount,
    required this.videoCount,
    required this.textCount,
    required this.mixedCount,
    required this.locationsCount,
    required this.tagsCount,
    required this.favoriteCount,
    required this.emotionDistribution,
    required this.tagDistribution,
    required this.hourlyDistribution,
    required this.monthlyCount,
    required this.monthlyComparison,
  });

  factory EnhancedMemoryStats.fromMemories(List<Memory> memories) {
    final emotionDistribution = <String, int>{};
    final tagDistribution = <String, int>{};
    final hourlyDistribution = <int, int>{};
    final monthlyCount = <int, int>{};
    
    int totalPhotos = 0;
    int totalVideos = 0;
    int photoCount = 0;
    int videoCount = 0;
    int textCount = 0;
    int mixedCount = 0;
    int locationsCount = 0;
    int favoriteCount = 0;

    final now = DateTime.now();
    int thisMonth = 0;
    int lastMonth = 0;

    for (final memory in memories) {
      // Count by type - Memory model only has photos currently
      if (memory.localPhotoPath != null || memory.remotePhotoPath != null) {
        photoCount++;
        totalPhotos++;
      } else if (memory.notes != null && memory.notes!.isNotEmpty) {
        textCount++;
      }

      // Emotion/Sentiment
      if (memory.sentiment != null) {
        final emotion = memory.sentiment.toString().split('.').last;
        emotionDistribution[emotion] = (emotionDistribution[emotion] ?? 0) + 1;
      }

      // Hourly distribution
      hourlyDistribution[memory.createdAt.hour] = 
          (hourlyDistribution[memory.createdAt.hour] ?? 0) + 1;

      // Monthly count
      monthlyCount[memory.createdAt.month] = 
          (monthlyCount[memory.createdAt.month] ?? 0) + 1;

      // This month / last month
      if (memory.createdAt.year == now.year && memory.createdAt.month == now.month) {
        thisMonth++;
      } else if (memory.createdAt.year == now.year && memory.createdAt.month == now.month - 1) {
        lastMonth++;
      }
    }

    final total = memories.length;
    final avgPerMonth = total > 0 ? total / 12 : 0.0;

    return EnhancedMemoryStats(
      totalCount: total,
      totalPhotos: totalPhotos,
      totalVideos: totalVideos,
      photoCount: photoCount,
      videoCount: videoCount,
      textCount: textCount,
      mixedCount: mixedCount,
      locationsCount: locationsCount,
      tagsCount: tagDistribution.length,
      favoriteCount: favoriteCount,
      emotionDistribution: emotionDistribution,
      tagDistribution: tagDistribution,
      hourlyDistribution: hourlyDistribution,
      monthlyCount: monthlyCount,
      monthlyComparison: MonthlyComparison(
        thisMonth: thisMonth,
        lastMonth: lastMonth,
        averagePerMonth: avgPerMonth,
        totalSold: total,
      ),
    );
  }
}

/// Heatmap data point
class MemoryHeatmapData {
  final DateTime date;
  final double intensity; // 0.0 - 1.0

  const MemoryHeatmapData({
    required this.date,
    required this.intensity,
  });
}

/// Timeline item
class MemoryTimelineItem {
  final Memory memory;
  final int month;

  const MemoryTimelineItem({
    required this.memory,
    required this.month,
  });
}

/// Enhanced resell statistics
class EnhancedResellStats {
  final int totalItems;
  final int soldCount;
  final int listingCount;
  final int toSellCount;
  final double totalRevenue;
  final double successRate;
  final double averageSoldPrice;
  final double averageListedDays;
  final Map<int, double> monthlyRevenue;
  final Map<int, int> monthlySoldCount;
  
  // Enhanced metrics
  final Map<DeclutterCategory, CategoryPerformance> categoryPerformance;
  final Map<ResellPlatform, PlatformStats> platformDistribution;
  final TrendAnalysis trendAnalysis;
  final List<ResellItem> topSellingItems;
  final MonthlyComparison monthlyComparison;

  const EnhancedResellStats({
    required this.totalItems,
    required this.soldCount,
    required this.listingCount,
    required this.toSellCount,
    required this.totalRevenue,
    required this.successRate,
    required this.averageSoldPrice,
    required this.averageListedDays,
    required this.monthlyRevenue,
    required this.monthlySoldCount,
    required this.categoryPerformance,
    required this.platformDistribution,
    required this.trendAnalysis,
    required this.topSellingItems,
    required this.monthlyComparison,
  });

  factory EnhancedResellStats.fromItems(
    List<ResellItem> resellItems,
    List<DeclutterItem> declutterItems,
  ) {
    final now = DateTime.now();
    final monthlyRevenue = <int, double>{};
    final monthlySoldCount = <int, int>{};
    final categoryStats = <DeclutterCategory, _CategoryStats>{};
    final platformStats = <ResellPlatform, _PlatformStats>{};
    
    int soldCount = 0, listingCount = 0, toSellCount = 0;
    double totalRevenue = 0;
    int totalListedDays = 0;
    int soldWithDate = 0;

    final soldItems = <ResellItem>[];

    for (final item in resellItems) {
      // Status counts
      switch (item.status) {
        case ResellStatus.sold:
          soldCount++;
          soldItems.add(item);
          
          // Revenue
          final price = item.soldPrice ?? 0;
          totalRevenue += price;
          
          // Monthly revenue
          final month = item.soldDate?.month ?? item.createdAt.month;
          monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + price;
          monthlySoldCount[month] = (monthlySoldCount[month] ?? 0) + 1;

          // Listed days
          if (item.soldDate != null) {
            final days = item.soldDate!.difference(item.createdAt).inDays;
            totalListedDays += days;
            soldWithDate++;
          }

          // Category performance
          final declutterItem = declutterItems
              .where((d) => d.id == item.declutterItemId)
              .firstOrNull;
          if (declutterItem != null) {
            categoryStats.putIfAbsent(declutterItem.category, 
              () => _CategoryStats());
            categoryStats[declutterItem.category]!.soldCount++;
            categoryStats[declutterItem.category]!.revenue += price;
            categoryStats[declutterItem.category]!.totalDays += 
                item.soldDate != null 
                    ? item.soldDate!.difference(item.createdAt).inDays 
                    : 0;
          }
        case ResellStatus.listing:
          listingCount++;
          // Category stats for listed items
          final declutterItem = declutterItems
              .where((d) => d.id == item.declutterItemId)
              .firstOrNull;
          if (declutterItem != null) {
            categoryStats.putIfAbsent(declutterItem.category, 
              () => _CategoryStats());
            categoryStats[declutterItem.category]!.listedCount++;
          }
        case ResellStatus.toSell:
          toSellCount++;
      }

      // Platform distribution
      if (item.platform != null) {
        platformStats.putIfAbsent(item.platform!, () => _PlatformStats());
        if (item.status == ResellStatus.sold) {
          platformStats[item.platform!]!.soldCount++;
          platformStats[item.platform!]!.revenue += item.soldPrice ?? 0;
        }
        platformStats[item.platform!]!.totalCount++;
      }
    }

    // Calculate derived metrics
    final successRate = resellItems.isNotEmpty 
        ? (soldCount / resellItems.length * 100) 
        : 0.0;
    final avgSoldPrice = soldCount > 0 ? totalRevenue / soldCount : 0.0;
    final avgListedDays = soldWithDate > 0 
        ? totalListedDays / soldWithDate 
        : 0.0;

    // Build category performance
    final categoryPerformance = <DeclutterCategory, CategoryPerformance>{};
    categoryStats.forEach((category, stats) {
      final totalListed = stats.soldCount + stats.listedCount;
      categoryPerformance[category] = CategoryPerformance(
        category: category,
        revenue: stats.revenue,
        soldCount: stats.soldCount,
        listedCount: stats.listedCount,
        successRate: totalListed > 0 ? stats.soldCount / totalListed * 100 : 0,
        averageDays: stats.soldCount > 0 ? stats.totalDays / stats.soldCount : 0,
      );
    });

    // Build platform stats
    final platformDistribution = <ResellPlatform, PlatformStats>{};
    platformStats.forEach((platform, stats) {
      platformDistribution[platform] = PlatformStats(
        platform: platform,
        soldCount: stats.soldCount,
        totalCount: stats.totalCount,
        revenue: stats.revenue,
        successRate: stats.totalCount > 0 
            ? stats.soldCount / stats.totalCount * 100 
            : 0,
      );
    });

    // Trend analysis
    final currentMonth = now.month;
    final currentMonthRevenue = (monthlyRevenue[currentMonth] ?? 0.0).toDouble();
    final prevMonthRevenue = currentMonth > 1
        ? (monthlyRevenue[currentMonth - 1] ?? 0.0).toDouble()
        : 0.0;
    final revenueChange = prevMonthRevenue > 0.0
        ? ((currentMonthRevenue - prevMonthRevenue) / prevMonthRevenue * 100.0).toDouble()
        : (currentMonthRevenue > 0.0 ? 100.0 : 0.0);

    final trendAnalysis = TrendAnalysis(
      currentMonthRevenue: currentMonthRevenue,
      previousMonthRevenue: prevMonthRevenue,
      changePercent: revenueChange,
      isUp: revenueChange >= 0,
    );

    // Top selling items
    soldItems.sort((a, b) => (b.soldPrice ?? 0).compareTo(a.soldPrice ?? 0));
    final topSelling = soldItems.take(5).toList();

    // Monthly comparison
    final currentMonthSold = monthlySoldCount[currentMonth] ?? 0;
    final prevMonthSold = currentMonth > 1 
        ? (monthlySoldCount[currentMonth - 1] ?? 0) 
        : 0;
    final monthsElapsed = now.month;
    final avgPerMonth = monthsElapsed > 0 ? (soldCount / monthsElapsed).toDouble() : 0.0;

    final monthlyComparison = MonthlyComparison(
      thisMonth: currentMonthSold,
      lastMonth: prevMonthSold,
      averagePerMonth: avgPerMonth,
      totalSold: soldCount,
    );

    return EnhancedResellStats(
      totalItems: resellItems.length,
      soldCount: soldCount,
      listingCount: listingCount,
      toSellCount: toSellCount,
      totalRevenue: totalRevenue,
      successRate: successRate,
      averageSoldPrice: avgSoldPrice,
      averageListedDays: avgListedDays,
      monthlyRevenue: monthlyRevenue,
      monthlySoldCount: monthlySoldCount,
      categoryPerformance: categoryPerformance,
      platformDistribution: platformDistribution,
      trendAnalysis: trendAnalysis,
      topSellingItems: topSelling,
      monthlyComparison: monthlyComparison,
    );
  }
}

/// Category performance metrics
class CategoryPerformance {
  final DeclutterCategory category;
  final double revenue;
  final int soldCount;
  final int listedCount;
  final double successRate;
  final double averageDays;

  const CategoryPerformance({
    required this.category,
    required this.revenue,
    required this.soldCount,
    required this.listedCount,
    required this.successRate,
    required this.averageDays,
  });

  int get totalListed => soldCount + listedCount;
}

/// Platform statistics
class PlatformStats {
  final ResellPlatform platform;
  final int soldCount;
  final int totalCount;
  final double revenue;
  final double successRate;

  const PlatformStats({
    required this.platform,
    required this.soldCount,
    required this.totalCount,
    required this.revenue,
    required this.successRate,
  });
}

/// Trend analysis
class TrendAnalysis {
  final double currentMonthRevenue;
  final double previousMonthRevenue;
  final double changePercent;
  final bool isUp;

  const TrendAnalysis({
    required this.currentMonthRevenue,
    required this.previousMonthRevenue,
    required this.changePercent,
    required this.isUp,
  });
}

/// Monthly comparison
class MonthlyComparison {
  final int thisMonth;
  final int lastMonth;
  final double averagePerMonth;
  final int totalSold;

  const MonthlyComparison({
    required this.thisMonth,
    required this.lastMonth,
    required this.averagePerMonth,
    required this.totalSold,
  });
}

// Helper classes for calculation
class _CategoryStats {
  int soldCount = 0;
  int listedCount = 0;
  double revenue = 0;
  int totalDays = 0;
}

class _PlatformStats {
  int soldCount = 0;
  int totalCount = 0;
  double revenue = 0;
}

/// Deep cleaning statistics
class DeepCleaningStats {
  final int totalSessions;
  final int totalItems;
  final double averageItemsPerSession;
  final Duration totalTime;
  final Duration averageTimePerSession;
  final Map<int, int> monthlyDistribution;
  final Map<String, int> areaDistribution;

  const DeepCleaningStats({
    required this.totalSessions,
    required this.totalItems,
    required this.averageItemsPerSession,
    required this.totalTime,
    required this.averageTimePerSession,
    required this.monthlyDistribution,
    required this.areaDistribution,
  });

  factory DeepCleaningStats.fromSessions(List<DeepCleaningSession> sessions) {
    final monthlyDistribution = <int, int>{};
    final areaDistribution = <String, int>{};
    int totalItems = 0;
    int totalSeconds = 0;

    for (final session in sessions) {
      monthlyDistribution[session.startTime.month] = 
          (monthlyDistribution[session.startTime.month] ?? 0) + 1;
      
      if (session.itemsCount != null) {
        totalItems += session.itemsCount!;
      }
      
      if (session.elapsedSeconds != null) {
        totalSeconds += session.elapsedSeconds!;
      }
      
      areaDistribution[session.area] = (areaDistribution[session.area] ?? 0) + 1;
    }

    final totalTime = Duration(seconds: totalSeconds);
    final avgItems = sessions.isNotEmpty ? totalItems / sessions.length : 0.0;
    final avgTime = sessions.isNotEmpty 
        ? Duration(seconds: totalSeconds ~/ sessions.length) 
        : Duration.zero;

    return DeepCleaningStats(
      totalSessions: sessions.length,
      totalItems: totalItems,
      averageItemsPerSession: avgItems,
      totalTime: totalTime,
      averageTimePerSession: avgTime,
      monthlyDistribution: monthlyDistribution,
      areaDistribution: areaDistribution,
    );
  }
}
