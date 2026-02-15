import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keepjoy_app/features/dashboard/widgets/declutter_results_distribution_card.dart';
import 'package:keepjoy_app/features/insights/deep_cleaning_analysis_card.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/widgets/glass_container.dart';
import 'package:keepjoy_app/theme/typography.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';
import 'package:keepjoy_app/models/memory.dart';

class YearlyReportsScreen extends StatefulWidget {
  const YearlyReportsScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.deepCleaningSessions,
    this.onDeleteSession,
    this.memories = const [],
  });

  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;
  final void Function(DeepCleaningSession session)? onDeleteSession;
  final List<Memory> memories;

  @override
  State<YearlyReportsScreen> createState() => _YearlyReportsScreenState();
}

enum _ReportRange { days7, days30, yearly }

class _YearlyReportsScreenState extends State<YearlyReportsScreen> {
  final ScrollController _scrollController = ScrollController();
  _ReportRange _selectedRange = _ReportRange.yearly;

  DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _rangeStart {
    final now = DateTime.now();
    switch (_selectedRange) {
      case _ReportRange.days7:
        return _todayStart.subtract(const Duration(days: 6));
      case _ReportRange.days30:
        return _todayStart.subtract(const Duration(days: 29));
      case _ReportRange.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime get _rangeEndExclusive {
    final now = DateTime.now();
    switch (_selectedRange) {
      case _ReportRange.days7:
      case _ReportRange.days30:
        return _todayStart.add(const Duration(days: 1));
      case _ReportRange.yearly:
        return DateTime(now.year + 1, 1, 1);
    }
  }

  String _rangeLabel(bool isChinese) {
    switch (_selectedRange) {
      case _ReportRange.days7:
        return isChinese ? '最近7天' : 'Last 7 Days';
      case _ReportRange.days30:
        return isChinese ? '最近30天' : 'Last 30 Days';
      case _ReportRange.yearly:
        return isChinese ? '每年' : 'Yearly';
    }
  }

  void _showRangeSelector(bool isChinese) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        Widget buildOption(_ReportRange range, String label) {
          final selected = _selectedRange == range;
          return ListTile(
            title: Text(
              label,
              style: ReportTextStyles.body.copyWith(
                color: ReportUI.primaryTextColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check_rounded, color: Color(0xFF0EA5E9))
                : null,
            onTap: () {
              setState(() => _selectedRange = range);
              Navigator.pop(sheetContext);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              buildOption(
                _ReportRange.days7,
                isChinese ? '最近7天' : 'Last 7 Days',
              ),
              buildOption(
                _ReportRange.days30,
                isChinese ? '最近30天' : 'Last 30 Days',
              ),
              buildOption(_ReportRange.yearly, isChinese ? '每年' : 'Yearly'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSessionDetail(
    BuildContext context,
    DeepCleaningSession session,
    bool isChinese,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (builderContext, scrollController) {
            final improvement =
                session.beforeMessinessIndex != null &&
                    session.afterMessinessIndex != null
                ? ((session.beforeMessinessIndex! -
                              session.afterMessinessIndex!) /
                          session.beforeMessinessIndex! *
                          100)
                      .toStringAsFixed(0)
                : null;

            final dateStr = DateFormat(
              isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy',
            ).format(session.startTime);

            final hasPhotos =
                (session.localBeforePhotoPath != null ||
                    session.remoteBeforePhotoPath != null) &&
                (session.localAfterPhotoPath != null ||
                    session.remoteAfterPhotoPath != null);

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.area,
                                    style: AppTypography.titleLarge.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateStr,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => Navigator.pop(sheetContext),
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          l10n.reportSessionData,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (hasPhotos) ...[
                          SizedBox(
                            height: 260,
                            child: PageView(
                              children: [
                                _buildPhotoCard(
                                  context: context,
                                  photoPath:
                                      session.localBeforePhotoPath ??
                                      session.remoteBeforePhotoPath!,
                                  label: l10n.dashboardBefore,
                                ),
                                _buildPhotoCard(
                                  context: context,
                                  photoPath:
                                      session.localAfterPhotoPath ??
                                      session.remoteAfterPhotoPath!,
                                  label: l10n.dashboardAfter,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (improvement != null)
                          _buildMetricRow(
                            label: l10n.reportImprovement,
                            value: '$improvement%',
                          ),
                        if (session.elapsedSeconds != null)
                          _buildMetricRow(
                            label: l10n.reportDuration,
                            value: '${session.elapsedSeconds! ~/ 60} min',
                          ),
                        if (session.itemsCount != null)
                          _buildMetricRow(
                            label: l10n.reportItemsCleaned,
                            value: session.itemsCount.toString(),
                          ),
                        if (session.focusIndex != null)
                          _buildMetricRow(
                            label: l10n.reportFocus,
                            value: '${session.focusIndex}/5',
                          ),
                        if (session.moodIndex != null)
                          _buildMetricRow(
                            label: l10n.reportJoy,
                            value: '${session.moodIndex}/5',
                          ),
                        if (session.beforeMessinessIndex != null &&
                            session.afterMessinessIndex != null) ...[
                          _buildMetricRow(
                            label: l10n.reportBeforeMessiness,
                            value: session.beforeMessinessIndex!
                                .toStringAsFixed(1),
                          ),
                          _buildMetricRow(
                            label: l10n.reportAfterTidiness,
                            value: session.afterMessinessIndex!.toStringAsFixed(
                              1,
                            ),
                          ),
                        ],
                        if (!hasPhotos &&
                            session.elapsedSeconds == null &&
                            session.itemsCount == null &&
                            session.focusIndex == null &&
                            session.moodIndex == null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.dashboardNoDetailedMetrics,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.dashboardNoDetailsSaved,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
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
          },
        );
      },
    );
  }

  Widget _buildMetricRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildReportSection(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildPhotoCard({
    required BuildContext context,
    required String photoPath,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(photoPath), fit: BoxFit.cover),
            Positioned(
              top: 16,
              left: 16,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                borderRadius: BorderRadius.circular(12),
                blur: 8,
                color: Colors.black.withValues(alpha: 0.4),
                child: Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallMetric(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  DateTime _toDateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  Map<DateTime, int> _buildDailyActivityCounts(
    List<DeclutterItem> items,
    List<DeepCleaningSession> sessions,
  ) {
    final dailyCounts = <DateTime, int>{};

    for (final item in items) {
      final date = _toDateOnly(item.createdAt);
      dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
    }

    for (final session in sessions) {
      final date = _toDateOnly(session.startTime);
      dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
    }

    return dailyCounts;
  }

  String _shortWeekdayLabel(DateTime day, bool isChinese) {
    if (isChinese) {
      const labels = ['一', '二', '三', '四', '五', '六', '日'];
      return labels[day.weekday - 1];
    }
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[day.weekday - 1];
  }

  List<_TrendPoint> _buildDeclutterTrendPoints({
    required bool isChinese,
    required DateTime rangeStart,
    required Map<DateTime, int> dailyActivityCounts,
  }) {
    if (_selectedRange == _ReportRange.yearly) {
      final year = rangeStart.year;
      return List.generate(12, (index) {
        final month = index + 1;
        int total = 0;
        dailyActivityCounts.forEach((date, count) {
          if (date.year == year && date.month == month) {
            total += count;
          }
        });
        return _TrendPoint(
          label: isChinese ? '$month月' : _getMonthAbbrev(month, false),
          count: total,
        );
      });
    }

    final pointCount = _selectedRange == _ReportRange.days7 ? 7 : 30;
    final start = _selectedRange == _ReportRange.days7
        ? _todayStart.subtract(const Duration(days: 6))
        : _todayStart.subtract(const Duration(days: 29));
    final points = <_TrendPoint>[];

    for (int i = 0; i < pointCount; i++) {
      final day = start.add(Duration(days: i));
      final dateOnly = _toDateOnly(day);
      points.add(
        _TrendPoint(
          label: _selectedRange == _ReportRange.days7
              ? _shortWeekdayLabel(day, isChinese)
              : '${day.month}/${day.day}',
          count: dailyActivityCounts[dateOnly] ?? 0,
        ),
      );
    }
    return points;
  }

  Widget _buildDeclutterTrendCard({
    required BuildContext context,
    required bool isChinese,
    required DateTime rangeStart,
    required Map<DateTime, int> dailyActivityCounts,
  }) {
    final points = _buildDeclutterTrendPoints(
      isChinese: isChinese,
      rangeStart: rangeStart,
      dailyActivityCounts: dailyActivityCounts,
    );
    final labels = points.map((point) => point.label).toList();
    final values = points.map((point) => point.count.toDouble()).toList();
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final activeCount = points.where((point) => point.count > 0).length;
    final _TrendPoint? peakPoint = points.isEmpty
        ? null
        : points.reduce((a, b) => a.count >= b.count ? a : b);
    final peakText = (peakPoint == null || peakPoint.count == 0)
        ? (isChinese ? '暂无高峰' : 'No peak')
        : (isChinese
              ? '高峰 ${peakPoint.label} (${peakPoint.count})'
              : 'Peak ${peakPoint.label} (${peakPoint.count})');

    return Container(
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
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
                      isChinese ? '整理趋势' : 'Declutter Trend',
                      style: ReportTextStyles.sectionHeader,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isChinese ? '查看整理变化。' : 'Activity over time.',
                      style: ReportTextStyles.sectionSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (total == 0)
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: ReportUI.statCardDecoration,
              child: Text(
                isChinese ? '暂无整理数据' : 'No declutter data',
                style: ReportTextStyles.body,
              ),
            )
          else
            SizedBox(
              height: 210,
              child: _buildDeclutterLineChart(labels: labels, values: values),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  isChinese
                      ? '$activeCount/${points.length} 活跃 · $peakText'
                      : '$activeCount/${points.length} active · $peakText',
                  style: ReportTextStyles.chartAxisLabel.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeclutterLineChart({
    required List<String> labels,
    required List<double> values,
  }) {
    final bool dense = labels.length > 12;
    final int mid = (labels.length / 2).floor();

    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _DeclutterTrendPainter(values: values),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(labels.first, style: ReportTextStyles.chartAxisLabel),
            const Spacer(),
            Text(labels[mid], style: ReportTextStyles.chartAxisLabel),
            const Spacer(),
            Text(labels.last, style: ReportTextStyles.chartAxisLabel),
          ],
        ),
        if (dense) ...[
          const SizedBox(height: 2),
          Text(
            '· · ·',
            style: ReportTextStyles.chartAxisLabel.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ],
    );
  }

  // ignore: unused_element
  void _showAreaDeepCleaningReport(BuildContext context, String area) {
    final l10n = AppLocalizations.of(context)!;
    final areaSessions =
        widget.deepCleaningSessions
            .where((session) => session.area == area)
            .toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (builderContext, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    area,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dashboardSessionTotal(areaSessions.length),
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      itemCount: areaSessions.length,
                      itemBuilder: (context, index) {
                        final session = areaSessions[index];
                        final dateStr = DateFormat.yMMMMd(
                          Localizations.localeOf(context).toString(),
                        ).format(session.startTime);

                        final improvement =
                            session.beforeMessinessIndex != null &&
                                session.afterMessinessIndex != null
                            ? ((session.beforeMessinessIndex! -
                                          session.afterMessinessIndex!) /
                                      session.beforeMessinessIndex! *
                                      100)
                                  .toStringAsFixed(0)
                            : null;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () =>
                                _showSessionDetail(context, session, true),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateStr,
                                        style: AppTypography.titleSmall
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                      ),
                                      if (improvement != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            '+$improvement%',
                                            style: AppTypography.labelMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildSmallMetric(
                                        context,
                                        Icons.timer_outlined,
                                        '${session.elapsedSeconds != null ? session.elapsedSeconds! ~/ 60 : 0}m',
                                      ),
                                      const SizedBox(width: 16),
                                      _buildSmallMetric(
                                        context,
                                        Icons.auto_awesome_outlined,
                                        '${session.itemsCount ?? 0} items',
                                      ),
                                      const SizedBox(width: 16),
                                      _buildSmallMetric(
                                        context,
                                        Icons.spa_outlined,
                                        '${session.focusIndex ?? 0}/5',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    final l10n = AppLocalizations.of(context)!;
    final headerSubtitle = isChinese ? '整理进度一览' : 'Declutter at a glance';
    final responsive = context.responsive;
    final horizontalPadding = responsive.horizontalPadding;
    final topPadding = responsive.safeAreaPadding.top;

    final rangeStart = _rangeStart;
    final rangeEndExclusive = _rangeEndExclusive;

    bool inRange(DateTime value, DateTime start, DateTime endExclusive) {
      return !value.isBefore(start) && value.isBefore(endExclusive);
    }

    final yearlyItems = widget.declutteredItems
        .where((item) => inRange(item.createdAt, rangeStart, rangeEndExclusive))
        .toList();

    final yearlySessions = widget.deepCleaningSessions
        .where(
          (session) =>
              inRange(session.startTime, rangeStart, rangeEndExclusive),
        )
        .toList();

    final dailyActivityCounts = _buildDailyActivityCounts(
      yearlyItems,
      yearlySessions,
    );
    final previousRangeDuration = rangeEndExclusive.difference(rangeStart);
    final previousRangeEnd = rangeStart;
    final previousRangeStart = previousRangeEnd.subtract(previousRangeDuration);

    int rangeItems(DateTime start, DateTime endExclusive) => widget
        .declutteredItems
        .where((item) => inRange(item.createdAt, start, endExclusive))
        .length;
    int rangeSessions(DateTime start, DateTime endExclusive) => widget
        .deepCleaningSessions
        .where((session) => inRange(session.startTime, start, endExclusive))
        .length;
    int rangeAreas(DateTime start, DateTime endExclusive) => widget
        .deepCleaningSessions
        .where((session) => inRange(session.startTime, start, endExclusive))
        .map((session) => session.area.trim())
        .where((area) => area.isNotEmpty)
        .toSet()
        .length;
    final actionsTrend = _percentChange(
      current:
          (rangeSessions(rangeStart, rangeEndExclusive) +
                  rangeItems(rangeStart, rangeEndExclusive))
              .toDouble(),
      previous:
          (rangeSessions(previousRangeStart, previousRangeEnd) +
                  rangeItems(previousRangeStart, previousRangeEnd))
              .toDouble(),
    );
    final itemsTrend = _percentChange(
      current: rangeItems(rangeStart, rangeEndExclusive).toDouble(),
      previous: rangeItems(previousRangeStart, previousRangeEnd).toDouble(),
    );
    final yearlyAreas = yearlySessions
        .map((session) => session.area.trim())
        .where((area) => area.isNotEmpty)
        .toSet()
        .length;
    final totalActions = yearlyItems.length + yearlySessions.length;
    final areasTrend = _percentChange(
      current: rangeAreas(rangeStart, rangeEndExclusive).toDouble(),
      previous: rangeAreas(previousRangeStart, previousRangeEnd).toDouble(),
    );

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
                // Background removed for consistency
                Container(
                  height: 800,
                  color: const Color(0xFFF5F5F7), // Standard background
                ),
                // Content on top
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: responsive.totalTwoLineHeaderHeight),

                      // Content
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          24,
                          horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 10.0;
                                final cardWidth =
                                    (constraints.maxWidth - spacing * 2) / 3;
                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: [
                                    SizedBox(
                                      width: cardWidth,
                                      child: _buildCompactTopMetricCard(
                                        title: isChinese ? '整理次数' : 'Sessions',
                                        value: totalActions.toString(),
                                        trend: actionsTrend,
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: _buildCompactTopMetricCard(
                                        title: l10n.reportItemsCleaned,
                                        value: yearlyItems.length.toString(),
                                        trend: itemsTrend,
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: _buildCompactTopMetricCard(
                                        title: l10n.dashboardAreasClearedLabel,
                                        value: yearlyAreas.toString(),
                                        trend: areasTrend,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            DeclutterResultsDistributionCard(
                              items: yearlyItems,
                              title: isChinese
                                  ? '整理成果分布'
                                  : 'Declutter Outcomes',
                              subtitle: isChinese
                                  ? '物品去向一览。'
                                  : 'Where items went.',
                              keptLabel: DeclutterStatus.keep.label(context),
                              resellLabel: DeclutterStatus.resell.label(
                                context,
                              ),
                              recycleLabel: DeclutterStatus.recycle.label(
                                context,
                              ),
                              donateLabel: DeclutterStatus.donate.label(
                                context,
                              ),
                              discardLabel: DeclutterStatus.discard.label(
                                context,
                              ),
                              totalItemsLabel: l10n.totalItemsDecluttered,
                              isChinese: isChinese,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isChinese ? '深度大扫除' : 'Clean Sweep',
                              style: ReportTextStyles.sectionHeader,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isChinese ? '看大扫除投入与变化。' : 'Effort and progress.',
                              style: ReportTextStyles.sectionSubtitle,
                            ),
                            const SizedBox(height: 12),
                            DeepCleaningAnalysisCard(
                              sessions: yearlySessions,
                              title: isChinese ? '数据概览' : 'Session Overview',
                              subtitle: isChinese
                                  ? '次数、物品、区域、时长。'
                                  : 'Sessions, items, areas, time.',
                              emptyStateMessage:
                                  l10n.reportNoDeepCleaningRecords,
                              onDeleteSession: widget.onDeleteSession,
                            ),
                            const SizedBox(height: 16),
                            _buildDeclutterTrendCard(
                              context: context,
                              isChinese: isChinese,
                              rangeStart: rangeStart,
                              dailyActivityCounts: dailyActivityCounts,
                            ),
                            const SizedBox(height: 16),
                            _buildJoyIndexCard(context, isChinese, yearlyItems),
                            const SizedBox(height: 24),

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
                final scrollProgress =
                    (scrollOffset / responsive.twoLineHeaderContentHeight)
                        .clamp(0.0, 1.0);
                final collapsedHeaderOpacity = scrollProgress >= 1.0
                    ? 1.0
                    : 0.0;
                return IgnorePointer(
                  ignoring: collapsedHeaderOpacity < 0.5,
                  child: Opacity(opacity: collapsedHeaderOpacity, child: child),
                );
              },
              child: Container(
                height: responsive.collapsedHeaderHeight,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding + 6,
                  horizontalPadding,
                  8,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F7),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l10n.dashboardYearlyReportsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: responsive.titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showRangeSelector(isChinese),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: ReportUI.statCardDecoration.copyWith(
                          color: Colors.white,
                          boxShadow: const [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _rangeLabel(isChinese),
                              style: ReportTextStyles.label.copyWith(
                                color: ReportUI.secondaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                final scrollProgress =
                    (scrollOffset / responsive.twoLineHeaderContentHeight)
                        .clamp(0.0, 1.0);
                final headerOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
                return Opacity(opacity: headerOpacity, child: child);
              },
              child: Container(
                height: responsive.totalTwoLineHeaderHeight,
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: topPadding + 12,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.dashboardYearlyReportsTitle,
                            style: TextStyle(
                              fontSize: responsive.largeTitleFontSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            headerSubtitle,
                            style: TextStyle(
                              fontSize: responsive.bodyFontSize,
                              color: const Color(0xFF6B7280),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showRangeSelector(isChinese),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: ReportUI.statCardDecoration.copyWith(
                          color: Colors.white,
                          boxShadow: const [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _rangeLabel(isChinese),
                              style: ReportTextStyles.label.copyWith(
                                color: ReportUI.secondaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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

  Widget _buildAchievementCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return SizedBox(
      height: 150,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: ReportUI.statCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: ReportTextStyles.statValueLarge),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ReportTextStyles.label,
            ),
          ],
        ),
      ),
    );
  }

  double _percentChange({required double current, required double previous}) {
    if (previous == 0) {
      return current > 0 ? 100 : 0;
    }
    return ((current - previous) / previous) * 100;
  }

  Widget _buildCompactTopMetricCard({
    required String title,
    required String value,
    required double trend,
  }) {
    final isNearZero = trend.abs() < 1;
    final isPositive = trend > 0;
    final trendText = isNearZero ? '0%' : '${trend.abs().toStringAsFixed(0)}%';
    final trendTextColor = isNearZero
        ? const Color(0xFF94A3B8)
        : (isPositive ? const Color(0xFF16A34A) : const Color(0xFFEF4444));
    final trendIcon = isNearZero
        ? Icons.trending_flat_rounded
        : (isPositive
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ReportUI.borderSideColor, width: 1),
        boxShadow: ReportUI.lightShadow,
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: SizedBox(
        height: 102,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ReportTextStyles.body.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ReportTextStyles.metricValueMedium.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(trendIcon, size: 18, color: trendTextColor),
                const SizedBox(width: 4),
                Text(
                  trendText,
                  style: ReportTextStyles.body.copyWith(
                    color: trendTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildDeclutterHintText({
    required bool isChinese,
    required int itemCount,
  }) {
    if (itemCount <= 0) {
      return isChinese
          ? '从一件小物开始，整理趋势会在这里慢慢清晰。'
          : 'Start with one item and your declutter trend will build here.';
    }
    final wardrobes = math.max(1, (itemCount / 40).ceil());
    return isChinese
        ? '已处理 $itemCount 件物品，约等于清空 $wardrobes 个标准衣柜。'
        : '$itemCount items processed, roughly equal to clearing $wardrobes wardrobes.';
  }

  String _getMonthAbbrev(int month, bool isChinese) {
    if (isChinese) {
      return '$month月';
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
    return months[month - 1];
  }

  Widget _buildJoyIndexCard(
    BuildContext context,
    bool isChinese,
    List<DeclutterItem> items,
  ) {
    final isYearlyRange = _selectedRange == _ReportRange.yearly;
    final labels = <String>[];
    final values = <double>[];

    if (isYearlyRange) {
      for (int month = 1; month <= 12; month++) {
        final count = items
            .where((item) => item.joyLevel != null && item.joyLevel! >= 6)
            .where((item) => item.createdAt.month == month)
            .length
            .toDouble();
        labels.add(_getMonthAbbrev(month, isChinese));
        values.add(count);
      }
    } else {
      if (_selectedRange == _ReportRange.days7) {
        final start = _todayStart.subtract(const Duration(days: 6));
        for (int i = 0; i < 7; i++) {
          final day = start.add(Duration(days: i));
          final dayEnd = day.add(const Duration(days: 1));
          final count = items
              .where((item) => item.joyLevel != null && item.joyLevel! >= 6)
              .where(
                (item) =>
                    !item.createdAt.isBefore(day) &&
                    item.createdAt.isBefore(dayEnd),
              )
              .length
              .toDouble();
          final dayLabel = '${day.month}/${day.day}';
          labels.add(dayLabel);
          values.add(count);
        }
      } else {
        final start = _todayStart.subtract(const Duration(days: 29));
        const bucketCount = 6;
        const bucketSizeDays = 5;
        for (int bucket = 0; bucket < bucketCount; bucket++) {
          final bucketStart = start.add(
            Duration(days: bucket * bucketSizeDays),
          );
          final bucketEnd = bucket == bucketCount - 1
              ? _todayStart.add(const Duration(days: 1))
              : bucketStart.add(const Duration(days: bucketSizeDays));
          final count = items
              .where((item) => item.joyLevel != null && item.joyLevel! >= 6)
              .where(
                (item) =>
                    !item.createdAt.isBefore(bucketStart) &&
                    item.createdAt.isBefore(bucketEnd),
              )
              .length
              .toDouble();
          labels.add('${bucketStart.month}/${bucketStart.day}');
          values.add(count);
        }
      }
    }

    final totalJoyCount = values.fold<double>(0, (sum, value) => sum + value);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
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
                      isChinese ? '心动指数趋势' : 'Joy Index Trend',
                      style: ReportTextStyles.sectionHeader,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isChinese ? '查看心动变化。' : 'Track joy over time.',
                      style: ReportTextStyles.sectionSubtitle,
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
                tooltip: isChinese ? '数据说明' : 'Data info',
                onPressed: () => _showJoyInfo(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (totalJoyCount == 0)
            Container(
              height: 210,
              alignment: Alignment.center,
              decoration: ReportUI.statCardDecoration,
              child: Text(
                isChinese ? '暂无心动数据' : 'No joy data yet',
                style: ReportTextStyles.body,
              ),
            )
          else
            SizedBox(
              height: 220,
              child: _buildJoyBarChart(labels: labels, values: values),
            ),
        ],
      ),
    );
  }

  Widget _buildJoyBarChart({
    required List<String> labels,
    required List<double> values,
  }) {
    var maxValue = 0.0;
    for (final v in values) {
      if (v > maxValue) maxValue = v;
    }
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final value = values[index];
        final ratio = (value / safeMax).clamp(0.0, 1.0);
        final barHeight = (ratio * 128).clamp(10.0, 128.0);
        final barColor = value <= 0
            ? const Color(0xFFE5E7EB)
            : Color.lerp(
                const Color(0xFFFBCFE8),
                const Color(0xFFEC4899),
                ratio,
              )!;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: ReportTextStyles.chartValueLabel,
                ),
                const SizedBox(height: 5),
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  style: ReportTextStyles.chartAxisLabel.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showJoyInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = l10n.localeName == 'zh';

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.reportJoy,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  isChinese ? '数据统计说明' : 'How it\'s measured',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoBox(
                  context,
                  isChinese
                      ? '心动量化了您在整理每一件物品时的情感联结。心动率越高，代表您的整理过程越具有正向情感和成就感。'
                      : 'Joy quantifies the emotional connection as you declutter each item. A higher joy rate indicates more positive energy and accomplishment in your journey.',
                ),
                const SizedBox(height: 16),
                _buildInfoBox(
                  context,
                  isChinese
                      ? '心动率 = 产生心动感的物品数 ÷ 所有记录心动状态的物品数。'
                      : 'Joy Rate = Count of Joyful items ÷ Total items with joy assessment.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBox(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: const Color(0xFF374151),
          height: 1.5,
        ),
      ),
    );
  }

  double _averageAreaImprovement(List<DeepCleaningSession> sessions) {
    double total = 0;
    int count = 0;
    for (final s in sessions) {
      if (s.beforeMessinessIndex != null &&
          s.afterMessinessIndex != null &&
          s.beforeMessinessIndex! > 0) {
        final improve =
            (s.beforeMessinessIndex! - s.afterMessinessIndex!) /
            s.beforeMessinessIndex! *
            100;
        total += improve;
        count++;
      }
    }
    if (count == 0) return 0;
    return total / count;
  }
}

class _TrendPoint {
  const _TrendPoint({required this.label, required this.count});

  final String label;
  final int count;
}

class _DeclutterTrendPainter extends CustomPainter {
  _DeclutterTrendPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.reduce(math.max);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final chartTop = 8.0;
    final chartBottom = size.height - 14.0;
    final chartHeight = chartBottom - chartTop;
    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0.0;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final y = chartTop + (chartHeight / 2) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePath = Path();
    final areaPath = Path();
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final ratio = (values[i] / safeMax).clamp(0.0, 1.0);
      final x = stepX * i;
      final y = chartBottom - chartHeight * ratio;
      final point = Offset(x, y);
      points.add(point);
      if (i == 0) {
        linePath.moveTo(x, y);
        areaPath.moveTo(x, chartBottom);
        areaPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }
    areaPath
      ..lineTo(points.last.dx, chartBottom)
      ..close();

    final fillPaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 3.5, Paint()..color = const Color(0xFF2563EB));
      canvas.drawCircle(point, 2.0, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _DeclutterTrendPainter oldDelegate) {
    if (identical(values, oldDelegate.values)) return false;
    if (values.length != oldDelegate.values.length) return true;
    for (int i = 0; i < values.length; i++) {
      if (values[i] != oldDelegate.values[i]) return true;
    }
    return false;
  }
}
