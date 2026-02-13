import 'dart:math' as math;

import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/theme/typography.dart';
import 'package:keepjoy_app/widgets/glass_container.dart';
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

class _MemoryLaneReportScreenState extends State<MemoryLaneReportScreen> {
  final ScrollController _scrollController = ScrollController();
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final responsive = context.responsive;
    final horizontalPadding = responsive.horizontalPadding;
    final headerHeight = responsive.totalTwoLineHeaderHeight + 12;
    final topPadding = responsive.safeAreaPadding.top;
    final colorScheme = Theme.of(context).colorScheme;
    final pageName = l10n.dashboardMemoryLaneTitle;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                // Gradient background that scrolls
                Container(
                  height: 800,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: ReportUI.memoryHeaderGradient,
                      stops: const [0.0, 0.25, 0.45],
                    ),
                  ),
                ),
                // Content on top
                Column(
                  children: [
                    // Top spacing + title
                    SizedBox(
                      height: headerHeight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: topPadding + 28,
                          bottom: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Large title on the left
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  pageName,
                                  style: ReportTextStyles.screenTitle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.dashboardMemoryLaneSubtitle,
                                  style: ReportTextStyles.screenSubtitle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Content sections
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        0,
                      ),
                      child: Column(
                        children: [
                          // 1. Category Statistics (moved to top)
                          _buildEmotionByCategory(context, isChinese),
                          const SizedBox(height: 20),

                          // 2. Memory Heatmap
                          _buildMemoryHeatmap(context, isChinese),
                          const SizedBox(height: 20),

                          // 3. Emotion Distribution (moved under heatmap)
                          _buildEmotionDistribution(context, isChinese),
                          const SizedBox(height: 20),

                          // 4. Time Markers
                          _buildTimeMarkers(context, isChinese),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Real header that appears when scrolling is complete - only this rebuilds on scroll
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
                final scrollProgress = (scrollOffset / headerHeight).clamp(
                  0.0,
                  1.0,
                );
                final realHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;
                return IgnorePointer(
                  ignoring: realHeaderOpacity < 0.5,
                  child: Opacity(opacity: realHeaderOpacity, child: child),
                );
              },
              child: Container(
                height: responsive.collapsedHeaderHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                  ),
                ),
                child: Stack(
                  children: [
                    // Back button
                    Positioned(
                      left: 0,
                      top: topPadding,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Centered title
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Text(
                          pageName,
                          style: ReportTextStyles.sectionHeader.copyWith(
                            color: Colors.black87,
                          ),
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

  // 1. PIE CHART for emotions
  Widget _buildEmotionDistribution(BuildContext context, bool isChinese) {
    final sentimentCounts = <MemorySentiment, int>{};
    for (final memory in widget.memories) {
      if (memory.sentiment != null) {
        sentimentCounts[memory.sentiment!] =
            (sentimentCounts[memory.sentiment!] ?? 0) + 1;
      }
    }

    final emotions = [
      {
        'sentiment': MemorySentiment.love,
        'label': MemorySentiment.love.label(context),
        'color': const Color(0xFFFF9AA2),
      },
      {
        'sentiment': MemorySentiment.nostalgia,
        'label': MemorySentiment.nostalgia.label(context),
        'color': const Color(0xFFFFD93D),
      },
      {
        'sentiment': MemorySentiment.adventure,
        'label': MemorySentiment.adventure.label(context),
        'color': const Color(0xFF89CFF0),
      },
      {
        'sentiment': MemorySentiment.happy,
        'label': MemorySentiment.happy.label(context),
        'color': const Color(0xFFFFA07A),
      },
      {
        'sentiment': MemorySentiment.grateful,
        'label': MemorySentiment.grateful.label(context),
        'color': const Color(0xFF5ECFB8),
      },
      {
        'sentiment': MemorySentiment.peaceful,
        'label': MemorySentiment.peaceful.label(context),
        'color': const Color(0xFFB794F6),
      },
    ];

    final totalCount = sentimentCounts.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    final hasData = totalCount > 0;

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
          Center(
            child: SizedBox(
              height: 220,
              width: 220,
              child: CustomPaint(
                painter: _EmotionPieChartPainter(
                  emotions: emotions,
                  sentimentCounts: sentimentCounts,
                  totalCount: totalCount,
                  hasData: hasData,
                  isChinese: isChinese,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildEmotionLegend(
            emotions: emotions,
            sentimentCounts: sentimentCounts,
            totalCount: totalCount,
            isChinese: isChinese,
            context: context,
          ),
        ],
      ),
    );
  }

  // 2. MONTHLY HEATMAP (12 squares for 12 months, 2 rows x 6 cols)
  Widget _buildMemoryHeatmap(BuildContext context, bool isChinese) {
    final monthlyData = <String, int>{};

    for (final memory in widget.memories) {
      final monthKey =
          '${memory.createdAt.year}-${memory.createdAt.month.toString().padLeft(2, '0')}';
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
    }

    int maxCount = 0;
    monthlyData.forEach((month, count) {
      if (count > maxCount) maxCount = count;
    });

    // Calculate stats
    String? mostActiveMonth;
    int maxMonthCount = 0;
    monthlyData.forEach((month, count) {
      if (count > maxMonthCount) {
        maxMonthCount = count;
        mostActiveMonth = month;
      }
    });

    // Calculate longest streak (year to date)
    final now = DateTime.now();
    int longestStreak = 0;
    int currentStreak = 0;

    for (int month = 1; month <= now.month; month++) {
      final monthKey = '${now.year}-${month.toString().padLeft(2, '0')}';
      if ((monthlyData[monthKey] ?? 0) > 0) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    String formatMostActiveLabel() {
      if (mostActiveMonth == null) return isChinese ? '暂无' : 'N/A';
      final parts = mostActiveMonth!.split('-');
      if (parts.length < 2) return mostActiveMonth!;
      final month = int.tryParse(parts[1]);
      if (month == null) return mostActiveMonth!;
      return isChinese ? '$month月' : _getMonthAbbrev(month);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '回忆热力图' : 'Memory Heatmap',
            style: ReportTextStyles.sectionHeader,
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '本年度活动' : 'Activity this year',
            style: ReportTextStyles.sectionSubtitle,
          ),
          const SizedBox(height: 24),
          // 2 rows of 6 months each
          Column(
            children: [
              // First row (months 1-6: January to June)
              Row(
                children: List.generate(6, (index) {
                  final month = index + 1; // 1-6
                  final monthDate = DateTime(now.year, month, 1);
                  final monthKey =
                      '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
                  final count = monthlyData[monthKey] ?? 0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getHeatmapColor(
                                count,
                              ).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AppTypography.labelSmall(
                            isChinese
                                ? '${monthDate.month}月'
                                : _getMonthAbbrev(monthDate.month),
                            context: context,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              // Second row (months 7-12: July to December)
              Row(
                children: List.generate(6, (index) {
                  final month = index + 7; // 7-12
                  final monthDate = DateTime(now.year, month, 1);
                  final monthKey =
                      '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
                  final count = monthlyData[monthKey] ?? 0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getHeatmapColor(
                                count,
                              ).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AppTypography.labelSmall(
                            isChinese
                                ? '${monthDate.month}月'
                                : _getMonthAbbrev(monthDate.month),
                            context: context,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Color legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                AppTypography.labelSmall(
                  isChinese ? '较少' : 'Less',
                  context: context,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(
                        (index * 3) + 1,
                      ), // Demo colors: 1, 4, 7, 10, 13
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                AppTypography.labelSmall(
                  isChinese ? '较多' : 'More',
                  context: context,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showHeatmapLegendDialog(context, isChinese),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: l10n.reportMostActiveLabel,
                  value: formatMostActiveLabel(),
                  context: context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  title: l10n.reportLongestStreak,
                  value: isChinese
                      ? '$longestStreak 个月'
                      : '$longestStreak months',
                  context: context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  title: l10n.reportPeakActivity,
                  value: isChinese
                      ? '$maxMonthCount 次'
                      : '$maxMonthCount entries',
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: ReportTextStyles.label,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: ReportTextStyles.statValueSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 3. HORIZONTAL BAR CHART by category
  Widget _buildEmotionByCategory(BuildContext context, bool isChinese) {
    // Initialize all categories with 0 count
    final categoryCounts = <DeclutterCategory, int>{};
    for (final category in DeclutterCategory.values) {
      categoryCounts[category] = 0;
    }

    // Count memories by category
    for (final memory in widget.memories) {
      if (memory.category != null && memory.category!.isNotEmpty) {
        final catValue = memory.category!;
        // Find matching enum category (match enum name/english/chinese)
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

    // Sort categories by count (descending)
    final sortedCategories = categoryCounts.keys.toList()
      ..sort((a, b) => categoryCounts[b]!.compareTo(categoryCounts[a]!));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '分类统计' : 'Category Statistics',
            style: ReportTextStyles.sectionHeader,
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '各类别的回忆数量' : 'Memory count per category',
            style: ReportTextStyles.sectionSubtitle,
          ),
          const SizedBox(height: 24),
          if (sortedCategories.isEmpty)
            Text(
              isChinese ? '暂无分类数据' : 'No category data yet',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            )
          else ...[
            Column(
              children: sortedCategories.map((category) {
                final count = categoryCounts[category] ?? 0;
                final maxCount = categoryCounts.values.isEmpty
                    ? 1
                    : categoryCounts.values.reduce((a, b) => a > b ? a : b);
                final barValue = maxCount == 0
                    ? 0.0
                    : (count / maxCount).clamp(0.0, 1.0);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppTypography.titleSmall(
                            category.label(context),
                            context: context,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const Spacer(),
                          AppTypography.titleMedium(
                            '$count',
                            context: context,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: barValue,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.8),
                                    Theme.of(context).colorScheme.primary,
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
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // 4. TIME MARKERS
  Widget _buildTimeMarkers(BuildContext context, bool isChinese) {
    final sortedMemories = widget.memories.isEmpty
        ? <Memory>[]
        : (List<Memory>.from(widget.memories)
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
    for (final memory in widget.memories) {
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

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
      child: widget.memories.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '时光印记' : 'Time Markers',
                  style: ReportTextStyles.sectionHeader,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    isChinese ? '暂无回忆' : 'No memories yet',
                    style: ReportTextStyles.body,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '时光印记' : 'Time Markers',
                  style: ReportTextStyles.sectionHeader,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.reportPreciousMoments,
                  style: ReportTextStyles.sectionSubtitle,
                ),
                const SizedBox(height: 24),
                _buildTimeMarker(
                  context,
                  Icons.spa_rounded,
                  colorScheme.primary,
                  l10n.reportFirstMemoryLabel,
                  firstMemory!.title,
                  _formatDate(firstMemory.createdAt, isChinese),
                  isChinese,
                ),
                const SizedBox(height: 16),
                if (longestStory != null)
                  _buildTimeMarker(
                    context,
                    Icons.menu_book_rounded,
                    colorScheme.secondary,
                    l10n.reportLongestStoryLabel,
                    longestStory.title,
                    _formatDate(longestStory.createdAt, isChinese),
                    isChinese,
                  ),
                const SizedBox(height: 16),
                _buildTimeMarker(
                  context,
                  Icons.auto_awesome_rounded,
                  colorScheme.tertiary,
                  l10n.reportLatestMemoryLabel,
                  latestMemory!.title,
                  _formatDate(latestMemory.createdAt, isChinese),
                  isChinese,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.track_changes_rounded,
                        size: 32,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTypography.titleSmall(
                              l10n.reportMemoryJourney,
                              context: context,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 4),
                            AppTypography.bodySmall(
                              l10n.reportMemoryJourneyDetail(
                                totalDays.toString(),
                                widget.memories.length.toString(),
                              ),
                              context: context,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTimeMarker(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String label,
    String title,
    String date,
    bool isChinese,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 24)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ReportTextStyles.label),
              const SizedBox(height: 4),
              Text(title, style: ReportTextStyles.statValueSmall),
              const SizedBox(height: 2),
              Text(date, style: ReportTextStyles.label),
            ],
          ),
        ),
      ],
    );
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

  Color _getHeatmapColor(int count) {
    // Use actual count instead of relative intensity for consistent colors
    if (count == 0) {
      return const Color(0xFFE5E7EB); // Gray for no activity
    } else if (count <= 3) {
      return const Color(0xFFD4E9F7); // Very light blue
    } else if (count <= 6) {
      return const Color(0xFFA8D8F0); // Light blue
    } else if (count <= 9) {
      return const Color(0xFF7BC8E8); // Medium blue
    } else if (count <= 12) {
      return const Color(0xFF4FB8E0); // Dark blue
    } else {
      return const Color(0xFF23A7D8); // Darkest blue
    }
  }

  Color _getHeatmapColorByCount(int count) {
    // Same logic as _getHeatmapColor for legend consistency
    if (count == 0) {
      return const Color(0xFFE5E7EB); // Gray
    } else if (count <= 3) {
      return const Color(0xFFD4E9F7); // Very light blue
    } else if (count <= 6) {
      return const Color(0xFFA8D8F0); // Light blue
    } else if (count <= 9) {
      return const Color(0xFF7BC8E8); // Medium blue
    } else {
      return const Color(0xFF4FB8E0); // Dark blue (for 10+)
    }
  }

  void _showHeatmapLegendDialog(BuildContext context, bool isChinese) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: GlassContainer(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppTypography.titleSmall(
                      isChinese ? '活动等级说明' : 'Activity Levels',
                      context: context,
                      fontWeight: FontWeight.bold,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: colorScheme.onSurfaceVariant,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...[
                  {'range': isChinese ? '无活动 (0)' : 'None (0)', 'count': 0},
                  {
                    'range': isChinese ? '轻度活跃 (1-3)' : 'Light (1-3)',
                    'count': 2,
                  },
                  {
                    'range': isChinese ? '中度活跃 (4-6)' : 'Moderate (4-6)',
                    'count': 5,
                  },
                  {
                    'range': isChinese ? '高度活跃 (7-9)' : 'High (7-9)',
                    'count': 8,
                  },
                  {
                    'range': isChinese ? '非常活跃 (10+)' : 'Very High (10+)',
                    'count': 10,
                  },
                ].map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getHeatmapColorByCount(
                              item['count'] as int,
                            ).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTypography.bodySmall(
                            item['range'] as String,
                            context: context,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
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

// Donut Chart Painter for Emotion Distribution
class _EmotionDonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> emotions;
  final Map<MemorySentiment, int> sentimentCounts;
  final int totalCount;

  _EmotionDonutPainter({
    required this.emotions,
    required this.sentimentCounts,
    required this.totalCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.32;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFE7EAF6);

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);

    if (totalCount == 0) {
      return;
    }

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
      if (sweepAngle <= 0) continue;

      final color = emotion['color'] as Color;
      paint.shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [color.withValues(alpha: 0.65), color],
      ).createShader(rect);

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _EmotionPieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> emotions;
  final Map<MemorySentiment, int> sentimentCounts;
  final int totalCount;
  final bool hasData;
  final bool isChinese;

  _EmotionPieChartPainter({
    required this.emotions,
    required this.sentimentCounts,
    required this.totalCount,
    required this.hasData,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    if (!hasData) {
      final grayPaint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, grayPaint);
      return;
    }

    // Shadow for slices
    final sliceShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Prepare data
    final maxCount = sentimentCounts.values.isEmpty
        ? 0
        : sentimentCounts.values.reduce((a, b) => a > b ? a : b);
    double startAngle = -math.pi / 2;
    const baseGapAngle = 0.03; // ~1.7°

    for (final emotion in emotions) {
      final sentiment = emotion['sentiment'] as MemorySentiment;
      final count = sentimentCounts[sentiment] ?? 0;
      final color = emotion['color'] as Color;
      if (count <= 0) continue;

      final sweepAngle = (count / totalCount) * 2 * math.pi;
      if (sweepAngle <= baseGapAngle) {
        startAngle += sweepAngle;
        continue;
      }

      final midAngle = startAngle + sweepAngle / 2;
      // Explode distance proportional to slice size
      final explodeFactor = (count / totalCount).clamp(0.0, 1.0);
      final explodeDist = radius * (0.018 + 0.03 * explodeFactor);
      final dx = explodeDist * math.cos(midAngle);
      final dy = explodeDist * math.sin(midAngle);

      // Slight scale for largest slice
      final scale = maxCount > 0 ? (0.94 + 0.08 * (count / maxCount)) : 1.0;
      final sliceRadius = radius * scale;
      final sliceRect = Rect.fromCircle(center: center, radius: sliceRadius);

      final gapAngle = baseGapAngle;
      final effectiveStart = startAngle + gapAngle / 2;
      final effectiveSweep = sweepAngle - gapAngle;

      canvas.save();
      canvas.translate(dx, dy);

      canvas.drawArc(
        sliceRect,
        effectiveStart,
        effectiveSweep,
        true,
        sliceShadowPaint,
      );

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawArc(sliceRect, effectiveStart, effectiveSweep, true, paint);

      // Percentage inside slice
      final percent = ((count / totalCount) * 100).toStringAsFixed(
        ((count / totalCount) * 100) >= 10 ? 0 : 1,
      );
      final innerRadius = sliceRadius * 0.58;
      final innerOffset = Offset(
        center.dx + innerRadius * math.cos(midAngle),
        center.dy + innerRadius * math.sin(midAngle),
      );
      final innerTextPainter = TextPainter(
        text: TextSpan(
          text: '$percent%',
          style: TextStyle(
            color:
                Color.lerp(color, Colors.black, 0.35) ??
                color.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      innerTextPainter.layout();
      innerTextPainter.paint(
        canvas,
        Offset(
          innerOffset.dx - innerTextPainter.width / 2,
          innerOffset.dy - innerTextPainter.height / 2,
        ),
      );

      // Outside title matching percentage tint
      final labelRadius = sliceRadius * 1.05;
      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(midAngle),
        center.dy + labelRadius * math.sin(midAngle),
      );
      final titleColor =
          innerTextPainter.text!.style?.color ??
          (Color.lerp(color, Colors.black, 0.35) ??
              color.withValues(alpha: 0.9));
      final labelPainter = TextPainter(
        text: TextSpan(
          text: emotion['label'] as String,
          style: TextStyle(
            color: titleColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout(maxWidth: radius);
      final isRight = math.cos(midAngle) >= 0;
      final labelPos = Offset(
        labelOffset.dx - (isRight ? 0 : labelPainter.width),
        labelOffset.dy - labelPainter.height / 2,
      );
      labelPainter.paint(canvas, labelPos);

      canvas.restore();
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
