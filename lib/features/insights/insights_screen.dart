import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/resell_item.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.deepCleaningSessions,
    required this.streak,
  });

  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;
  final int streak;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  static const _chipColors = <Color>[
    Color(0xFF52C7B8),
    Color(0xFF9E7DB6),
    Color(0xFFF0AD57),
    Color(0xFFB0B5FF),
    Color(0xFFD18BBF),
  ];

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
    final l10n = AppLocalizations.of(context)!;
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
    final itemsWithJoy = widget.declutteredItems.where((item) => item.joyLevel != null).toList();
    final avgJoyIndex = itemsWithJoy.isEmpty
        ? 0.0
        : itemsWithJoy.map((item) => item.joyLevel!).reduce((a, b) => a + b) / itemsWithJoy.length;

    // Calculate New Life Value (total sold price from resell items)
    final soldItems = widget.resellItems.where((item) => item.soldPrice != null);
    final totalValue = soldItems.isEmpty
        ? 0.0
        : soldItems.map((item) => item.soldPrice!).reduce((a, b) => a + b);

    // Calculate average focus index from sessions
    final sessionsWithFocus = sessionsThisMonth.where((s) => s.focusIndex != null);
    final avgFocusIndex = sessionsWithFocus.isEmpty
        ? 0.0
        : sessionsWithFocus.map((s) => s.focusIndex!).reduce((a, b) => a + b) / sessionsWithFocus.length;

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

    final gradientHeight = 200.0; // Fixed gradient height

    // Calculate scroll progress based on how much the gradient has scrolled away
    final maxScroll = gradientHeight; // When gradient title reaches header
    final scrollProgress = (_scrollOffset / maxScroll).clamp(0.0, 1.0);

    // Header expands from thin to full height
    final headerHeight = 20.0 + (40.0 * scrollProgress); // 20px → 60px

    // Semi-transparent blurred background
    final headerBgColor = Color.lerp(
      Colors.transparent,
      Colors.white.withValues(alpha: 0.8),
      scrollProgress,
    )!;

    // Header title slides up from bottom of header and moves to center
    final headerTitleOpacity = scrollProgress;
    final headerTitleColor = Colors.black87;

    // Title slides up from bottom (starts at bottom of header, ends at center)
    final titleVerticalOffset = 20.0 * (1.0 - scrollProgress); // Slides up from +20 to 0

    // Title alignment (starts left, moves to center)
    final titleAlignment = Alignment.lerp(
      Alignment.centerLeft,
      Alignment.center,
      scrollProgress,
    )!;

    // Icon opacity (fades out as we scroll)
    final iconOpacity = 1.0 - scrollProgress;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B4E71), // Purple at top
              Color(0xFF8A6E8F), // Mid purple
              Color(0xFF95E3C6), // Mint green
              Color(0xFFD5F2E9), // Light mint
              Color(0xFFF5FBF8), // Very light mint
              Colors.white,      // Fade to white
            ],
            stops: [0.0, 0.15, 0.3, 0.45, 0.6, 1.0],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Sticky header (thin at first, expands on scroll)
            SliverAppBar(
              pinned: true,
              toolbarHeight: headerHeight,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10.0 * scrollProgress,
                    sigmaY: 10.0 * scrollProgress,
                  ),
                  child: Container(
                    color: headerBgColor,
                    child: SafeArea(
                      child: Container(
                        height: headerHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Stack(
                          children: [
                            // Header title (slides up from bottom and fades in)
                            if (headerTitleOpacity > 0.01)
                              Positioned(
                                left: titleAlignment == Alignment.center ? 0 : 0,
                                right: titleAlignment == Alignment.center ? 0 : null,
                                top: (headerHeight / 2) - 12 + titleVerticalOffset,
                                child: Opacity(
                                  opacity: headerTitleOpacity,
                                  child: Text(
                                    isChinese ? '洞察' : 'Insight',
                                    textAlign: titleAlignment == Alignment.center
                                        ? TextAlign.center
                                        : TextAlign.left,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: headerTitleColor,
                                    ),
                                  ),
                                ),
                              ),
                            // Profile icon (only visible initially)
                            if (iconOpacity > 0.01)
                              Positioned(
                                right: 0,
                                top: (headerHeight / 2) - 18,
                                child: Opacity(
                                  opacity: iconOpacity,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
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
            ),
            // Big title "洞察" at top left
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Text(
                    isChinese ? '洞察' : 'Insight',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 34,
                    ),
                  ),
                ),
              ),
            ),
            // Content area with cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Monthly Achievement Card (white container with carousel inside)
                    Container(
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
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isChinese
                                ? '共处理 ${widget.declutteredItems.length} 件物品，释放空间'
                                : 'Processed ${widget.declutteredItems.length} items',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Horizontal scrollable metric cards inside container
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: metrics.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index < metrics.length - 1 ? 12 : 0,
                                  ),
                                  child: _buildMetricCard(context, metrics[index]),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Monthly Report Card - 本月整理报告
                  _buildMonthlyReportCard(context, isChinese, areaCounts),
                  const SizedBox(height: 24),
                  // Other cards
                  Column(
                    children: [
                      _buildAreaSummaryCard(
                        context: context,
                        title: isChinese ? '整理区域' : l10n.cleaningAreas,
                        areaCounts: areaCounts,
                        isChinese: isChinese,
                      ),
                      const SizedBox(height: 16),
                      _buildLetGoDetailsCard(context, isChinese),
                      const SizedBox(height: 32),
                    ],
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

  Widget _buildMetricCard(BuildContext context, _MetricCardData metric) {
    return Container(
      width: 140,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: metric.iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              metric.icon,
              color: metric.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          // Value and unit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                metric.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              if (metric.unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 2),
                  child: Text(
                    metric.unit,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            metric.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
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
      if (item.category != null) {
        final categoryName = item.category.toString().split('.').last;
        categoryCounts[categoryName] = (categoryCounts[categoryName] ?? 0) + 1;
      }
    }

    // Get max count for heatmap
    final maxAreaCount = areaCounts.isEmpty ? 1 : areaCounts.values.reduce((a, b) => a > b ? a : b);

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
            subtitle: isChinese ? '回顾整理频次、类别与区域' : 'Review frequency, categories & areas',
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
                    isChinese ? '本月还没有分类整理记录，先挑一件物品开始吧。' : 'No categorized items yet. Start with one item.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.key} (${entry.value})',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: intensity > 0.5 ? Colors.white : Colors.black87,
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
                    isChinese ? '这个月还没有拍下整理前后的对比，下次记得记录成果。' : 'No before/after photos yet. Remember to record your progress next time.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.deepCleaningSessions.take(3).map((session) {
                      final improvement = session.beforeMessinessIndex != null && session.afterMessinessIndex != null
                          ? ((session.beforeMessinessIndex! - session.afterMessinessIndex!) / session.beforeMessinessIndex! * 100).toStringAsFixed(0)
                          : null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${session.area}: ${improvement != null ? (isChinese ? "改善 $improvement%" : "$improvement% improvement") : (isChinese ? "完成整理" : "Completed")}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAreaSummaryCard({
    required BuildContext context,
    required String title,
    required Map<String, int> areaCounts,
    required bool isChinese,
  }) {
    final theme = Theme.of(context);
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
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            areaCounts.isEmpty
                ? (isChinese
                      ? '本月还没有分类整理记录，先挑一件物品开始吧。'
                      : 'No categorized sessions yet this month. Start with one area!')
                : (isChinese
                      ? '最近整理的区域分布如下。'
                      : 'Here’s where you’ve been tidying recently.'),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          if (areaCounts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.layers_outlined,
                color: Colors.black26,
                size: 36,
              ),
            )
          else
            Builder(
              builder: (_) {
                final entries = areaCounts.entries.toList();
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < entries.length; i++)
                      _buildAreaChip(
                        theme,
                        entries[i].key,
                        entries[i].value,
                        _chipColors[i % _chipColors.length],
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAreaChip(ThemeData theme, String area, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: count == 0 ? color.withValues(alpha: 0.2) : color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$area ×$count',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: count == 0 ? color.withValues(alpha: 0.9) : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLetGoDetailsCard(BuildContext context, bool isChinese) {
    final theme = Theme.of(context);

    // Calculate counts for each disposal method
    final resellCount = widget.declutteredItems.where((item) => item.status == DeclutterStatus.resell).length;
    final recycleCount = widget.declutteredItems.where((item) => item.status == DeclutterStatus.recycle).length;
    final donateCount = widget.declutteredItems.where((item) => item.status == DeclutterStatus.donate).length;
    final discardCount = widget.declutteredItems.where((item) => item.status == DeclutterStatus.discard).length;

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
                  : CustomPaint(
                      painter: _EmptyDonutChartPainter(),
                    ),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
          ),
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
