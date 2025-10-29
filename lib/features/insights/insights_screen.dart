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
        subtitle: isChinese ? '本月完成' : 'This month',
      ),
      _MetricCardData(
        icon: Icons.inventory_2_rounded,
        iconColor: const Color(0xFF5ECFB8),
        bgColor: const Color(0xFFE6F7F4),
        value: widget.declutteredItems.length.toString(),
        unit: isChinese ? '件' : 'items',
        title: isChinese ? '已整理物品' : 'Items Sorted',
        subtitle: isChinese ? '累计整理' : 'Total organized',
      ),
      _MetricCardData(
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFFFF9AA2),
        bgColor: const Color(0xFFFFF0F2),
        value: avgJoyIndex.toStringAsFixed(1),
        unit: '',
        title: isChinese ? '心动指数' : 'Joy Index',
        subtitle: isChinese ? '平均快乐值' : 'Average joy level',
      ),
      _MetricCardData(
        icon: Icons.attach_money_rounded,
        iconColor: const Color(0xFFFFD93D),
        bgColor: const Color(0xFFFFF9E6),
        value: totalValue.toStringAsFixed(0),
        unit: isChinese ? '元' : '\$',
        title: isChinese ? '新生价值' : 'New Life Value',
        subtitle: isChinese ? '转售收入' : 'Resale income',
      ),
      _MetricCardData(
        icon: Icons.track_changes_rounded,
        iconColor: const Color(0xFF89CFF0),
        bgColor: const Color(0xFFE6F4F9),
        value: avgFocusIndex.toStringAsFixed(1),
        unit: '',
        title: isChinese ? '专注度' : 'Focus Level',
        subtitle: isChinese ? '整理时的专注' : 'During cleaning',
      ),
      _MetricCardData(
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFFF6B6B),
        bgColor: const Color(0xFFFFEDED),
        value: streakDays.toString(),
        unit: isChinese ? '天' : 'days',
        title: isChinese ? '坚持天数' : 'Streak',
        subtitle: isChinese ? '连续整理' : 'Consistent organizing',
      ),
    ];

    final gradientHeight = 200.0; // Fixed gradient height

    // Calculate scroll progress based on how much the gradient has scrolled away
    final maxScroll = gradientHeight - 60; // When gradient title reaches header
    final scrollProgress = (_scrollOffset / maxScroll).clamp(0.0, 1.0);

    // Interpolate colors based on scroll
    final headerBgColor = Color.lerp(
      Colors.transparent,
      Colors.white,
      scrollProgress,
    )!;

    // Header title fades IN and moves to center as gradient scrolls away
    final headerTitleOpacity = scrollProgress;
    final headerTitleColor = Colors.black87;

    // Icon opacity (fades out)
    final iconOpacity = 1.0 - scrollProgress;

    // Title alignment in header (moves to center)
    final titleAlignment = Alignment.lerp(
      Alignment.centerLeft,
      Alignment.center,
      scrollProgress,
    )!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sticky header (transparent at first, becomes white)
          SliverAppBar(
            pinned: true,
            toolbarHeight: 60,
            backgroundColor: headerBgColor,
            elevation: scrollProgress > 0.8 ? 0.5 : 0,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            flexibleSpace: SafeArea(
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  children: [
                    // Header title (fades IN and moves to center)
                    if (headerTitleOpacity > 0.01)
                      Align(
                        alignment: titleAlignment,
                        child: Opacity(
                          opacity: headerTitleOpacity,
                          child: Text(
                            isChinese ? '洞察' : 'Insight',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: headerTitleColor,
                            ),
                          ),
                        ),
                      ),
                    // Profile icon (fades out)
                    if (iconOpacity > 0.01)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Opacity(
                          opacity: iconOpacity,
                          child: Center(
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
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Gradient section - SCROLLABLE CONTENT with title at top left
          SliverToBoxAdapter(
            child: Container(
              height: gradientHeight,
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
                  stops: [0.0, 0.25, 0.5, 0.7, 0.9, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
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
              ),
            ),
          ),
          // Content area - starts overlapping the gradient
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -80), // Pull card up into gradient area
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
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: metrics.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index < metrics.length - 1 ? 16 : 0,
                                ),
                                child: _buildMetricCard(context, metrics[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
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
    );
  }

  Widget _buildMetricCard(BuildContext context, _MetricCardData metric) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: metric.bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: metric.iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              metric.icon,
              color: metric.iconColor,
              size: 28,
            ),
          ),
          // Value and title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  if (metric.unit.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        metric.unit,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                metric.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metric.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
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
            isChinese ? '了解不同去向的放手占比。' : 'See how items found their next home.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EDF7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.pie_chart_outline_rounded,
                    color: Colors.black54,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isChinese ? '数据即将呈现' : 'Data coming soon',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.unit,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String unit;
  final String title;
  final String subtitle;
}
