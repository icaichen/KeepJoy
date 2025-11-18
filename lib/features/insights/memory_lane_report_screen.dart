import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/declutter_item.dart';

class MemoryLaneReportScreen extends StatefulWidget {
  const MemoryLaneReportScreen({super.key, required this.memories});

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
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

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
                        Color(0xFFF5F5F7),
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
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
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

    final maxCount = sentimentCounts.values.isEmpty
        ? 1
        : sentimentCounts.values.reduce((a, b) => a > b ? a : b);

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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ...emotions.map((emotion) {
            final sentiment = emotion['sentiment'] as MemorySentiment;
            final count = sentimentCounts[sentiment] ?? 0;
            final color = emotion['color'] as Color;
            final label = emotion['label'] as String;
            final normalizedWidth = maxCount > 0 ? (count / maxCount) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        if (count > 0)
                          FractionallySizedBox(
                            widthFactor: normalizedWidth,
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        if (count == 0)
                          Container(
                            height: 32,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '0',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
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

    String formatMostActiveLabel() {
      if (mostActiveMonth == null) return isChinese ? '暂无' : 'N/A';
      final parts = mostActiveMonth!.split('-');
      if (parts.length < 2) return mostActiveMonth!;
      final month = int.tryParse(parts[1]);
      final year = parts[0];
      if (month == null) return mostActiveMonth!;
      return isChinese ? '$month月 $year' : '${_getMonthAbbrev(month)} $year';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            isChinese ? '过去12个月的活动' : 'Activity in past 12 months',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
          const SizedBox(height: 24),
          // 2 rows of 6 months each
          Column(
            children: [
              // First row
              Row(
                children: List.generate(6, (index) {
                  final monthDate = DateTime(
                    now.year,
                    now.month - (11 - index),
                    1,
                  );
                  final monthKey =
                      '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
                  final count = monthlyData[monthKey] ?? 0;
                  final intensity = maxCount > 0 ? (count / maxCount) : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getHeatmapColor(intensity),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isChinese
                                ? '${monthDate.month}月'
                                : _getMonthAbbrev(monthDate.month),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
              // Second row
              Row(
                children: List.generate(6, (index) {
                  final monthDate = DateTime(
                    now.year,
                    now.month - (5 - index),
                    1,
                  );
                  final monthKey =
                      '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
                  final count = monthlyData[monthKey] ?? 0;
                  final intensity = maxCount > 0 ? (count / maxCount) : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getHeatmapColor(intensity),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isChinese
                                ? '${monthDate.month}月'
                                : _getMonthAbbrev(monthDate.month),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      color: _getHeatmapColor(index / 4),
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
                child: Container(
                  constraints: const BoxConstraints(minHeight: 96),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '最活跃' : 'Most Active',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMostActiveLabel(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 96),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '最长连续' : 'Longest Streak',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isChinese ? '$longestStreak 个月' : '$longestStreak months',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 96),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '峰值活动' : 'Peak Activity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isChinese ? '$maxMonthCount 次' : '$maxMonthCount entries',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        // Find matching enum category
        final declutterCategory = DeclutterCategory.values.firstWhere(
          (cat) => cat.english == memory.category || cat.chinese == memory.category,
          orElse: () => DeclutterCategory.miscellaneous,
        );
        categoryCounts[declutterCategory] = (categoryCounts[declutterCategory] ?? 0) + 1;
      }
    }

    // Sort categories by count (descending)
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            child: SizedBox(
              width: double.infinity,
              height: 260,
              child: CustomPaint(
                painter: _CategoryVerticalBarChartPainter(
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

  Color _getHeatmapColor(double intensity) {
    if (intensity == 0) {
      return const Color(0xFFE0E0E0);
    } else if (intensity <= 0.25) {
      return const Color(0xFFE8D9F7);
    } else if (intensity <= 0.5) {
      return const Color(0xFFD4B6F0);
    } else if (intensity <= 0.75) {
      return const Color(0xFFC39BE8);
    } else {
      return const Color(0xFFB794F6);
    }
  }

  Color _getHeatmapColorByCount(int count) {
    if (count == 0) {
      return const Color(0xFFE0E0E0); // Gray
    } else if (count <= 3) {
      return const Color(0xFFE8D9F7); // Super light purple
    } else if (count <= 6) {
      return const Color(0xFFD4B6F0); // Light purple
    } else if (count <= 9) {
      return const Color(0xFFC39BE8); // Medium purple
    } else {
      return const Color(0xFFB794F6); // Dark purple
    }
  }

  void _showHeatmapLegendDialog(BuildContext context, bool isChinese) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    isChinese ? '活动等级' : 'Activity Levels',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...[
                  {'range': '0', 'count': 0},
                  {'range': '1-3', 'count': 2},
                  {'range': '4-6', 'count': 5},
                  {'range': '7-9', 'count': 8},
                  {'range': '10+', 'count': 10},
                ].map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getHeatmapColorByCount(item['count'] as int),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          item['range'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF374151),
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
      final monthDate = DateTime(
        now.year,
        now.month - (monthsToShow - 1 - i),
        1,
      );
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
    const padding = 32.0;
    const bottomPadding = 80.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding - bottomPadding;
    final double barWidth = categories.isEmpty
        ? 0.0
        : (chartWidth / categories.length) * 0.5;
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

      // Count label
      textPainter.text = TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: barHeight > 28 ? Colors.white : const Color(0xFF666666),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      final countY = barHeight > 28 ? y + 6 : y - textPainter.height - 4;
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
