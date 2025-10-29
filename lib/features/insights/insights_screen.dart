import 'package:flutter/material.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/resell_item.dart';

class InsightsScreen extends StatelessWidget {
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

  static const _chipColors = <Color>[
    Color(0xFF52C7B8),
    Color(0xFF9E7DB6),
    Color(0xFFF0AD57),
    Color(0xFFB0B5FF),
    Color(0xFFD18BBF),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final sessionsThisMonth = deepCleaningSessions
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
    final itemsWithJoy = declutteredItems.where((item) => item.joyLevel != null).toList();
    final avgJoyIndex = itemsWithJoy.isEmpty
        ? 0.0
        : itemsWithJoy.map((item) => item.joyLevel!).reduce((a, b) => a + b) / itemsWithJoy.length;

    // Calculate New Life Value (total sold price from resell items)
    final soldItems = resellItems.where((item) => item.soldPrice != null);
    final totalValue = soldItems.isEmpty
        ? 0.0
        : soldItems.map((item) => item.soldPrice!).reduce((a, b) => a + b);

    // Calculate average focus index from sessions
    final sessionsWithFocus = sessionsThisMonth.where((s) => s.focusIndex != null);
    final avgFocusIndex = sessionsWithFocus.isEmpty
        ? 0.0
        : sessionsWithFocus.map((s) => s.focusIndex!).reduce((a, b) => a + b) / sessionsWithFocus.length;

    // Calculate streak
    final streakDays = streak;

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
        value: declutteredItems.length.toString(),
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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B4E71), // Purple at top
              Color(0xFF95E3C6), // Mint green in middle
              Color(0xFFF8F8F8), // Fade to very light at bottom
            ],
            stops: [0.0, 0.4, 1.0], // Purple 0%, Mint 40%, Light 100%
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildGradientHeader(context, l10n, isChinese),
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          isChinese ? '本月成就' : 'Monthly Achievements',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          isChinese
                              ? '共处理 ${declutteredItems.length} 件物品，释放空间'
                              : 'Processed ${declutteredItems.length} items',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Horizontal scrollable metric cards
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isChinese,
  ) {
    return Container(
      height: 220,
      width: double.infinity,
      // Remove background gradient - use the Scaffold's gradient instead
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '心动报告' : 'Insights Summary',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isChinese ? '固定摘要' : 'Pinned overview',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isChinese ? '本月' : 'This month',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  '${DateTime.now().month}/${DateTime.now().day}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
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
