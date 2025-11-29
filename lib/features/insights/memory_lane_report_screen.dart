import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';

class MemoryLaneReportScreen extends StatefulWidget {
  const MemoryLaneReportScreen({super.key, required this.memories});

  final List<Memory> memories;

  @override
  State<MemoryLaneReportScreen> createState() => _MemoryLaneReportScreenState();
}

class _MemoryLaneReportScreenState extends State<MemoryLaneReportScreen> {
  final ScrollController _scrollController = ScrollController();

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
    final headerHeight = responsive.totalTwoLineHeaderHeight;
    final topPadding = responsive.safeAreaPadding.top;

    final pageName = isChinese ? '年度记忆' : 'Annual Memory';

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
                // Gradient background that scrolls
                Container(
                  height: 800,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFB794F6), // Purple
                        Color(0xFFF3EBFF), // Light purple
                        Color(0xFFF5F5F7),
                      ],
                      stops: [0.0, 0.25, 0.45],
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
                      top: topPadding + 20,
                      bottom: 16,
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
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    letterSpacing: -0.5,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.dashboardMemoryLaneSubtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4B5563),
                                  ),
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
                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final scrollProgress = (scrollOffset / headerHeight).clamp(0.0, 1.0);
                final realHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;
                return IgnorePointer(
                  ignoring: realHeaderOpacity < 0.5,
                  child: Opacity(
                    opacity: realHeaderOpacity,
                    child: child,
                  ),
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
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
        'label': isChinese ? '爱' : 'Love',
        'color': const Color(0xFFFF9AA2),
      },
      {
        'sentiment': MemorySentiment.nostalgia,
        'label': isChinese ? '怀念' : 'Nostalgia',
        'color': const Color(0xFFFFD93D),
      },
      {
        'sentiment': MemorySentiment.adventure,
        'label': isChinese ? '冒险' : 'Adventure',
        'color': const Color(0xFF89CFF0),
      },
      {
        'sentiment': MemorySentiment.happy,
        'label': isChinese ? '快乐' : 'Happy',
        'color': const Color(0xFFFFA07A),
      },
      {
        'sentiment': MemorySentiment.grateful,
        'label': isChinese ? '感激' : 'Grateful',
        'color': const Color(0xFF5ECFB8),
      },
      {
        'sentiment': MemorySentiment.peaceful,
        'label': isChinese ? '平静' : 'Peaceful',
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '情绪分布' : 'Emotion Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? '每个回忆都是珍贵的' : 'Every memory is precious',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              height: 240,
              width: 240,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '回忆热力图' : 'Memory Heatmap',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '本年度活动' : 'Activity this year',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
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
                              color: _getHeatmapColor(count),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isChinese
                                ? '${monthDate.month}月'
                                : _getMonthAbbrev(monthDate.month),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 11,
                                ),
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
                              color: _getHeatmapColor(count),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isChinese
                                ? '${monthDate.month}月'
                                : _getMonthAbbrev(monthDate.month),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 11,
                                ),
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
                Text(
                  isChinese ? '较少' : 'Less',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
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
                Text(
                  isChinese ? '较多' : 'More',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showHeatmapLegendDialog(context, isChinese),
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: const Color(0xFF6B7280),
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
                  title: isChinese ? '最活跃' : 'Most Active',
                  value: formatMostActiveLabel(),
                  context: context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  title: isChinese ? '最长连续' : 'Longest Streak',
                  value: isChinese
                      ? '$longestStreak 个月'
                      : '$longestStreak months',
                  context: context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  title: isChinese ? '峰值活动' : 'Peak Activity',
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
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 32,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
            ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '分类统计' : 'Category Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '各类别的回忆数量' : 'Memory count per category',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
            Text(
              isChinese ? '暂无分类数据' : 'No category data yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            )
          else ...[
            SizedBox(
              height: 260,
              width: double.infinity,
              child: CustomPaint(
                painter: _CategoryVerticalBarChartPainter(
                  categories: sortedCategories,
                  counts: categoryCounts,
                  isChinese: isChinese,
                ),
              ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: widget.memories.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '时光印记' : 'Time Markers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    isChinese ? '暂无回忆' : 'No memories yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '时光印记' : 'Time Markers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isChinese ? '珍贵的时刻' : 'Precious moments',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                _buildTimeMarker(
                  context,
                  Icons.spa_rounded,
                  const Color(0xFF66BB6A),
                  isChinese ? '第一个回忆' : 'First Memory',
                  firstMemory!.title,
                  _formatDate(firstMemory.createdAt, isChinese),
                  isChinese,
                ),
                const SizedBox(height: 16),
                if (longestStory != null)
                  _buildTimeMarker(
                    context,
                    Icons.menu_book_rounded,
                    const Color(0xFF8E24AA),
                    isChinese ? '最长故事' : 'Longest Story',
                    longestStory.title,
                    _formatDate(longestStory.createdAt, isChinese),
                    isChinese,
                  ),
                const SizedBox(height: 16),
                _buildTimeMarker(
                  context,
                  Icons.auto_awesome_rounded,
                  const Color(0xFFFFB300),
                  isChinese ? '最新回忆' : 'Latest Memory',
                  latestMemory!.title,
                  _formatDate(latestMemory.createdAt, isChinese),
                  isChinese,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF3EBFF), Color(0xFFE6D5FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.track_changes_rounded,
                        size: 32,
                        color: Color(0xFF7B61FF),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isChinese ? '回忆之旅' : 'Memory Journey',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isChinese
                                  ? '$totalDays 天 · ${widget.memories.length} 个回忆'
                                  : '$totalDays days · ${widget.memories.length} memories',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.black54),
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
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontSize: 10,
                ),
              ),
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isChinese ? '活动等级说明' : 'Activity Levels',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF9CA3AF),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...[
                  {'range': isChinese ? '无活动 (0)' : 'None (0)', 'count': 0},
                  {'range': isChinese ? '轻度活跃 (1-3)' : 'Light (1-3)', 'count': 2},
                  {'range': isChinese ? '中度活跃 (4-6)' : 'Moderate (4-6)', 'count': 5},
                  {'range': isChinese ? '高度活跃 (7-9)' : 'High (7-9)', 'count': 8},
                  {'range': isChinese ? '非常活跃 (10+)' : 'Very High (10+)', 'count': 10},
                ].map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _getHeatmapColorByCount(
                              item['count'] as int,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE5E7EA)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['range'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF4B5563),
                              height: 1.2,
                            ),
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
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // 3 列布局，图例仅显示色块+标签
        final itemWidth = (constraints.maxWidth - 2 * 8) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: emotions.map((emotion) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: emotion['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emotion['label'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF111827),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
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
        const Color(0xFFE0E0E0),
        const Color(0xFFB794F6),
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
      // Draw gray circle when no data
      final grayPaint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, grayPaint);
    } else {
      double startAngle = -math.pi / 2; // Start from top

      for (final emotion in emotions) {
        final sentiment = emotion['sentiment'] as MemorySentiment;
        final count = sentimentCounts[sentiment] ?? 0;
        final color = emotion['color'] as Color;

        if (count == 0) continue;

        final sweepAngle = (count / totalCount) * 2 * math.pi;

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );

        // Label count on slice
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.58;
        final labelOffset = Offset(
          center.dx + labelRadius * math.cos(midAngle),
          center.dy + labelRadius * math.sin(midAngle),
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$count',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelOffset.dx - textPainter.width / 2,
            labelOffset.dy - textPainter.height / 2,
          ),
        );

        startAngle += sweepAngle;
      }
    }

    // Draw white circle in center to create donut effect
    final centerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerCirclePaint);

    // Draw total count in center with label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$totalCount',
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 - 8,
      ),
    );

    final subPainter = TextPainter(
      text: TextSpan(
        text: isChinese ? '回忆' : 'memories',
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subPainter.layout();
    subPainter.paint(
      canvas,
      Offset(
        center.dx - subPainter.width / 2,
        center.dy - subPainter.height / 2 + 16,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
