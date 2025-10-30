import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/memory_lane_report_screen.dart';
import 'package:keepjoy_app/features/insights/resell_analysis_report_screen.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/resell_item.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.deepCleaningSessions,
    required this.streak,
    required this.memories,
  });

  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;
  final int streak;
  final List<Memory> memories;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _showJoyPercent = true; // true = Joy Percent, false = Joy Count
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

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final sessionsThisMonth = widget.deepCleaningSessions
        .where(
          (session) =>
              !session.startTime.isBefore(monthStart) &&
              session.startTime.isBefore(nextMonthStart),
        )
        .toList();

    final areaCounts = <String, int>{};
    for (final session in sessionsThisMonth) {
      areaCounts.update(session.area, (value) => value + 1, ifAbsent: () => 1);
    }

    // Calculate Joy Index (average joy level from items with joyLevel)
    final itemsWithJoy = widget.declutteredItems
        .where((item) => item.joyLevel != null)
        .toList();
    final avgJoyIndex = itemsWithJoy.isEmpty
        ? 0.0
        : itemsWithJoy.map((item) => item.joyLevel!).reduce((a, b) => a + b) /
              itemsWithJoy.length;

    // Calculate New Life Value (total sold price from resell items)
    final soldItems = widget.resellItems.where(
      (item) => item.soldPrice != null,
    );
    final totalValue = soldItems.isEmpty
        ? 0.0
        : soldItems.map((item) => item.soldPrice!).reduce((a, b) => a + b);

    // Calculate average focus index from sessions
    final sessionsWithFocus = sessionsThisMonth.where(
      (s) => s.focusIndex != null,
    );
    final avgFocusIndex = sessionsWithFocus.isEmpty
        ? 0.0
        : sessionsWithFocus.map((s) => s.focusIndex!).reduce((a, b) => a + b) /
              sessionsWithFocus.length;

    // Calculate streak
    final streakDays = widget.streak;

    final metrics = <_MetricCardData>[
      _MetricCardData(
        icon: Icons.cleaning_services_rounded,
        iconColor: const Color(0xFFB794F6),
        bgColor: const Color(0xFFF3EBFF),
        value: sessionsThisMonth.length.toString(),
        unit: isChinese ? '次' : 'times',
        title: isChinese ? '深度整理' : 'Deep Cleaning',
      ),
      _MetricCardData(
        icon: Icons.inventory_2_rounded,
        iconColor: const Color(0xFF5ECFB8),
        bgColor: const Color(0xFFE6F7F4),
        value: widget.declutteredItems.length.toString(),
        unit: isChinese ? '件' : 'items',
        title: isChinese ? '已整理物品' : 'Items Sorted',
      ),
      _MetricCardData(
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFFFF9AA2),
        bgColor: const Color(0xFFFFF0F2),
        value: avgJoyIndex.toStringAsFixed(1),
        unit: '',
        title: isChinese ? '心动指数' : 'Joy Index',
      ),
      _MetricCardData(
        icon: Icons.attach_money_rounded,
        iconColor: const Color(0xFFFFD93D),
        bgColor: const Color(0xFFFFF9E6),
        value: totalValue.toStringAsFixed(0),
        unit: isChinese ? '元' : '\$',
        title: isChinese ? '新生价值' : 'New Life Value',
      ),
      _MetricCardData(
        icon: Icons.track_changes_rounded,
        iconColor: const Color(0xFF89CFF0),
        bgColor: const Color(0xFFE6F4F9),
        value: avgFocusIndex.toStringAsFixed(1),
        unit: '',
        title: isChinese ? '专注度' : 'Focus Level',
      ),
      _MetricCardData(
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFFF6B6B),
        bgColor: const Color(0xFFFFEDED),
        value: streakDays.toString(),
        unit: isChinese ? '天' : 'days',
        title: isChinese ? '坚持天数' : 'Streak',
      ),
    ];

    final summaryTitle = isChinese ? '洞察' : 'Insights';

    final topPadding = MediaQuery.of(context).padding.top;

    // Calculate scroll-based animations
    const expandedHeight = 280.0;
    final minHeight = topPadding + kToolbarHeight;
    final scrollProgress = (_scrollOffset / (expandedHeight - minHeight)).clamp(0.0, 1.0);

    // Short header is visible during scroll but fades out when title is gone
    final shortHeaderOpacity = scrollProgress > 0.01 && scrollProgress < 0.95 ? 1.0 : 0.0;

    // Real header appears only when scrolling is complete
    final realHeaderOpacity = scrollProgress >= 0.95 ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 渐变背景 + 大标题 + Profile图标 (作为普通内容，会滚动)
              SliverToBoxAdapter(
                child: Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFB794F6), // Purple
                        Color(0xFF9B7FE8),
                        Color(0xFFF2F2F7), // White at 1/3
                      ],
                      stops: [0.0, 0.33, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Large title
                      Positioned(
                        left: 24,
                        right: 80,
                        bottom: 60,
                        child: Text(
                          summaryTitle,
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: -0.6,
                            height: 1.05,
                          ),
                        ),
                      ),
                      // Profile Icon
                      Positioned(
                        right: 16,
                        top: topPadding + 12,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFFB794F6),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          // Content cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  // Monthly Achievement Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
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
                            isChinese ? '本月成就' : 'Monthly Achievements',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isChinese
                                ? '共处理 ${widget.declutteredItems.length} 件物品，释放空间'
                                : 'Processed ${widget.declutteredItems.length} items',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black54),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 130,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: metrics.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index < metrics.length - 1
                                        ? 12
                                        : 0,
                                  ),
                                  child: _buildMetricCard(
                                    context,
                                    metrics[index],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMonthlyReportCard(
                      context,
                      isChinese,
                      areaCounts,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildJoyIndexCard(context, isChinese),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildLetGoDetailsCard(context, isChinese),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildResellAnalysisCard(context, isChinese),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMemoryLaneCard(context, isChinese),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      // Short header bar that covers scrolling content (2/3 height of real header)
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: Opacity(
            opacity: shortHeaderOpacity,
            child: Container(
              height: (topPadding + kToolbarHeight) * 0.67,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFB794F6),
                    Color(0xFF9B7FE8),
                  ],
                ),
              ),
            ),
          ),
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
                color: Color(0xFFF2F2F7),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E5EA),
                    width: 0.5,
                  ),
                ),
              ),
              padding: EdgeInsets.only(top: topPadding),
              alignment: Alignment.center,
              child: Text(
                summaryTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildMetricCard(BuildContext context, _MetricCardData metric) {
    return Container(
      width: 140,
      height: 120,
      decoration: BoxDecoration(
        color: metric.bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: metric.iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(metric.icon, color: metric.iconColor, size: 18),
          ),
          const SizedBox(height: 6),
          // Value and unit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  metric.value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (metric.unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 1),
                  child: Text(
                    metric.unit,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          // Title
          Text(
            metric.title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReportCard(
    BuildContext context,
    bool isChinese,
    Map<String, int> areaCounts,
  ) {
    // Calculate cleaning frequency by type
    final joyDeclutterCount = widget.declutteredItems.length;
    final deepCleaningCount = widget.deepCleaningSessions.length;
    final quickTidyCount = 0; // TODO: Add when we have quick tidy feature

    // Calculate category counts
    final categoryCounts = <String, int>{};
    for (final item in widget.declutteredItems) {
      final categoryName = item.category.toString().split('.').last;
      categoryCounts[categoryName] = (categoryCounts[categoryName] ?? 0) + 1;
    }

    // Get max count for heatmap
    final maxAreaCount = areaCounts.isEmpty
        ? 1
        : areaCounts.values.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
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
          // Title
          Text(
            isChinese ? '本月整理报告' : 'Monthly Report',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // 1. 整理频次 - Cleaning Frequency
          _buildReportSection(
            context,
            title: isChinese ? '整理频次' : 'Cleaning Frequency',
            subtitle: isChinese
                ? '回顾整理频次、类别与区域'
                : 'Review frequency, categories & areas',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFrequencyItem(
                  context,
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFF5ECFB8),
                  count: deepCleaningCount,
                  label: isChinese ? '极速大扫除' : 'Deep Clean',
                ),
                _buildFrequencyItem(
                  context,
                  icon: Icons.pan_tool_rounded,
                  color: const Color(0xFFFF9AA2),
                  count: joyDeclutterCount,
                  label: isChinese ? '心动整理' : 'Joy Declutter',
                ),
                _buildFrequencyItem(
                  context,
                  icon: Icons.description_rounded,
                  color: const Color(0xFF89CFF0),
                  count: quickTidyCount,
                  label: isChinese ? '心动小帮手' : 'Quick Tidy',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. 整理类别 - Categories
          _buildReportSection(
            context,
            title: isChinese ? '整理类别' : 'Categories',
            child: categoryCounts.isEmpty
                ? Text(
                    isChinese
                        ? '本月还没有分类整理记录，先挑一件物品开始吧。'
                        : 'No categorized items yet. Start with one item.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryCounts.entries.map((entry) {
                      return Chip(
                        label: Text('${entry.key} (${entry.value})'),
                        backgroundColor: const Color(0xFFF5F5F5),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 20),

          // 3. 整理区域 - Areas with heatmap
          _buildReportSection(
            context,
            title: isChinese ? '整理区域' : 'Cleaning Areas',
            child: areaCounts.isEmpty
                ? Text(
                    isChinese ? '还没有记录整理区域。' : 'No areas recorded yet.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: areaCounts.entries.map((entry) {
                      final intensity = entry.value / maxAreaCount;
                      final color = Color.lerp(
                        const Color(0xFFE0E0E0),
                        const Color(0xFF5ECFB8),
                        intensity,
                      )!;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.key} (${entry.value})',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: intensity > 0.5
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 20),

          // 4. 整理前后对比 - Before/After Comparison
          _buildReportSection(
            context,
            title: isChinese ? '整理前后对比' : 'Before & After',
            child: widget.deepCleaningSessions.isEmpty
                ? Text(
                    isChinese
                        ? '这个月还没有拍下整理前后的对比，下次记得记录成果。'
                        : 'No before/after photos yet. Remember to record your progress next time.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.deepCleaningSessions.take(3).map((
                      session,
                    ) {
                      final improvement =
                          session.beforeMessinessIndex != null &&
                              session.afterMessinessIndex != null
                          ? ((session.beforeMessinessIndex! -
                                        session.afterMessinessIndex!) /
                                    session.beforeMessinessIndex! *
                                    100)
                                .toStringAsFixed(0)
                          : null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${session.area}: ${improvement != null ? (isChinese ? "改善 $improvement%" : "$improvement% improvement") : (isChinese ? "完成整理" : "Completed")}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black87),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoyIndexCard(BuildContext context, bool isChinese) {
    // Calculate joy index trend over selected period (last 30 days)
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Group items by week
    final weeklyJoyData = <int, List<int>>{}; // week -> list of joy levels
    final weeklyJoyCount = <int, int>{}; // week -> count of items with joy
    final weeklyTotalCount = <int, int>{}; // week -> total items decluttered

    for (final item in widget.declutteredItems) {
      if (item.createdAt.isAfter(thirtyDaysAgo)) {
        final weekIndex =
            now.difference(item.createdAt).inDays ~/
            7; // 0 = this week, 1 = last week, etc.
        if (weekIndex < 5) {
          // Only last 5 weeks
          weeklyTotalCount[weekIndex] = (weeklyTotalCount[weekIndex] ?? 0) + 1;

          if (item.joyLevel != null && item.joyLevel! > 0) {
            weeklyJoyData.putIfAbsent(weekIndex, () => []).add(item.joyLevel!);
            weeklyJoyCount[weekIndex] = (weeklyJoyCount[weekIndex] ?? 0) + 1;
          }
        }
      }
    }

    // Calculate weekly joy percent
    final weeklyJoyPercent = <int, double>{};
    weeklyTotalCount.forEach((week, total) {
      final joyCount = weeklyJoyCount[week] ?? 0;
      weeklyJoyPercent[week] = total > 0 ? (joyCount / total * 100) : 0.0;
    });

    // Calculate average joy percent
    final avgJoyPercent = weeklyJoyPercent.isEmpty
        ? 0.0
        : weeklyJoyPercent.values.reduce((a, b) => a + b) /
              weeklyJoyPercent.length;

    // Calculate total joy count
    final itemsWithJoy = widget.declutteredItems
        .where((item) => item.joyLevel != null && item.joyLevel! > 0)
        .toList();
    final totalJoyCount = itemsWithJoy.length;

    // Determine trend
    String trendText;
    String trendIcon;
    Color trendColor;

    if (weeklyJoyPercent.length >= 2) {
      final weeks = weeklyJoyPercent.keys.toList()..sort();
      final recentWeek = weeklyJoyPercent[weeks.first] ?? 0;
      final olderWeek = weeklyJoyPercent[weeks.last] ?? 0;

      if (recentWeek > olderWeek) {
        trendText = isChinese ? '上升' : 'Rising';
        trendIcon = '↑';
        trendColor = const Color(0xFF4CAF50);
      } else if (recentWeek < olderWeek) {
        trendText = isChinese ? '下降' : 'Falling';
        trendIcon = '↓';
        trendColor = const Color(0xFFF44336);
      } else {
        trendText = isChinese ? '稳定' : 'Stable';
        trendIcon = '→';
        trendColor = const Color(0xFF9E9E9E);
      }
    } else {
      trendText = isChinese ? '暂无' : 'N/A';
      trendIcon = '—';
      trendColor = const Color(0xFF9E9E9E);
    }

    return Container(
      width: double.infinity,
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
          // Title
          Text(
            isChinese ? '心动指数趋势' : 'Joy Index Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '年度心动轨迹概览' : 'Annual joy trajectory overview',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Toggle between Joy Percent and Joy Count
          Row(
            children: [
              Text(
                isChinese ? '趋势指标' : 'Trend Metric',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showJoyPercent = true;
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _showJoyPercent
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _showJoyPercent
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isChinese ? '心动比例' : 'Joy Percent',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: _showJoyPercent
                                        ? Colors.black87
                                        : Colors.black45,
                                    fontWeight: _showJoyPercent
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showJoyPercent = false;
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: !_showJoyPercent
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: !_showJoyPercent
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isChinese ? '心动次数' : 'Joy Count',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: !_showJoyPercent
                                        ? Colors.black87
                                        : Colors.black45,
                                    fontWeight: !_showJoyPercent
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart
          if (weeklyJoyPercent.isEmpty && weeklyJoyCount.isEmpty)
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Text(
                isChinese
                    ? '还没有足够的数据来显示趋势'
                    : 'Not enough data to show trend yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _JoyTrendChartPainter(
                  weeklyData: _showJoyPercent
                      ? weeklyJoyPercent
                      : weeklyJoyCount.map((k, v) => MapEntry(k, v.toDouble())),
                  maxWeeks: 5,
                  isPercent: _showJoyPercent,
                  isChinese: isChinese,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Summary stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                label: isChinese ? '平均心动比例' : 'Avg Joy %',
                value: '${avgJoyPercent.toStringAsFixed(0)}%',
                color: const Color(0xFFFF9AA2),
              ),
              _buildStatItem(
                context,
                label: isChinese ? '总心动次数' : 'Total Joy',
                value: totalJoyCount.toString(),
                color: const Color(0xFF5ECFB8),
              ),
              _buildStatItem(
                context,
                label: isChinese ? '趋势分析' : 'Trend',
                value: '$trendIcon $trendText',
                color: trendColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildReportSection(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildFrequencyItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLetGoDetailsCard(BuildContext context, bool isChinese) {
    final theme = Theme.of(context);

    // Calculate counts for each disposal method
    final resellCount = widget.declutteredItems
        .where((item) => item.status == DeclutterStatus.resell)
        .length;
    final recycleCount = widget.declutteredItems
        .where((item) => item.status == DeclutterStatus.recycle)
        .length;
    final donateCount = widget.declutteredItems
        .where((item) => item.status == DeclutterStatus.donate)
        .length;
    final discardCount = widget.declutteredItems
        .where((item) => item.status == DeclutterStatus.discard)
        .length;

    final total = resellCount + recycleCount + donateCount + discardCount;

    // Define colors for each category
    const resellColor = Color(0xFFFFD93D); // Yellow
    const recycleColor = Color(0xFF5ECFB8); // Teal
    const donateColor = Color(0xFFFF9AA2); // Pink
    const discardColor = Color(0xFF9E9E9E); // Gray

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '放手详情' : 'Letting Go Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? '了解不同去向的放手占比' : 'See how items found their next home',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          // Pie chart
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: total > 0
                  ? CustomPaint(
                      painter: _DonutChartPainter(
                        resellCount: resellCount,
                        recycleCount: recycleCount,
                        donateCount: donateCount,
                        discardCount: discardCount,
                        total: total,
                        resellColor: resellColor,
                        recycleColor: recycleColor,
                        donateColor: donateColor,
                        discardColor: discardColor,
                      ),
                    )
                  : CustomPaint(painter: _EmptyDonutChartPainter()),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                color: resellColor,
                label: isChinese ? '出售' : 'Sell',
                count: resellCount,
                theme: theme,
              ),
              _buildLegendItem(
                color: recycleColor,
                label: isChinese ? '回收' : 'Recycle',
                count: recycleCount,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                color: donateColor,
                label: isChinese ? '捐赠' : 'Donate',
                count: donateCount,
                theme: theme,
              ),
              _buildLegendItem(
                color: discardColor,
                label: isChinese ? '🗑️' : 'Discard',
                count: discardCount,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
        ),
        const SizedBox(width: 8),
        Text(
          '$count 件',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildResellAnalysisCard(BuildContext context, bool isChinese) {
    // Calculate resell metrics
    final soldItems = widget.resellItems
        .where((item) => item.status == ResellStatus.sold)
        .toList();
    final totalSoldItems = soldItems.length;

    // Average transaction price
    final avgPrice = soldItems.isEmpty
        ? 0.0
        : soldItems
                  .map((item) => item.soldPrice ?? 0.0)
                  .reduce((a, b) => a + b) /
              totalSoldItems;

    // Average days to sell (from creation to sold date)
    final avgDays = soldItems.isEmpty
        ? 0.0
        : soldItems
                  .where((item) => item.soldDate != null)
                  .map(
                    (item) => item.soldDate!.difference(item.createdAt).inDays,
                  )
                  .reduce((a, b) => a + b) /
              soldItems.where((item) => item.soldDate != null).length;

    // Success rate (sold / total resell items)
    final successRate = widget.resellItems.isEmpty
        ? 0.0
        : (totalSoldItems / widget.resellItems.length) * 100;

    // Total revenue
    final totalRevenue = soldItems.isEmpty
        ? 0.0
        : soldItems
              .map((item) => item.soldPrice ?? 0.0)
              .reduce((a, b) => a + b);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResellAnalysisReportScreen(
              resellItems: widget.resellItems,
              declutteredItems: widget.declutteredItems,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF9E6), Color(0xFFFFECB3)],
          ),
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD93D).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFFFFD93D),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '转卖分析' : 'Resell Analysis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        isChinese ? '点击查看完整报告' : 'Tap to view full report',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Metrics grid
            Row(
              children: [
                Expanded(
                  child: _buildResellMetric(
                    context,
                    label: isChinese ? '平均交易价' : 'Avg Price',
                    value: '¥${avgPrice.toStringAsFixed(0)}',
                    icon: Icons.payments_rounded,
                    color: const Color(0xFFFFD93D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResellMetric(
                    context,
                    label: isChinese ? '平均售出天数' : 'Avg Days',
                    value: avgDays.toStringAsFixed(0),
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFF89CFF0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildResellMetric(
                    context,
                    label: isChinese ? '成交率' : 'Success Rate',
                    value: '${successRate.toStringAsFixed(0)}%',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF5ECFB8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResellMetric(
                    context,
                    label: isChinese ? '总收入' : 'Total Revenue',
                    value: '¥${totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFFF9AA2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResellMetric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryLaneCard(BuildContext context, bool isChinese) {
    final sortedMemories = widget.memories.isEmpty
        ? <Memory>[]
        : (List<Memory>.from(widget.memories)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));

    final firstMemory = sortedMemories.isNotEmpty ? sortedMemories.first : null;
    final latestMemory = sortedMemories.isNotEmpty ? sortedMemories.last : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryLaneReportScreen(
              memories: widget.memories,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EBFF), Color(0xFFE6D5FF)],
          ),
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB794F6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFFB794F6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '记忆长廊' : 'Memory Lane',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        isChinese ? '重温你的整理旅程' : 'Revisit your journey',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.memories.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    isChinese ? '暂无回忆' : 'No memories yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('🌱', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isChinese ? '第一个回忆' : 'First Memory',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                firstMemory!.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('✨', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isChinese ? '最新回忆' : 'Latest Memory',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                latestMemory!.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for donut chart
class _DonutChartPainter extends CustomPainter {
  final int resellCount;
  final int recycleCount;
  final int donateCount;
  final int discardCount;
  final int total;
  final Color resellColor;
  final Color recycleColor;
  final Color donateColor;
  final Color discardColor;

  _DonutChartPainter({
    required this.resellCount,
    required this.recycleCount,
    required this.donateCount,
    required this.discardCount,
    required this.total,
    required this.resellColor,
    required this.recycleColor,
    required this.donateColor,
    required this.discardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - innerRadius;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    // Draw resell segment
    if (resellCount > 0) {
      final sweepAngle = (resellCount / total) * 2 * 3.14159;
      paint.color = resellColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw recycle segment
    if (recycleCount > 0) {
      final sweepAngle = (recycleCount / total) * 2 * 3.14159;
      paint.color = recycleColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw donate segment
    if (donateCount > 0) {
      final sweepAngle = (donateCount / total) * 2 * 3.14159;
      paint.color = donateColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw discard segment
    if (discardCount > 0) {
      final sweepAngle = (discardCount / total) * 2 * 3.14159;
      paint.color = discardColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Empty donut chart painter (all gray)
class _EmptyDonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - innerRadius
      ..color = const Color(0xFFE0E0E0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
      0,
      2 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Joy trend chart painter (line chart)
class _JoyTrendChartPainter extends CustomPainter {
  final Map<int, double> weeklyData; // week index -> value (percent or count)
  final int maxWeeks;
  final bool isPercent;
  final bool isChinese;

  _JoyTrendChartPainter({
    required this.weeklyData,
    required this.maxWeeks,
    required this.isPercent,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weeklyData.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFFF9AA2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFFF9AA2).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = const Color(0xFFFF9AA2)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;

    final textPaint = TextPainter(textDirection: TextDirection.ltr);

    // Calculate dimensions
    final padding = 30.0;
    final bottomPadding = 40.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - padding - bottomPadding;

    // Find max value for scaling
    final maxValue = isPercent
        ? 100.0
        : weeklyData.values.reduce((a, b) => a > b ? a : b) *
              1.2; // Add 20% padding for count

    // Draw horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = padding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Prepare data points (reverse order so week 0 is on the right)
    final points = <Offset>[];
    final labels = <String>[];
    final sortedWeeks = weeklyData.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order

    // Generate month labels
    final now = DateTime.now();
    for (int i = 0; i < sortedWeeks.length; i++) {
      final week = sortedWeeks[i];
      final value = weeklyData[week]!;

      // X position: spread evenly across chart width
      final x =
          padding +
          (chartWidth * i / (sortedWeeks.length - 1).clamp(1, double.infinity));

      // Y position: scale based on max value
      final normalizedValue = value / maxValue;
      final y = padding + (chartHeight * (1 - normalizedValue));

      points.add(Offset(x, y));

      // Calculate which month this week belongs to
      final weekDate = now.subtract(Duration(days: week * 7));
      final monthLabel = '${weekDate.month}${isChinese ? '月' : 'M'}';
      labels.add(monthLabel);
    }

    if (points.isEmpty) return;

    // Draw filled area under the line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height - bottomPadding);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlPoint1 = Offset(
        current.dx + (next.dx - current.dx) / 3,
        current.dy,
      );
      final controlPoint2 = Offset(
        current.dx + 2 * (next.dx - current.dx) / 3,
        next.dy,
      );
      fillPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        next.dx,
        next.dy,
      );
    }

    fillPath.lineTo(points.last.dx, size.height - bottomPadding);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlPoint1 = Offset(
        current.dx + (next.dx - current.dx) / 3,
        current.dy,
      );
      final controlPoint2 = Offset(
        current.dx + 2 * (next.dx - current.dx) / 3,
        next.dy,
      );
      linePath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        next.dx,
        next.dy,
      );
    }

    canvas.drawPath(linePath, paint);

    // Draw dots and labels at each data point
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw dot
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);

      // Draw month label below
      textPaint.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPaint.layout();
      textPaint.paint(
        canvas,
        Offset(
          point.dx - textPaint.width / 2,
          size.height - bottomPadding + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MetricCardData {
  const _MetricCardData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.unit,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String unit;
  final String title;
}
