import 'dart:math' as math;

import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';

class MemoryLaneReportScreen extends StatefulWidget {
  const MemoryLaneReportScreen({super.key, required this.memories});

  final List<Memory> memories;

  @override
  State<MemoryLaneReportScreen> createState() => _MemoryLaneReportScreenState();
}

enum _ReportRange { days7, days30, yearly }

class _MemoryLaneReportScreenState extends State<MemoryLaneReportScreen> {
  final ScrollController _scrollController = ScrollController();
  _ReportRange _selectedRange = _ReportRange.yearly;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _rangeStart {
    final now = DateTime.now();
    switch (_selectedRange) {
      case _ReportRange.days7:
        return _todayStart.subtract(const Duration(days: 6));
      case _ReportRange.days30:
        return _todayStart.subtract(const Duration(days: 29));
      case _ReportRange.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime get _rangeEndExclusive {
    final now = DateTime.now();
    switch (_selectedRange) {
      case _ReportRange.days7:
      case _ReportRange.days30:
        return _todayStart.add(const Duration(days: 1));
      case _ReportRange.yearly:
        return DateTime(now.year + 1, 1, 1);
    }
  }

  String _rangeLabel(bool isChinese) {
    switch (_selectedRange) {
      case _ReportRange.days7:
        return isChinese ? '最近7天' : 'Last 7 Days';
      case _ReportRange.days30:
        return isChinese ? '最近30天' : 'Last 30 Days';
      case _ReportRange.yearly:
        return isChinese ? '每年' : 'Yearly';
    }
  }

  List<Memory> _filteredMemories() {
    final start = _rangeStart;
    final end = _rangeEndExclusive;
    return widget.memories.where((memory) {
      return !memory.createdAt.isBefore(start) &&
          memory.createdAt.isBefore(end);
    }).toList();
  }

  void _showRangeSelector(bool isChinese) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        Widget buildOption(_ReportRange range, String label) {
          final selected = _selectedRange == range;
          return ListTile(
            title: Text(
              label,
              style: ReportTextStyles.body.copyWith(
                color: ReportUI.primaryTextColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check_rounded, color: Color(0xFF0EA5E9))
                : null,
            onTap: () {
              setState(() => _selectedRange = range);
              Navigator.pop(sheetContext);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              buildOption(
                _ReportRange.days7,
                isChinese ? '最近7天' : 'Last 7 Days',
              ),
              buildOption(
                _ReportRange.days30,
                isChinese ? '最近30天' : 'Last 30 Days',
              ),
              buildOption(_ReportRange.yearly, isChinese ? '每年' : 'Yearly'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final responsive = context.responsive;
    final horizontalPadding = responsive.horizontalPadding;
    final topPadding = responsive.safeAreaPadding.top;
    final expandedHeaderHeight =
        responsive.totalTwoLineHeaderHeight +
        (responsive.isSmallDevice ? 6 : 0);
    final headerTitleSize = responsive.isSmallDevice
        ? (responsive.titleFontSize + 2)
        : responsive.largeTitleFontSize;
    final headerSubtitle = isChinese ? '回忆趋势一览' : 'Memory at a glance';
    final pageName = l10n.dashboardMemoryLaneTitle;
    final memories = _filteredMemories();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                // Background
                Container(height: 800, color: const Color(0xFFF5F5F7)),
                // Content
                Column(
                  children: [
                    SizedBox(height: expandedHeaderHeight),

                    // Main Report Content
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        36,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEmotionDistribution(
                            context,
                            isChinese,
                            memories,
                          ),
                          const SizedBox(height: ReportUI.sectionGap),
                          _buildEmotionByCategory(context, isChinese, memories),
                          const SizedBox(height: ReportUI.sectionGap),
                          _buildMemoryHeatmap(context, isChinese, memories),
                          const SizedBox(height: ReportUI.sectionGap),
                          _buildTimeMarkers(context, isChinese, memories),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                final scrollProgress =
                    (scrollOffset / responsive.twoLineHeaderContentHeight)
                        .clamp(0.0, 1.0);
                final collapsedHeaderOpacity = scrollProgress >= 1.0
                    ? 1.0
                    : 0.0;
                return IgnorePointer(
                  ignoring: collapsedHeaderOpacity < 0.5,
                  child: Opacity(opacity: collapsedHeaderOpacity, child: child),
                );
              },
              child: Container(
                height: responsive.collapsedHeaderHeight,
                padding: EdgeInsets.only(top: topPadding),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F7),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                  ),
                ),
                child: Text(
                  pageName,
                  style: TextStyle(
                    fontSize: responsive.titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                final scrollProgress =
                    (scrollOffset / responsive.twoLineHeaderContentHeight)
                        .clamp(0.0, 1.0);
                final headerOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
                return Opacity(opacity: headerOpacity, child: child);
              },
              child: Container(
                height: expandedHeaderHeight,
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: topPadding + 10,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pageName,
                            style: TextStyle(
                              fontSize: headerTitleSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            headerSubtitle,
                            style: TextStyle(
                              fontSize: responsive.captionFontSize + 1,
                              color: const Color(0xFF6B7280),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showRangeSelector(isChinese),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: ReportUI.statCardDecoration.copyWith(
                          color: Colors.white,
                          boxShadow: const [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _rangeLabel(isChinese),
                              style: ReportTextStyles.label.copyWith(
                                color: ReportUI.secondaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. EMOTION DISTRIBUTION (Pie + Legend)
  Widget _buildEmotionDistribution(
    BuildContext context,
    bool isChinese,
    List<Memory> memories,
  ) {
    final sentimentCounts = <MemorySentiment, int>{};
    for (final memory in memories) {
      if (memory.sentiment != null) {
        sentimentCounts[memory.sentiment!] =
            (sentimentCounts[memory.sentiment!] ?? 0) + 1;
      }
    }

    // Updated palette to match screenshot
    final emotionColors = {
      'happy': const Color(0xFF5ECFB8), // Teal
      'joy': const Color(0xFF5ECFB8), // Teal
      'love': const Color(0xFFB794F6), // Purple
      'nostalgia': const Color(0xFF89CFF0), // Blue
      'adventure': const Color(0xFFFFD93D), // Yellow
      'grateful': const Color(0xFFFFA07A), // Orange
      'peaceful': const Color(0xFFE0E7FF), // Light Indigo
      'sad': const Color(0xFF9CA3AF),
      'angry': const Color(0xFFFF9AA2),
      'calm': const Color(0xFFE0E7FF),
      'excited': const Color(0xFFFFA07A),
      'neutral': const Color(0xFF9CA3AF),
    };

    final emotions = [
      {
        'sentiment': MemorySentiment.happy,
        'label': MemorySentiment.happy.label(context),
        'color': emotionColors['happy']!,
      },
      {
        'sentiment': MemorySentiment.love,
        'label': MemorySentiment.love.label(context),
        'color': emotionColors['love']!,
      },
      {
        'sentiment': MemorySentiment.nostalgia,
        'label': MemorySentiment.nostalgia.label(context),
        'color': emotionColors['nostalgia']!,
      },
      {
        'sentiment': MemorySentiment.adventure,
        'label': MemorySentiment.adventure.label(context),
        'color': emotionColors['adventure']!,
      },
      {
        'sentiment': MemorySentiment.grateful,
        'label': MemorySentiment.grateful.label(context),
        'color': emotionColors['grateful']!,
      },
      {
        'sentiment': MemorySentiment.peaceful,
        'label': MemorySentiment.peaceful.label(context),
        'color': emotionColors['peaceful']!,
      },
    ];

    final totalCount = sentimentCounts.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    final hasData = totalCount > 0;

    // Calculate dominant emotion for center text
    String centerValue = '0%';
    String centerLabel = '';
    Color centerColor = const Color(0xFFB794F6);

    if (hasData) {
      MemorySentiment? maxSentiment;
      int maxCount = 0;
      for (final entry in sentimentCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          maxSentiment = entry.key;
        }
      }

      if (maxSentiment != null) {
        centerValue = '${((maxCount / totalCount) * 100).toStringAsFixed(0)}%';
        centerLabel = maxSentiment.label(context);
        // Find color
        final emotionEntry = emotions.firstWhere(
          (e) => e['sentiment'] == maxSentiment,
          orElse: () => {'color': const Color(0xFFB794F6)},
        );
        centerColor = emotionEntry['color'] as Color;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '情绪分布' : 'Emotion Distribution',
            style: ReportTextStyles.sectionHeader,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.reportPreciousMoments,
            style: ReportTextStyles.sectionSubtitle,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pie Chart
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _EmotionPieChartPainter(
                    emotions: emotions,
                    sentimentCounts: sentimentCounts,
                    totalCount: totalCount,
                    hasData: hasData,
                    centerValue: centerValue,
                    centerLabel: centerLabel,
                    centerColor: centerColor,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Legend
              Expanded(
                child: Column(
                  children: emotions.map((emotion) {
                    final sentiment = emotion['sentiment'] as MemorySentiment;
                    final count = sentimentCounts[sentiment] ?? 0;

                    final percentage = totalCount == 0
                        ? 0.0
                        : (count / totalCount * 100);
                    final color = emotion['color'] as Color;
                    final label = emotion['label'] as String;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              label,
                              style: ReportTextStyles.legendLabel.copyWith(
                                color: const Color(0xFF374151),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: ReportTextStyles.legendLabel.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. ACTIVITY BAR CHART
  Widget _buildMemoryHeatmap(
    BuildContext context,
    bool isChinese,
    List<Memory> memories,
  ) {
    final isYearly = _selectedRange == _ReportRange.yearly;
    final labels = <String>[];
    final counts = <int>[];

    if (isYearly) {
      for (var month = 1; month <= 12; month++) {
        final count = memories
            .where((memory) => memory.createdAt.month == month)
            .length;
        labels.add(isChinese ? '$month月' : _getMonthAbbrev(month));
        counts.add(count);
      }
    } else {
      if (_selectedRange == _ReportRange.days7) {
        final start = _todayStart.subtract(const Duration(days: 6));
        for (var i = 0; i < 7; i++) {
          final day = start.add(Duration(days: i));
          final dayEnd = day.add(const Duration(days: 1));
          final count = memories
              .where(
                (memory) =>
                    !memory.createdAt.isBefore(day) &&
                    memory.createdAt.isBefore(dayEnd),
              )
              .length;
          final dayLabel = '${day.month}/${day.day}';
          labels.add(dayLabel);
          counts.add(count);
        }
      } else {
        final start = _todayStart.subtract(const Duration(days: 29));
        const bucketCount = 6;
        const bucketSizeDays = 5;
        for (var bucket = 0; bucket < bucketCount; bucket++) {
          final bucketStart = start.add(
            Duration(days: bucket * bucketSizeDays),
          );
          final bucketEnd = bucket == bucketCount - 1
              ? _todayStart.add(const Duration(days: 1))
              : bucketStart.add(const Duration(days: bucketSizeDays));
          final count = memories
              .where(
                (memory) =>
                    !memory.createdAt.isBefore(bucketStart) &&
                    memory.createdAt.isBefore(bucketEnd),
              )
              .length;
          labels.add('${bucketStart.month}/${bucketStart.day}');
          counts.add(count);
        }
      }
    }

    final maxCount = counts.isEmpty ? 0 : counts.fold<int>(0, math.max);
    final peakIndex = counts.indexWhere((count) => count == maxCount);
    const chartHeight = 180.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '回忆趋势' : 'Memory Trend',
            style: ReportTextStyles.sectionHeader,
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '查看回忆记录随时间的变化节奏' : 'See memory frequency over time',
            style: ReportTextStyles.sectionSubtitle,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(counts.length, (index) {
                final count = counts[index];
                final ratio = maxCount == 0 ? 0.0 : (count / maxCount);
                final barHeight = maxCount == 0
                    ? 8.0
                    : (ratio * (chartHeight - 42)).clamp(8.0, chartHeight - 42);
                final barColor = count == 0
                    ? const Color(0xFFE5E7EB)
                    : Color.lerp(
                        const Color(0xFFBFDBFE),
                        const Color(0xFF2563EB),
                        ratio,
                      )!;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: ReportTextStyles.chartValueLabel.copyWith(
                            color: count > 0
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: index == peakIndex && count > 0
                                  ? const Color(0xFF1D4ED8)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: ReportTextStyles.chartAxisLabel,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 3. CATEGORY STATISTICS
  Widget _buildEmotionByCategory(
    BuildContext context,
    bool isChinese,
    List<Memory> memories,
  ) {
    final categoryCounts = <DeclutterCategory, int>{};
    for (final category in DeclutterCategory.values) {
      categoryCounts[category] = 0;
    }

    for (final memory in memories) {
      if (memory.category != null && memory.category!.isNotEmpty) {
        final catValue = memory.category!;
        final declutterCategory = DeclutterCategory.values.firstWhere(
          (cat) =>
              cat.name == catValue ||
              cat.english == catValue ||
              cat.chinese == catValue,
          orElse: () => DeclutterCategory.miscellaneous,
        );
        categoryCounts[declutterCategory] =
            (categoryCounts[declutterCategory] ?? 0) + 1;
      }
    }

    final sortedCategories = categoryCounts.keys.toList()
      ..sort((a, b) => categoryCounts[b]!.compareTo(categoryCounts[a]!));

    // Calculate max count for bar scaling
    final maxCount = categoryCounts.values.isEmpty
        ? 1
        : categoryCounts.values.reduce(math.max);

    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF97316), // Orange
      const Color(0xFF60A5FA), // Light Blue
      const Color(0xFFFBBF24), // Yellow
      const Color(0xFF10B981), // Green
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF6B7280), // Gray
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '回忆分类统计' : 'Memory Category Statistics',
            style: ReportTextStyles.sectionHeader,
          ),
          const SizedBox(height: 4),
          Text(
            isChinese
                ? '了解不同物品品类承载的回忆分布'
                : 'Understand which item categories hold most memories',
            style: ReportTextStyles.sectionSubtitle,
          ),
          const SizedBox(height: 4),

          if (sortedCategories.every((c) => (categoryCounts[c] ?? 0) == 0))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  isChinese ? '暂无分类数据' : 'No category data yet',
                  style: ReportTextStyles.sectionSubtitle,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
                childAspectRatio: 3.4,
              ),
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                final category = sortedCategories[index];
                final count = categoryCounts[category] ?? 0;
                // Skip if count is 0? The screenshot showed all categories, or top ones.
                // Let's show all for now as per "Category Statistics" section usually implies full view or top view.
                // If the user wants to hide 0s, we can filter. But grid looks better filled.

                final barValue = maxCount == 0
                    ? 0.0
                    : (count / maxCount).clamp(0.0, 1.0);
                final color = colors[index % colors.length];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.label(context),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: barValue,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // 4. ANNUAL MEMORY (Time Markers, Redesigned)
  Widget _buildTimeMarkers(
    BuildContext context,
    bool isChinese,
    List<Memory> memories,
  ) {
    final sortedMemories = memories.isEmpty
        ? <Memory>[]
        : (List<Memory>.from(memories)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));

    Memory? firstMemory = sortedMemories.isNotEmpty
        ? sortedMemories.first
        : null;
    Memory? latestMemory = sortedMemories.isNotEmpty
        ? sortedMemories.last
        : null;

    // Find longest story (by description length)
    Memory? longestStory;
    int maxLength = 0;
    for (final memory in memories) {
      final length =
          (memory.description?.length ?? 0) + (memory.notes?.length ?? 0);
      if (length > maxLength) {
        maxLength = length;
        longestStory = memory;
      }
    }

    // Calculate total days
    final totalDays = (firstMemory != null && latestMemory != null)
        ? latestMemory.createdAt.difference(firstMemory.createdAt).inDays
        : 0;

    return Container(
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '回忆长廊' : 'Memory Gallery',
            style: ReportTextStyles.sectionHeader,
          ),
          const SizedBox(height: 4),
          Text(
            isChinese
                ? '把值得珍藏的片段，串成一条温柔而清晰的时间线。'
                : 'A gentle, clear timeline of the moments worth keeping.',
            style: ReportTextStyles.sectionSubtitle,
          ),
          const SizedBox(height: 24),

          if (memories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  isChinese ? '暂无回忆记录' : 'No memory records yet',
                  style: ReportTextStyles.body,
                ),
              ),
            )
          else ...[
            // Build timeline entries
            ..._buildTimelineEntries(
              context,
              isChinese: isChinese,
              memories: memories,
              firstMemory: firstMemory!,
              latestMemory: latestMemory!,
              longestStory: longestStory,
              totalDays: totalDays,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTimelineEntries(
    BuildContext context, {
    required bool isChinese,
    required List<Memory> memories,
    required Memory firstMemory,
    required Memory latestMemory,
    Memory? longestStory,
    required int totalDays,
  }) {
    final accent = const Color(0xFF6F92C9);
    final items = <_TimelineItem>[
      _TimelineItem(
        label: l10n.reportFirstMemoryLabel,
        title: firstMemory.title,
        date: _formatDate(firstMemory.createdAt, isChinese),
        icon: Icons.flag_rounded,
      ),
    ];

    if (longestStory != null &&
        longestStory != firstMemory &&
        longestStory != latestMemory) {
      items.add(
        _TimelineItem(
          label: l10n.reportLongestStoryLabel,
          title: longestStory.title,
          date: _formatDate(longestStory.createdAt, isChinese),
          icon: Icons.history_edu_rounded,
        ),
      );
    }

    if (latestMemory != firstMemory) {
      items.add(
        _TimelineItem(
          label: l10n.reportLatestMemoryLabel,
          title: latestMemory.title,
          date: _formatDate(latestMemory.createdAt, isChinese),
          icon: Icons.auto_awesome_rounded,
        ),
      );
    }

    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      widgets.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline rail
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: ReportUI.borderSideColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  padding: const EdgeInsets.all(14),
                  decoration: ReportUI.statCardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(item.icon, size: 14, color: accent),
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: ReportTextStyles.label.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: ReportTextStyles.body.copyWith(
                          color: ReportUI.primaryTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.date,
                        style: ReportTextStyles.label.copyWith(
                          color: ReportUI.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Journey summary at bottom
    widgets.add(const SizedBox(height: 14));
    widgets.add(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ReportUI.statCardDecoration,
        child: Row(
          children: [
            Icon(Icons.timelapse_rounded, size: 18, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.reportMemoryJourneyDetail(
                  totalDays.toString(),
                  memories.length.toString(),
                ),
                style: ReportTextStyles.body.copyWith(
                  color: ReportUI.primaryTextColor,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return widgets;
  }

  String _formatDate(DateTime date, bool isChinese) {
    if (isChinese) {
      return '${date.year}年${date.month}月${date.day}日';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getMonthAbbrev(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // ignore: unused_element
  Widget _buildEmotionDonut({
    required BuildContext context,
    required double chartSize,
    required List<Map<String, dynamic>> emotions,
    required Map<MemorySentiment, int> sentimentCounts,
    required int totalCount,
    required bool hasData,
    required bool isChinese,
  }) {
    final theme = Theme.of(context);
    final emptyTitle = isChinese ? '暂无回忆数据' : 'No memories yet';
    final emptySubtitle = isChinese
        ? '创建一些回忆后即可看到情绪分布。'
        : 'Create some memories to see the emotion breakdown.';
    final totalLabel = isChinese ? '条回忆' : 'memories';

    final innerWidth = chartSize * 0.65;

    // Create slices list with only emotions that have count > 0
    final slices = hasData
        ? emotions.where((emotion) {
            final sentiment = emotion['sentiment'] as MemorySentiment;
            final count = sentimentCounts[sentiment] ?? 0;
            return count > 0;
          }).toList()
        : <Map<String, dynamic>>[];

    return SizedBox(
      width: chartSize,
      height: chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(chartSize),
            painter: _EmotionDonutPainter(
              emotions: slices,
              sentimentCounts: sentimentCounts,
              totalCount: totalCount,
              hasData: hasData,
              isChinese: isChinese,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: hasData
                ? SizedBox(
                    key: const ValueKey('emotionData'),
                    width: innerWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalCount',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalLabel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('emotionEmpty'),
                    width: innerWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emptyTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          emptySubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionLegend({
    required List<Map<String, dynamic>> emotions,
    required Map<MemorySentiment, int> sentimentCounts,
    required int totalCount,
    required bool isChinese,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 2 * 12) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: emotions.map((emotion) {
            final count =
                sentimentCounts[emotion['sentiment'] as MemorySentiment] ?? 0;
            final label = emotion['label'] as String;
            final color = emotion['color'] as Color;

            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ReportTextStyles.label,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$count', style: ReportTextStyles.statValueSmall),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// PROPER VERTICAL BAR CHART PAINTER
// ignore: unused_element
class _VerticalBarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> emotions;
  final Map<MemorySentiment, int> sentimentCounts;
  final bool isChinese;

  _VerticalBarChartPainter({
    required this.emotions,
    required this.sentimentCounts,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const labelColumnWidth = 92.0;
    const countColumnWidth = 40.0;
    const leftPadding = 20.0;
    const rightPadding = 24.0;
    const topPadding = 24.0;
    const bottomPadding = 24.0;

    final barStartX = leftPadding + labelColumnWidth + countColumnWidth + 12;
    final chartWidth = size.width - barStartX - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final maxCount = sentimentCounts.values.isEmpty
        ? 1
        : sentimentCounts.values.reduce((a, b) => a > b ? a : b);

    final barSpacing = chartHeight / emotions.length;
    final barHeight = barSpacing * 0.55;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Grid only across bar area
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final x = barStartX + (chartWidth * i / 4);
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, size.height - bottomPadding),
        gridPaint,
      );
    }

    for (int i = 0; i < emotions.length; i++) {
      final emotion = emotions[i];
      final sentiment = emotion['sentiment'] as MemorySentiment;
      final count = sentimentCounts[sentiment] ?? 0;
      final color = emotion['color'] as Color;

      final normalizedWidth = maxCount > 0 ? (count / maxCount) : 0.0;
      final proposedWidth = normalizedWidth * chartWidth;
      final barWidth = count == 0 ? 8.0 : proposedWidth.clamp(18.0, chartWidth);
      final y = topPadding + (i * barSpacing) + (barSpacing - barHeight) / 2;

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barStartX, y, barWidth, barHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(barRect, Paint()..color = color);

      // dot
      final dotCenter = Offset(leftPadding + 6, y + barHeight / 2);
      canvas.drawCircle(dotCenter, 5, Paint()..color = color);

      // label text
      final label = emotion['label'] as String;
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: const Color(0xFF4B5563),
          fontSize: isChinese ? 12 : 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout(maxWidth: labelColumnWidth - 16);
      textPainter.paint(
        canvas,
        Offset(dotCenter.dx + 10, y + (barHeight - textPainter.height) / 2),
      );

      // count column
      final countText = count.toString();
      final fitsInside = barWidth > 50;
      textPainter.text = TextSpan(
        text: countText,
        style: TextStyle(
          color: fitsInside ? Colors.white : const Color(0xFF1F2937),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();

      final countX = fitsInside
          ? barStartX + barWidth - textPainter.width - 8
          : barStartX + barWidth + 8;
      final countY = y + (barHeight - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(countX, countY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ignore: unused_element
Widget _buildCategoryStatRow(
  BuildContext context, {
  required DeclutterCategory category,
  required int count,
  required int maxCount,
}) {
  final ratio = maxCount == 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.label(context),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFB794F6),
                      const Color(0xFF7C3AED).withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// MONTHLY HEATMAP PAINTER (12 squares, 2 rows x 6 cols)
// ignore: unused_element
class _MonthlyHeatmapPainter extends CustomPainter {
  final Map<String, int> monthlyData;
  final int maxCount;
  final bool isChinese;

  _MonthlyHeatmapPainter({
    required this.monthlyData,
    required this.maxCount,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 40.0;
    const cellGap = 8.0;
    const monthsToShow = 12;
    const cols = 6; // 6 months per row, 2 rows total

    final now = DateTime.now();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Calculate starting position to center the grid
    final totalWidth = (cellSize * cols) + (cellGap * (cols - 1));
    final startX = (size.width - totalWidth) / 2;

    // Draw 12 month squares in 2 rows, 6 columns (months 1-12)
    for (int i = 0; i < monthsToShow; i++) {
      final month = i + 1; // 1-12
      final monthDate = DateTime(now.year, month, 1);
      final monthKey =
          '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      final count = monthlyData[monthKey] ?? 0;

      // Calculate row and column
      final row = i ~/ cols;
      final col = i % cols;

      // Calculate position
      final x = startX + (col * (cellSize + cellGap));
      final y = 10.0 + (row * (cellSize + cellGap + 20)); // 20 extra for label

      // Calculate color intensity
      final intensity = maxCount > 0 ? (count / maxCount).toDouble() : 0.0;
      final color = Color.lerp(
        const Color(0xFFF2E8FF),
        const Color(0xFF8B5CF6),
        intensity,
      )!;

      // Draw cell
      final paint = Paint()..color = color;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cellSize, cellSize),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, paint);

      // Draw month label below
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final monthLabel = isChinese
          ? '${monthDate.month}月'
          : months[monthDate.month - 1];

      textPainter.text = TextSpan(
        text: monthLabel,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (cellSize - textPainter.width) / 2, y + cellSize + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// CATEGORY VERTICAL BAR CHART PAINTER
// ignore: unused_element
class _CategoryVerticalBarChartPainter extends CustomPainter {
  final List<DeclutterCategory> categories;
  final Map<DeclutterCategory, int> counts;
  final bool isChinese;

  _CategoryVerticalBarChartPainter({
    required this.categories,
    required this.counts,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 16.0;
    const bottomPadding = 80.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding - bottomPadding;
    final double barWidth = categories.isEmpty
        ? 0.0
        : (chartWidth / categories.length) * 0.7;
    final double barSpacing = categories.isEmpty
        ? 0.0
        : chartWidth / categories.length;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final colors = [
      const Color(0xFF5ECFB8),
      const Color(0xFFFF9AA2),
      const Color(0xFFFFD93D),
      const Color(0xFF89CFF0),
      const Color(0xFFB794F6),
      const Color(0xFFFF6B6B),
    ];

    if (categories.isEmpty || counts.isEmpty) {
      return;
    }
    final maxCount = counts.values.reduce((a, b) => a > b ? a : b);

    // Grid lines for context
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = padding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final count = counts[category]!;
      final normalizedHeight = maxCount == 0 ? 0.0 : count / maxCount;
      final barHeight = (normalizedHeight * chartHeight)
          .clamp(4.0, chartHeight)
          .toDouble();
      final x = padding + (barSpacing * i) + (barSpacing - barWidth) / 2;
      final y = padding + chartHeight - barHeight;

      final barPaint = Paint()..color = colors[i % colors.length];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(8),
        ),
        barPaint,
      );

      // Count label (统一置于柱体上方，深色文字)
      textPainter.text = TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: const Color(0xFF111827),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      final countY = y - textPainter.height - 4;
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, countY),
      );

      // Category label
      textPainter.text = TextSpan(
        text: isChinese ? category.chinese : category.english,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout(maxWidth: barSpacing);
      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainter.width / 2,
          size.height - bottomPadding + 24,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _EmotionDonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> emotions;
  final Map<MemorySentiment, int> sentimentCounts;
  final int totalCount;
  final bool hasData;
  final bool isChinese;

  _EmotionDonutPainter({
    required this.emotions,
    required this.sentimentCounts,
    required this.totalCount,
    required this.hasData,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.25;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFE0F7FA).withValues(alpha: 0.5);

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);

    if (!hasData || totalCount <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    for (final emotion in emotions) {
      final sentiment = emotion['sentiment'] as MemorySentiment;
      final count = sentimentCounts[sentiment] ?? 0;
      if (count <= 0) continue;

      final sweepAngle = (count / totalCount) * math.pi * 2;
      paint.color = emotion['color'] as Color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TimelineItem {
  final String label;
  final String title;
  final String date;
  final IconData icon;

  _TimelineItem({
    required this.label,
    required this.title,
    required this.date,
    required this.icon,
  });
}

class _EmotionPieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> emotions;
  final Map<MemorySentiment, int> sentimentCounts;
  final int totalCount;
  final bool hasData;
  final String centerValue;
  final String centerLabel;
  final Color centerColor;

  _EmotionPieChartPainter({
    required this.emotions,
    required this.sentimentCounts,
    required this.totalCount,
    required this.hasData,
    required this.centerValue,
    required this.centerLabel,
    required this.centerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (!hasData) {
      final grayPaint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, grayPaint);

      // Draw center hole
      final holePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white;
      canvas.drawCircle(center, radius * 0.6, holePaint);
      return;
    }

    double startAngle = -math.pi / 2;

    for (final emotion in emotions) {
      final sentiment = emotion['sentiment'] as MemorySentiment;
      final count = sentimentCounts[sentiment] ?? 0;
      final color = emotion['color'] as Color;

      if (count <= 0) continue;

      final sweepAngle = (count / totalCount) * 2 * math.pi;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // Draw border
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 2;
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      startAngle += sweepAngle;
    }

    // Draw center hole for donut effect
    final holePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, holePaint);

    // Draw Center Text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Percentage
    textPainter.text = TextSpan(
      text: centerValue,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: centerColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 - 8,
      ),
    );

    // Label
    textPainter.text = TextSpan(
      text: centerLabel,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: centerColor.withValues(alpha: 0.8),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
