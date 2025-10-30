import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';

class MemoryLaneReportScreen extends StatelessWidget {
  const MemoryLaneReportScreen({
    super.key,
    required this.declutteredItems,
  });

  final List<DeclutterItem> declutteredItems;

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('zh');

    // Get items with photos
    final itemsWithPhotos =
        declutteredItems.where((item) => item.photoPath != null).toList()
          ..sort((a, b) =>
              b.createdAt.compareTo(a.createdAt)); // Sort by newest first

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar stays the same
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final scrollY =
                    (constraints.maxHeight - kToolbarHeight).clamp(0.0, 150.0);
                final progress = 1 - (scrollY / 150.0);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform.translate(
                      offset: Offset(0, progress * -30),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF3EBFF),
                              Color(0xFFB794F6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 40,
                      child: Opacity(
                        opacity: 1 - progress,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isChinese ? '记忆长廊' : 'Memory Lane',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isChinese
                                  ? '${itemsWithPhotos.length} 张照片'
                                  : '${itemsWithPhotos.length} photos',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10 * progress,
                            sigmaY: 10 * progress,
                          ),
                          child: Container(
                            height: kToolbarHeight +
                                MediaQuery.of(context).padding.top,
                            color: Colors.white.withValues(alpha: progress * 0.9),
                            alignment: Alignment.center,
                            child: SafeArea(
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.black
                                          .withValues(alpha: progress),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Expanded(
                                    child: Opacity(
                                      opacity: progress,
                                      child: Text(
                                        isChinese ? '记忆长廊' : 'Memory Lane',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
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
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Content sections
          SliverToBoxAdapter(
            child: Column(
              children: [
                // 1. Emotion Distribution (Vertical Bar Chart)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildEmotionDistribution(context, isChinese),
                ),
                const SizedBox(height: 20),

                // 2. Memory Heatmap (GitHub-style daily grid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildMemoryHeatmap(context, isChinese),
                ),
                const SizedBox(height: 20),

                // 3. Emotion by Category (Horizontal Bar Chart)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildEmotionByCategory(context, isChinese),
                ),
                const SizedBox(height: 20),

                // 4. Time Markers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTimeMarkers(context, isChinese),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  // 1. VERTICAL BAR CHART for emotions
  Widget _buildEmotionDistribution(BuildContext context, bool isChinese) {
    final emotionCounts = <DeclutterStatus, int>{};
    for (final item in declutteredItems) {
      emotionCounts[item.status] = (emotionCounts[item.status] ?? 0) + 1;
    }

    final emotions = [
      {
        'status': DeclutterStatus.keep,
        'label': isChinese ? '共同成长' : 'Growing Together',
        'emoji': '🌱',
        'color': const Color(0xFF5ECFB8)
      },
      {
        'status': DeclutterStatus.donate,
        'label': isChinese ? '传递温暖' : 'Spreading Warmth',
        'emoji': '💝',
        'color': const Color(0xFFFF9AA2)
      },
      {
        'status': DeclutterStatus.recycle,
        'label': isChinese ? '循环新生' : 'Renewed Life',
        'emoji': '♻️',
        'color': const Color(0xFF89CFF0)
      },
      {
        'status': DeclutterStatus.resell,
        'label': isChinese ? '价值延续' : 'Value Continues',
        'emoji': '💰',
        'color': const Color(0xFFFFD93D)
      },
      {
        'status': DeclutterStatus.discard,
        'label': isChinese ? '任务完成' : 'Mission Complete',
        'emoji': '✅',
        'color': const Color(0xFFB794F6)
      },
    ];

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
          const SizedBox(height: 4),
          Text(
            isChinese ? '每个决定都是一次成长' : 'Every decision is growth',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: CustomPaint(
              painter: _VerticalBarChartPainter(
                emotions: emotions,
                emotionCounts: emotionCounts,
                isChinese: isChinese,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. MONTHLY HEATMAP (12 squares for 12 months)
  Widget _buildMemoryHeatmap(BuildContext context, bool isChinese) {
    // Calculate monthly activity for the past 12 months
    final monthlyData = <String, int>{};

    for (final item in declutteredItems) {
      final monthKey =
          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}';
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

    // Calculate longest streak (consecutive months)
    int longestStreak = 0;
    int currentStreak = 0;
    final sortedMonths = monthlyData.keys.toList()..sort();
    for (int i = 0; i < sortedMonths.length - 1; i++) {
      final currentMonth = DateTime.parse('${sortedMonths[i]}-01');
      final nextMonth = DateTime.parse('${sortedMonths[i + 1]}-01');

      // Check if next month is consecutive
      final expectedNext = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      if (nextMonth.year == expectedNext.year && nextMonth.month == expectedNext.month) {
        currentStreak++;
        if (currentStreak > longestStreak) longestStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '回忆热力图' : 'Memory Heatmap',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '年度整理轨迹' : 'Annual decluttering journey',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _MonthlyHeatmapPainter(
                monthlyData: monthlyData,
                maxCount: maxCount,
                isChinese: isChinese,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              Text(
                isChinese ? '少' : 'Less',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
              ),
              const SizedBox(width: 4),
              ...List.generate(5, (index) {
                final intensity = (index + 1) / 5;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        const Color(0xFFE0E0E0),
                        const Color(0xFFB794F6),
                        intensity,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              Text(
                isChinese ? '多' : 'More',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeatmapStat(
                  context,
                  label: isChinese ? '最活跃' : 'Most Active',
                  value: mostActiveMonth != null
                      ? _formatMonth(mostActiveMonth!, isChinese)
                      : '-',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFD93D),
                ),
                _buildHeatmapStat(
                  context,
                  label: isChinese ? '最长连续' : 'Longest Streak',
                  value: '${longestStreak + 1} ${isChinese ? '月' : 'mo'}',
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF6B6B),
                ),
                _buildHeatmapStat(
                  context,
                  label: isChinese ? '高峰活动' : 'Peak Activity',
                  value: maxCount.toString(),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF5ECFB8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  // 3. HORIZONTAL BAR CHART by category
  Widget _buildEmotionByCategory(BuildContext context, bool isChinese) {
    final categoryEmotions = <DeclutterCategory, List<int>>{};

    for (final item in declutteredItems) {
      if (item.joyLevel != null && item.joyLevel! > 0) {
        categoryEmotions
            .putIfAbsent(item.category, () => [])
            .add(item.joyLevel!);
      }
    }

    final categoryAverages = <DeclutterCategory, double>{};
    categoryEmotions.forEach((category, joyLevels) {
      categoryAverages[category] =
          joyLevels.reduce((a, b) => a + b) / joyLevels.length;
    });

    final sortedCategories = categoryAverages.keys.toList()
      ..sort((a, b) => categoryAverages[b]!.compareTo(categoryAverages[a]!));

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '物品情绪分类' : 'Item Emotions by Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '各类别的平均心动指数' : 'Average joy index per category',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 20),
          if (sortedCategories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  isChinese ? '暂无心动指数数据' : 'No joy level data yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _HorizontalBarChartPainter(
                  categories: sortedCategories,
                  averages: categoryAverages,
                  isChinese: isChinese,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 4. TIME MARKERS
  Widget _buildTimeMarkers(BuildContext context, bool isChinese) {
    if (declutteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedItems = declutteredItems.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final firstMemory = sortedItems.first;
    final latestMemory = sortedItems.last;

    final longestMemory = declutteredItems.reduce((curr, next) {
      final currLength = (curr.name.length + (curr.notes?.length ?? 0));
      final nextLength = (next.name.length + (next.notes?.length ?? 0));
      return currLength > nextLength ? curr : next;
    });

    final joyfulMemory = declutteredItems
        .where((item) => item.joyLevel != null)
        .fold<DeclutterItem?>(null, (prev, curr) {
      if (prev == null) return curr;
      return (curr.joyLevel ?? 0) > (prev.joyLevel ?? 0) ? curr : prev;
    });

    final totalDays =
        latestMemory.createdAt.difference(firstMemory.createdAt).inDays;

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
      child: Column(
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
            isChinese ? '记录你的每个重要时刻' : 'Capturing your important moments',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF3EBFF),
                  Color(0xFFE6D5FF),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: Color(0xFFB794F6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '整理旅程' : 'Declutter Journey',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isChinese
                            ? '$totalDays 天 · ${declutteredItems.length} 件物品'
                            : '$totalDays days · ${declutteredItems.length} items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeMarker(
            context,
            icon: Icons.play_circle_rounded,
            iconColor: const Color(0xFF5ECFB8),
            title: isChinese ? '第一个回忆' : 'First Memory',
            itemName: firstMemory.name,
            date: firstMemory.createdAt,
            isChinese: isChinese,
          ),
          const SizedBox(height: 12),
          if (joyfulMemory != null) ...[
            _buildTimeMarker(
              context,
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFFF9AA2),
              title: isChinese ? '最心动回忆' : 'Most Joyful',
              itemName: joyfulMemory.name,
              date: joyfulMemory.createdAt,
              subtitle:
                  '${isChinese ? "心动指数" : "Joy Level"} ${joyfulMemory.joyLevel}/10',
              isChinese: isChinese,
            ),
            const SizedBox(height: 12),
          ],
          _buildTimeMarker(
            context,
            icon: Icons.auto_stories_rounded,
            iconColor: const Color(0xFFFFD93D),
            title: isChinese ? '最长回忆' : 'Longest Story',
            itemName: longestMemory.name,
            date: longestMemory.createdAt,
            subtitle: longestMemory.notes != null &&
                    longestMemory.notes!.length > 30
                ? '${longestMemory.notes!.substring(0, 30)}...'
                : longestMemory.notes,
            isChinese: isChinese,
          ),
          const SizedBox(height: 12),
          _buildTimeMarker(
            context,
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF89CFF0),
            title: isChinese ? '最新回忆' : 'Latest Memory',
            itemName: latestMemory.name,
            date: latestMemory.createdAt,
            isChinese: isChinese,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMarker(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String itemName,
    required DateTime date,
    String? subtitle,
    required bool isChinese,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  itemName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  _formatDate(date, isChinese),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black45,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(String monthKey, bool isChinese) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;

    final month = int.parse(parts[1]);
    if (isChinese) {
      return '$month月';
    } else {
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
        'Dec'
      ];
      return months[month - 1];
    }
  }

  String _formatDate(DateTime date, bool isChinese) {
    if (isChinese) {
      return '${date.year}年${date.month}月${date.day}日';
    } else {
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
  }
}

// PROPER VERTICAL BAR CHART PAINTER
class _VerticalBarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> emotions;
  final Map<DeclutterStatus, int> emotionCounts;
  final bool isChinese;

  _VerticalBarChartPainter({
    required this.emotions,
    required this.emotionCounts,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 40.0;
    const bottomPadding = 80.0; // Increased for better label spacing
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - padding - bottomPadding;

    final maxCount = emotionCounts.values.isEmpty
        ? 1
        : emotionCounts.values.reduce((a, b) => a > b ? a : b);

    final barWidth = (chartWidth / emotions.length) * 0.5;
    final barSpacing = chartWidth / emotions.length;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = padding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Draw bars
    for (int i = 0; i < emotions.length; i++) {
      final emotion = emotions[i];
      final status = emotion['status'] as DeclutterStatus;
      final count = emotionCounts[status] ?? 0;
      final color = emotion['color'] as Color;
      final emoji = emotion['emoji'] as String;
      final label = emotion['label'] as String;

      // Calculate bar height with minimum height for visibility
      final normalizedHeight = maxCount > 0 ? (count / maxCount) : 0.0;
      final barHeight = (normalizedHeight * chartHeight).clamp(5.0, chartHeight);
      final x = padding + (barSpacing * i) + (barSpacing - barWidth) / 2;
      final y = padding + chartHeight - barHeight;

      // Draw bar
      final barPaint = Paint()..color = color;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, barPaint);

      // Draw emoji above bar
      textPainter.text = TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 20),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, y - 28),
      );

      // Draw count on top of bar (if tall enough) or above it
      final countText = count.toString();
      textPainter.text = TextSpan(
        text: countText,
        style: TextStyle(
          color: barHeight > 25 ? Colors.white : const Color(0xFF666666),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();

      final countY = barHeight > 25 ? y + 6 : y - 50;
      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - textPainter.width) / 2,
          countY,
        ),
      );

      // Draw label below with word wrapping
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 9,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      );
      textPainter.layout(maxWidth: barWidth + 10);
      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainter.width / 2,
          size.height - bottomPadding + 12,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// MONTHLY HEATMAP PAINTER (12 squares for 12 months)
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

    final now = DateTime.now();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Calculate starting position to center the grid
    final totalWidth = (cellSize * monthsToShow) + (cellGap * (monthsToShow - 1));
    final startX = (size.width - totalWidth) / 2;

    // Draw 12 month squares (right to left, newest on right)
    for (int i = 0; i < monthsToShow; i++) {
      final monthDate = DateTime(now.year, now.month - (monthsToShow - 1 - i), 1);
      final monthKey =
          '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      final count = monthlyData[monthKey] ?? 0;

      // Calculate position
      final x = startX + (i * (cellSize + cellGap));
      final y = 20.0;

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
        'Dec'
      ];
      final monthLabel =
          isChinese ? '${monthDate.month}月' : months[monthDate.month - 1];

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

// HORIZONTAL BAR CHART PAINTER (for categories)
class _HorizontalBarChartPainter extends CustomPainter {
  final List<DeclutterCategory> categories;
  final Map<DeclutterCategory, double> averages;
  final bool isChinese;

  _HorizontalBarChartPainter({
    required this.categories,
    required this.averages,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 16.0;
    const labelWidth = 80.0;
    final chartWidth = size.width - labelWidth - padding * 2;
    final barHeight = (size.height - padding * 2) / categories.length;
    final actualBarHeight = barHeight * 0.6;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final categoryColors = {
      DeclutterCategory.clothes: const Color(0xFF5ECFB8),
      DeclutterCategory.books: const Color(0xFFFFD93D),
      DeclutterCategory.papers: const Color(0xFF89CFF0),
      DeclutterCategory.miscellaneous: const Color(0xFFB794F6),
      DeclutterCategory.sentimental: const Color(0xFFFF9AA2),
      DeclutterCategory.beauty: const Color(0xFFFF6B6B),
    };

    final maxAverage =
        averages.values.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final average = averages[category]!;
      final y = padding + (i * barHeight);

      // Draw label
      textPainter.text = TextSpan(
        text: isChinese ? category.chinese : category.english,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout(maxWidth: labelWidth - 8);
      textPainter.paint(
        canvas,
        Offset(padding, y + (barHeight - textPainter.height) / 2),
      );

      // Draw bar
      final barX = padding + labelWidth;
      final barPaint = Paint()..color = const Color(0xFFF5F5F5);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, y + (barHeight - actualBarHeight) / 2,
              chartWidth, actualBarHeight),
          const Radius.circular(6),
        ),
        barPaint,
      );

      final barWidth = (average / maxAverage) * chartWidth;
      final valuePaint = Paint()
        ..color = categoryColors[category] ?? const Color(0xFFB794F6);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, y + (barHeight - actualBarHeight) / 2,
              barWidth, actualBarHeight),
          const Radius.circular(6),
        ),
        valuePaint,
      );

      // Draw value
      textPainter.text = TextSpan(
        text: average.toStringAsFixed(1),
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          barX + barWidth + 8,
          y + (barHeight - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
