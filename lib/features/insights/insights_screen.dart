import 'package:flutter/material.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/resell_item.dart';

class InsightsScreen extends StatefulWidget {
  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;
  final int streak;

  const InsightsScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.deepCleaningSessions,
    required this.streak,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  static const _headerPurple = Color(0xFF6B4E71);
  static const _metricAccent = Color(0xFF95E3C6);
  static const _chipColors = <Color>[
    Color(0xFF52C7B8),
    Color(0xFF9E7DB6),
    Color(0xFFF0AD57),
    Color(0xFFB0B5FF),
    Color(0xFFD18BBF),
  ];

  List<DeepCleaningSession> get _recentSessions {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    return widget.deepCleaningSessions
        .where(
          (session) =>
              !session.startTime.isBefore(monthStart) &&
              session.startTime.isBefore(nextMonthStart),
        )
        .toList();
  }

  Map<String, int> get _areaCounts {
    final counts = <String, int>{};
    for (final session in _recentSessions) {
      counts.update(session.area, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  int get _deepCleaningCount => _recentSessions.length;

  int get _joyDeclutterCount => widget.resellItems.length;

  int get _quickDeclutterCount => widget.declutteredItems.length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n, isChinese),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildMonthlyReportCard(theme, l10n, isChinese),
                    const SizedBox(height: 24),
                    _buildLetGoDetailsCard(theme, l10n, isChinese),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isChinese,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isChinese ? '洞察' : l10n.insights,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _headerPurple,
                ),
              ),
              const Spacer(),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFDDD0E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: _headerPurple),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                width: 26,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: index == 0 ? _headerPurple : const Color(0xFFD9D0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReportCard(
    ThemeData theme,
    AppLocalizations l10n,
    bool isChinese,
  ) {
    final metrics = <_MetricData>[
      _MetricData(
        icon: Icons.flash_on_rounded,
        label: isChinese ? '极速大扫除' : l10n.quickDeclutter,
        value: _quickDeclutterCount.toString(),
      ),
      _MetricData(
        icon: Icons.cleaning_services,
        label: isChinese ? '心动整理' : l10n.deepCleaning,
        value: _deepCleaningCount.toString(),
      ),
      _MetricData(
        icon: Icons.note_add_rounded,
        label: isChinese ? '心动小帮手' : l10n.joyDeclutter,
        value: _joyDeclutterCount.toString(),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '本月整理报告' : l10n.monthlyReport,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _headerPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '整理节奏与成果一览' : l10n.declutterRhythmOverview,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF8B8E98),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: metrics
                .map((metric) => _buildMetricPill(metric, theme))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE7DFEE), thickness: 1),
          const SizedBox(height: 16),
          Text(
            isChinese ? '整理类别' : 'Organized Areas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _headerPurple,
            ),
          ),
          const SizedBox(height: 8),
          if (_areaCounts.isEmpty)
            Text(
              isChinese
                  ? '本月还没有分类整理记录，先挑一件物品开始吧。'
                  : 'No categorized sessions yet this month. Start with one area!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8B8E98),
              ),
            )
          else
            Builder(
              builder: (_) {
                final entries = _areaCounts.entries.toList();
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
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE7DFEE), thickness: 1),
          const SizedBox(height: 16),
          Text(
            isChinese ? '整理前后对比' : l10n.beforeAfterComparison,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _headerPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _recentSessions.isEmpty
                ? (isChinese
                      ? '这个月还没有拍下整理前后的对比，下次记得记录成果。'
                      : 'No before/after snapshots yet this month. Remember to capture your results!')
                : (isChinese
                      ? '本月已记录${_recentSessions.length}次整理前后对比。'
                      : 'Recorded ${_recentSessions.length} before/after comparisons this month.'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF8B8E98),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(_MetricData metric, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _metricAccent.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(
            metric.icon,
            color: _metricAccent.withValues(alpha: 0.9),
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          metric.value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: _headerPurple,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 90,
          child: Text(
            metric.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A7D85),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
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

  Widget _buildLetGoDetailsCard(
    ThemeData theme,
    AppLocalizations l10n,
    bool isChinese,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '放手详情' : 'Letting Go Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _headerPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? '了解不同去向的放手占比' : 'See how items found their next home.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF8B8E98),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26),
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
                    color: _headerPurple,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isChinese ? '数据即将呈现' : 'Data coming soon',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B8E98),
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

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
