import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/memory.dart';

class MemoryLaneReportScreen extends StatefulWidget {
  const MemoryLaneReportScreen({
    super.key,
    required this.memories,
  });

  final List<Memory> memories;

  @override
  State<MemoryLaneReportScreen> createState() => _MemoryLaneReportScreenState();
}

class _MemoryLaneReportScreenState extends State<MemoryLaneReportScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('zh');

    final topPadding = MediaQuery.of(context).padding.top;
    final pageName = isChinese ? '记忆长廊' : 'Memory Lane';

    // Calculate scroll-based animations
    const titleAreaHeight = 120.0;
    final scrollProgress = (_scrollOffset / titleAreaHeight).clamp(0.0, 1.0);
    final titleOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
    final realHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;

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
                        Colors.white,
                      ],
                      stops: [0.0, 0.15, 0.33],
                    ),
                  ),
                ),
                // Content on top
                Column(
                  children: [
                    // Top spacing + title
                    SizedBox(
                      height: 120,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 16,
                          top: topPadding + 12,
                        ),
                        child: Opacity(
                          opacity: titleOpacity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Large title on the left
                              Text(
                                pageName,
                                style: const TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content sections
                    Column(
                      children: [
                      // 1. Emotion Distribution (Vertical Bar Chart)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _buildEmotionDistribution(context, isChinese),
                      ),
                      const SizedBox(height: 20),

                // 2. Memory Heatmap
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
          ],
        ),
              ],
            ),
          ),

          // Real header that appears when scrolling is complete
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: realHeaderOpacity < 0.5,
                child: Opacity(
                  opacity: realHeaderOpacity,
                  child: Container(
                    height: topPadding + kToolbarHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE5E5EA),
                          width: 0.5,
                        ),
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
            ),
          ],
        ),
    );
  }

  // 1. VERTICAL BAR CHART for emotions
  Widget _buildEmotionDistribution(BuildContext context, bool isChinese) {
    final sentimentCounts = <MemorySentiment, int>{};
    for (final memory in widget.memories) {
      if (memory.sentiment != null) {
        sentimentCounts[memory.sentiment!] = (sentimentCounts[memory.sentiment!] ?? 0) + 1;
      }
    }

    final emotions = [
      {
        'sentiment': MemorySentiment.love,
        'label': isChinese ? '爱' : 'Love',
        'color': const Color(0xFFFF9AA2)
      },
      {
        'sentiment': MemorySentiment.nostalgia,
        'label': isChinese ? '怀念' : 'Nostalgia',
        'color': const Color(0xFFFFD93D)
      },
      {
        'sentiment': MemorySentiment.adventure,
        'label': isChinese ? '冒险' : 'Adventure',
        'color': const Color(0xFF89CFF0)
      },
      {
        'sentiment': MemorySentiment.happy,
        'label': isChinese ? '快乐' : 'Happy',
        'color': const Color(0xFFFFA07A)
      },
      {
        'sentiment': MemorySentiment.grateful,
        'label': isChinese ? '感激' : 'Grateful',
        'color': const Color(0xFF5ECFB8)
      },
      {
        'sentiment': MemorySentiment.peaceful,
        'label': isChinese ? '平静' : 'Peaceful',
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
            isChinese ? '每个回忆都是珍贵的' : 'Every memory is precious',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            child: SizedBox(
              width: double.infinity,
              height: 250,
              child: CustomPaint(
                painter: _VerticalBarChartPainter(
                  emotions: emotions,
                  sentimentCounts: sentimentCounts,
                  isChinese: isChinese,
                ),
              ),
            ),
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

    // Calculate longest streak
    final now = DateTime.now();
    int longestStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < 12; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey =
          '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      if ((monthlyData[monthKey] ?? 0) > 0) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
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
            isChinese ? '过去12个月的回忆活跃度' : 'Activity in past 12 months',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            child: SizedBox(
              width: double.infinity,
              height: 160,
              child: CustomPaint(
                painter: _MonthlyHeatmapPainter(
                  monthlyData: monthlyData,
                  maxCount: maxCount,
                  isChinese: isChinese,
                ),
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
              const SizedBox(width: 8),
              ...List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        const Color(0xFFE0E0E0),
                        const Color(0xFFB794F6),
                        i / 4,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                isChinese ? '多' : 'More',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatChip(
                context,
                isChinese ? '最活跃月份' : 'Most Active',
                mostActiveMonth != null
                    ? (isChinese
                        ? '${mostActiveMonth!.split('-')[1]}月'
                        : mostActiveMonth!.split('-')[1])
                    : (isChinese ? '无' : 'N/A'),
                isChinese,
              ),
              _buildStatChip(
                context,
                isChinese ? '最长连续' : 'Longest Streak',
                '$longestStreak ${isChinese ? '月' : 'months'}',
                isChinese,
              ),
              _buildStatChip(
                context,
                isChinese ? '高峰活动' : 'Peak Activity',
                '$maxMonthCount ${isChinese ? '个' : 'items'}',
                isChinese,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context, String label, String value, bool isChinese) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontSize: 10,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  // 3. HORIZONTAL BAR CHART by category
  Widget _buildEmotionByCategory(BuildContext context, bool isChinese) {
    // Group memories by category (category is a String)
    final categoryGroups = <String, List<Memory>>{};

    for (final memory in widget.memories) {
      if (memory.category != null && memory.category!.isNotEmpty) {
        categoryGroups.putIfAbsent(memory.category!, () => []).add(memory);
      }
    }

    // Calculate count per category (since memories don't have joy levels)
    final categoryCounts = <String, int>{};
    categoryGroups.forEach((category, memories) {
      categoryCounts[category] = memories.length;
    });

    final sortedCategories = categoryCounts.keys.toList()
      ..sort((a, b) => categoryCounts[b]!.compareTo(categoryCounts[a]!));

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
            isChinese ? '分类统计' : 'Category Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '各类别的回忆数量' : 'Memory count per category',
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
                  isChinese ? '暂无分类数据' : 'No category data yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
            )
          else
            ClipRRect(
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: CustomPaint(
                  painter: _HorizontalBarChartPainter(
                    categories: sortedCategories,
                    counts: categoryCounts,
                    isChinese: isChinese,
                  ),
                ),
              ),
            ),
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

    Memory? firstMemory = sortedMemories.isNotEmpty ? sortedMemories.first : null;
    Memory? latestMemory = sortedMemories.isNotEmpty ? sortedMemories.last : null;

    // Find longest story (by description length)
    Memory? longestStory;
    int maxLength = 0;
    for (final memory in widget.memories) {
      final length = (memory.description?.length ?? 0) + (memory.notes?.length ?? 0);
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 20),
                _buildTimeMarker(
                  context,
                  '🌱',
                  isChinese ? '第一个回忆' : 'First Memory',
                  firstMemory!.title,
                  _formatDate(firstMemory.createdAt, isChinese),
                  isChinese,
                ),
                const SizedBox(height: 16),
                if (longestStory != null)
                  _buildTimeMarker(
                    context,
                    '📖',
                    isChinese ? '最长故事' : 'Longest Story',
                    longestStory.title,
                    _formatDate(longestStory.createdAt, isChinese),
                    isChinese,
                  ),
                const SizedBox(height: 16),
                _buildTimeMarker(
                  context,
                  '✨',
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
                      const Text('🎯', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isChinese ? '回忆之旅' : 'Memory Journey',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isChinese
                                  ? '$totalDays 天 · ${widget.memories.length} 个回忆'
                                  : '$totalDays days · ${widget.memories.length} memories',
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
              ],
            ),
    );
  }

  Widget _buildTimeMarker(BuildContext context, String emoji, String label,
      String title, String date, bool isChinese) {
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
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
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
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
    const padding = 40.0;
    const bottomPadding = 60.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - padding - bottomPadding;

    final maxCount = sentimentCounts.values.isEmpty
        ? 1
        : sentimentCounts.values.reduce((a, b) => a > b ? a : b);

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
      final sentiment = emotion['sentiment'] as MemorySentiment;
      final count = sentimentCounts[sentiment] ?? 0;
      final color = emotion['color'] as Color;
      final label = emotion['label'] as String;

      // Calculate bar height
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

      // Draw count
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

      final countY = barHeight > 25 ? y + 6 : y - 22;
      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - textPainter.width) / 2,
          countY,
        ),
      );

      // Draw label below
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      );
      textPainter.layout(maxWidth: barWidth + 20);
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

    // Draw 12 month squares in 2 rows, 6 columns
    for (int i = 0; i < monthsToShow; i++) {
      final monthDate = DateTime(now.year, now.month - (monthsToShow - 1 - i), 1);
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

// HORIZONTAL BAR CHART PAINTER
class _HorizontalBarChartPainter extends CustomPainter {
  final List<String> categories;
  final Map<String, int> counts;
  final bool isChinese;

  _HorizontalBarChartPainter({
    required this.categories,
    required this.counts,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 16.0;
    const labelWidth = 100.0;
    final chartWidth = size.width - labelWidth - padding * 2;
    final barHeight = (size.height - padding * 2) / categories.length;
    final actualBarHeight = barHeight * 0.6;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final colors = [
      const Color(0xFF5ECFB8),
      const Color(0xFFFF9AA2),
      const Color(0xFFFFD93D),
      const Color(0xFF89CFF0),
      const Color(0xFFB794F6),
      const Color(0xFFFF6B6B),
    ];

    final maxCount = counts.values.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final count = counts[category]!;
      final y = padding + (i * barHeight);

      // Draw label
      textPainter.text = TextSpan(
        text: category,
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

      // Draw bar background
      final barX = padding + labelWidth;
      final bgPaint = Paint()..color = const Color(0xFFF5F5F5);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, y + (barHeight - actualBarHeight) / 2,
              chartWidth, actualBarHeight),
          const Radius.circular(6),
        ),
        bgPaint,
      );

      // Draw bar value
      final barWidth = (count / maxCount) * chartWidth;
      final valuePaint = Paint()..color = colors[i % colors.length];

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, y + (barHeight - actualBarHeight) / 2,
              barWidth, actualBarHeight),
          const Radius.circular(6),
        ),
        valuePaint,
      );

      // Draw count
      textPainter.text = TextSpan(
        text: count.toString(),
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
