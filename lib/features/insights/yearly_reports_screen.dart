import 'dart:io';
import 'dart:ui' as ui;

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

class YearlyReportsScreen extends StatefulWidget {
  const YearlyReportsScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.deepCleaningSessions,
    this.onDeleteSession,
  });

  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;
  final void Function(DeepCleaningSession session)? onDeleteSession;

  @override
  State<YearlyReportsScreen> createState() => _YearlyReportsScreenState();
}

class _YearlyReportsScreenState extends State<YearlyReportsScreen> {
  bool _showJoyPercent = true; // true = Joy Rate, false = Joy Count
  final ScrollController _scrollController = ScrollController();

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
                color: Theme.of(context).colorScheme.surface,
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
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

  Widget _buildHeatmapCell(BuildContext context, DateTime date, int activity) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: _getHeatmapColor(context, activity),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getMonthAbbrev(
                date.month,
                AppLocalizations.of(context)!.localeName == 'zh',
              ),
              style: AppTypography.labelSmall.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
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
                color: Theme.of(context).colorScheme.surface,
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
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
    final responsive = context.responsive;
    final horizontalPadding = responsive.horizontalPadding;
    final headerHeight = responsive.totalTwoLineHeaderHeight + 12;
    final topPadding = responsive.safeAreaPadding.top;

    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final nextYearStart = DateTime(now.year + 1, 1, 1);
    final pageName = l10n.yearlyReportsTitle;

    // Calculate past 12 months activity (for heatmap)
    final past12MonthsActivity = <String, int>{};
    String? mostActiveMonth;
    int mostActiveCount = 0;
    int peakActivity = 0;

    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(monthDate.year, monthDate.month, 1);
      final monthEnd = monthDate.month == 12
          ? DateTime(monthDate.year + 1, 1, 1)
          : DateTime(monthDate.year, monthDate.month + 1, 1);

      final count =
          widget.declutteredItems
              .where(
                (item) =>
                    item.createdAt.isAfter(
                      monthStart.subtract(const Duration(days: 1)),
                    ) &&
                    item.createdAt.isBefore(monthEnd),
              )
              .length +
          widget.deepCleaningSessions
              .where(
                (session) =>
                    session.startTime.isAfter(
                      monthStart.subtract(const Duration(days: 1)),
                    ) &&
                    session.startTime.isBefore(monthEnd),
              )
              .length;

      final monthKey = '${monthDate.year}-${monthDate.month}';
      past12MonthsActivity[monthKey] = count;

      if (count > mostActiveCount) {
        mostActiveCount = count;
        mostActiveMonth = _getMonthName(monthDate.month, isChinese);
      }

      if (count > peakActivity) {
        peakActivity = count;
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int currentStreak = 0;
    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = '${monthDate.year}-${monthDate.month}';
      final count = past12MonthsActivity[monthKey] ?? 0;

      if (count > 0) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    // Calculate yearly stats
    final yearlyItems = widget.declutteredItems
        .where(
          (item) =>
              !item.createdAt.isBefore(yearStart) &&
              item.createdAt.isBefore(nextYearStart),
        )
        .toList();

    final yearlySessions = widget.deepCleaningSessions
        .where(
          (session) =>
              !session.startTime.isBefore(yearStart) &&
              session.startTime.isBefore(nextYearStart),
        )
        .toList();

    final yearlySoldItems = widget.resellItems
        .where(
          (item) =>
              item.soldPrice != null &&
              item.soldDate != null &&
              !item.soldDate!.isBefore(yearStart) &&
              item.soldDate!.isBefore(nextYearStart),
        )
        .toList();
    final yearlyResellValue = yearlySoldItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.soldPrice ?? 0.0),
    );
    final localeName = Localizations.localeOf(context).toString();
    final currencySymbol = isChinese ? '¥' : '\$';
    final currencyFormatter = NumberFormat.compactCurrency(
      locale: localeName,
      symbol: currencySymbol,
      decimalDigits: 0,
    );
    final yearlyResellValueDisplay = currencyFormatter.format(
      yearlyResellValue,
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
                // Gradient background that scrolls
                Container(
                  height: 800,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF89CFF0), // Blue
                        Color(0xFFE6F4F9), // Light blue
                        Color(0xFFF5F5F7),
                      ],
                      stops: [0.0, 0.25, 0.45],
                    ),
                  ),
                ),
                // Content on top
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      // Top spacing + title
                      SizedBox(
                        height: headerHeight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: topPadding + 28,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.dashboardYearlyReportsTitle,
                                      style: ReportTextStyles.screenTitle,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.dashboardYearlyReportsSubtitle,
                                      style: ReportTextStyles.screenSubtitle,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

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
                            // Year-to-date metrics summary
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildAchievementCard(
                                    context: context,
                                    icon: Icons.auto_awesome_outlined,
                                    iconColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    value: yearlySessions.length.toString(),
                                    label: l10n.dashboardSessionsLabel,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildAchievementCard(
                                    context: context,
                                    icon: Icons.inventory_2_outlined,
                                    iconColor: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    value: yearlyItems.length.toString(),
                                    label: l10n.reportItemsCleaned,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildAchievementCard(
                                    context: context,
                                    icon: Icons.payments_outlined,
                                    iconColor: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                    value: yearlyResellValueDisplay,
                                    label: l10n.reportTotalRevenue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Declutter Heatmap (Past 12 months)
                            Container(
                              padding: const EdgeInsets.all(
                                ReportUI.contentPadding,
                              ),
                              decoration: ReportUI.cardDecoration,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.reportMemoryHeatmap,
                                    style: ReportTextStyles.sectionHeader,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.reportActivityThisYear,
                                    style: ReportTextStyles.sectionSubtitle,
                                  ),
                                  const SizedBox(height: 32),

                                  // Heatmap Grid
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
                                              '${monthDate.year}-${monthDate.month}';
                                          final activity =
                                              past12MonthsActivity[monthKey] ??
                                              0;
                                          return _buildHeatmapCell(
                                            context,
                                            monthDate,
                                            activity,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 8),
                                      // Second row
                                      Row(
                                        children: List.generate(6, (index) {
                                          final monthDate = DateTime(
                                            now.year,
                                            now.month - (5 - index),
                                            1,
                                          );
                                          final monthKey =
                                              '${monthDate.year}-${monthDate.month}';
                                          final activity =
                                              past12MonthsActivity[monthKey] ??
                                              0;
                                          return _buildHeatmapCell(
                                            context,
                                            monthDate,
                                            activity,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Color legend
                                  Row(
                                    children: [
                                      Text(
                                        l10n.reportLess,
                                          style: ReportTextStyles.label,
                                      ),
                                      const SizedBox(width: 8),
                                      ...List.generate(5, (index) {
                                        return Container(
                                          width: 16,
                                          height: 16,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getHeatmapColor(
                                              context,
                                              (index * 3) + 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.reportMore,
                                          style: ReportTextStyles.label,
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () =>
                                            _showHeatmapLegendDialog(context),
                                        icon: Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Statistics - All in one row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildHeatmapStatCard(
                                          context: context,
                                          title: l10n.reportMostActiveMonth,
                                          value: mostActiveMonth ?? 'N/A',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildHeatmapStatCard(
                                          context: context,
                                          title: l10n.reportLongestStreak,
                                          value: isChinese
                                              ? '$longestStreak 个月'
                                              : '$longestStreak months',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildHeatmapStatCard(
                                          context: context,
                                          title: l10n.reportTotalItems,
                                          value: '$peakActivity ${l10n.items}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            DeclutterResultsDistributionCard(
                              items: yearlyItems,
                              title: l10n.reportYearToDateOutcomes,
                              subtitle: l10n
                                  .reportYearToDateOutcomes, // Using title as subtitle for now if specific one isn't distinct enough
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
                            const SizedBox(height: 20),

                            // Clean Sweep Analysis (Yearly)
                            DeepCleaningAnalysisCard(
                              sessions: yearlySessions,
                              title: l10n.reportCleanSweepTitle,
                              emptyStateMessage:
                                  l10n.reportNoDeepCleaningRecords,
                              onDeleteSession: widget.onDeleteSession,
                            ),
                            const SizedBox(height: 20),

                            // Joy Index Trend
                            _buildJoyIndexCard(context, isChinese),
                            const SizedBox(height: 20),

                            // Your Joyful Journey (Yearly Insights)
                            if (_hasYearlyActivity())
                              _buildYearlyInsightsCard(isChinese),
                            if (_hasYearlyActivity())
                              const SizedBox(height: 20),
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

          // Real header that appears when scrolling is complete
          // Real header - only this rebuilds on scroll
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
                final scrollProgress = (scrollOffset / headerHeight).clamp(
                  0.0,
                  1.0,
                );
                final realHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;
                return IgnorePointer(
                  ignoring: realHeaderOpacity < 0.5,
                  child: Opacity(opacity: realHeaderOpacity, child: child),
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
                          style: AppTypography.titleMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ReportUI.borderSideColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: ReportTextStyles.statValueLarge,
              ),
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

  Widget _buildHeatmapStatCard({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: ReportUI.statCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ReportTextStyles.label,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: ReportTextStyles.statValueSmall,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(BuildContext context, int count) {
    return ReportUI.getHeatmapColor(count);
  }

  void _showHeatmapLegendDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = l10n.localeName.toLowerCase().startsWith('zh');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                      l10n.reportActivityLevels,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLegendItem(
                  context,
                  isChinese ? '无活动 (0)' : 'None (0)',
                  0,
                ),
                _buildLegendItem(context, '1-3', 2),
                _buildLegendItem(context, '4-6', 5),
                _buildLegendItem(context, '7-9', 8),
                _buildLegendItem(context, '10+', 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getHeatmapColor(context, count),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
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

  String _getMonthName(int month, bool isChinese) {
    if (isChinese) {
      return '$month月';
    }
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildJoyIndexCard(BuildContext context, bool isChinese) {
    final l10n = AppLocalizations.of(context)!;
    // Calculate joy index trend year-to-date (January to current month)
    final now = DateTime.now();

    // Initialize all 12 months (1-12)
    final monthlyJoyData = <int, List<int>>{}; // month -> list of joy levels
    final monthlyJoyCount = <int, int>{}; // month -> count of joy clicks
    final monthlyTotalCount =
        <int, int>{}; // month -> items answered joy question

    for (int month = 1; month <= 12; month++) {
      monthlyJoyData[month] = [];
      monthlyJoyCount[month] = 0;
      monthlyTotalCount[month] = 0;
    }

    for (final item in widget.declutteredItems) {
      // Only include items from current year AND only quick declutter items that have a joy answer
      if (item.createdAt.year == now.year && item.joyLevel != null) {
        final month = item.createdAt.month; // 1-12

        monthlyTotalCount[month] = (monthlyTotalCount[month] ?? 0) + 1;

        if (item.joyLevel! >= 6) {
          monthlyJoyData.putIfAbsent(month, () => []).add(item.joyLevel!);
          monthlyJoyCount[month] = (monthlyJoyCount[month] ?? 0) + 1;
        }
      }
    }

    // Calculate monthly joy rate for all 12 months
    final monthlyJoyPercent = <int, double>{};
    for (int month = 1; month <= 12; month++) {
      final total = monthlyTotalCount[month] ?? 0;
      final joyCount = monthlyJoyCount[month] ?? 0;
      monthlyJoyPercent[month] = total > 0 ? (joyCount / total * 100) : 0.0;
    }

    // Calculate average joy rate (excluding months with no data)
    final monthsWithData = monthlyJoyPercent.values
        .where((v) => v > 0)
        .toList();
    final avgJoyPercent = monthsWithData.isEmpty
        ? 0.0
        : monthsWithData.reduce((a, b) => a + b) / monthsWithData.length;

    // Calculate total joy count
    final itemsWithJoy = widget.declutteredItems
        .where((item) => item.createdAt.year == now.year)
        .where((item) => item.joyLevel != null && item.joyLevel! >= 6)
        .toList();
    final totalJoyCount = itemsWithJoy.length;

    // Determine trend (compare recent 3 months vs older 3 months)
    String trendText;
    String trendIcon;
    Color trendColor;

    if (now.month >= 6) {
      // Average of most recent 3 months
      final month1 = monthlyJoyPercent[now.month] ?? 0;
      final month2 = monthlyJoyPercent[now.month - 1] ?? 0;
      final month3 = monthlyJoyPercent[now.month - 2] ?? 0;
      final recentAvg = (month1 + month2 + month3) / 3;

      // Average of first 3 months (January-March)
      final olderAvg =
          (monthlyJoyPercent[1]! +
              monthlyJoyPercent[2]! +
              monthlyJoyPercent[3]!) /
          3;

      if (recentAvg > olderAvg) {
        trendText = isChinese ? '上升' : 'Rising';
        trendIcon = '↑';
        trendColor = const Color(0xFF4CAF50);
      } else if (recentAvg < olderAvg) {
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
      padding: const EdgeInsets.all(ReportUI.contentPadding),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with inline info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '心动指数趋势' : 'Joy Index Trend',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isChinese ? '年度心动轨迹概览' : 'Annual joy trajectory overview',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
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
          const SizedBox(height: 20),

          // Metric dropdown for Joy Rate vs Joy Count
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  isChinese ? '指标' : 'Metric',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<bool>(
                      value: _showJoyPercent,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6B7280),
                      ),
                      dropdownColor: Colors.white,
                      focusColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _showJoyPercent = value;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem<bool>(
                          value: true,
                          child: Text(
                            isChinese ? '心动率' : 'Joy Rate',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                          ),
                        ),
                        DropdownMenuItem<bool>(
                          value: false,
                          child: Text(
                            isChinese ? '心动次数' : 'Joy Count',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
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

          const SizedBox(height: 20),

          // Chart (always show with 12 months)
          SizedBox(
            height: 250,
            child: CustomPaint(
              size: const Size(double.infinity, 250),
              painter: _JoyTrendChartPainter(
                monthlyData: _showJoyPercent
                    ? monthlyJoyPercent
                    : monthlyJoyCount.map((k, v) => MapEntry(k, v.toDouble())),
                maxMonths: 12,
                isPercent: _showJoyPercent,
                colorScheme: Theme.of(context).colorScheme,
                l10n: l10n,
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
                label: l10n.reportAverageJoyRate,
                value: '${avgJoyPercent.toStringAsFixed(0)}%',
                color: Theme.of(context).colorScheme.primary,
              ),
              _buildStatItem(
                context,
                label: l10n.reportTotalJoyCount,
                value: totalJoyCount.toString(),
                color: Theme.of(context).colorScheme.secondary,
              ),
              _buildStatItem(
                context,
                label: l10n.reportTrendAnalysis,
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
          style: AppTypography.labelSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showJoyInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = l10n.localeName == 'zh';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                        color: Theme.of(context).colorScheme.onSurface,
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
                    color: Theme.of(context).colorScheme.onSurface,
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
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  bool _hasYearlyActivity() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);

    final hasDecluttered = widget.declutteredItems.any(
      (item) =>
          item.createdAt.isAfter(yearStart.subtract(const Duration(days: 1))),
    );

    final hasResold = widget.resellItems.any(
      (item) =>
          item.status == ResellStatus.sold &&
          item.soldDate != null &&
          item.soldDate!.isAfter(yearStart.subtract(const Duration(days: 1))),
    );

    final hasSessions = widget.deepCleaningSessions.any(
      (session) => session.startTime.isAfter(
        yearStart.subtract(const Duration(days: 1)),
      ),
    );

    return hasDecluttered || hasResold || hasSessions;
  }

  Widget _buildYearlyInsightsCard(bool isChinese) {
    // Calculate YEARLY metrics
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);

    // Count decluttered items this year
    final declutteredThisYear = widget.declutteredItems
        .where(
          (item) => item.createdAt.isAfter(
            yearStart.subtract(const Duration(days: 1)),
          ),
        )
        .length;

    // Count resold items this year
    final resoldThisYear = widget.resellItems
        .where(
          (item) =>
              item.status == ResellStatus.sold &&
              item.soldDate != null &&
              item.soldDate!.isAfter(
                yearStart.subtract(const Duration(days: 1)),
              ),
        )
        .length;

    // Count deep cleaning sessions this year
    final sessionsThisYear = widget.deepCleaningSessions
        .where(
          (session) => session.startTime.isAfter(
            yearStart.subtract(const Duration(days: 1)),
          ),
        )
        .length;

    // Calculate total time spent cleaning (in hours)
    final totalMinutes =
        widget.deepCleaningSessions
            .where(
              (session) => session.startTime.isAfter(
                yearStart.subtract(const Duration(days: 1)),
              ),
            )
            .fold(0, (sum, session) => sum + (session.elapsedSeconds ?? 0)) ~/
        60;

    // Build list of insights to display
    final insights = <Widget>[];

    // Add decluttered items insight if there are any
    if (declutteredThisYear > 0) {
      final spaceCubicFeet = (declutteredThisYear * 0.5).toStringAsFixed(1);
      insights.add(
        _buildInsightRow(
          icon: Icons.inventory_2_rounded,
          iconColor: const Color(0xFF5ECFB8),
          text: isChinese
              ? '你为 $declutteredThisYear 件物品找到了新的归宿，为生活腾出了约 $spaceCubicFeet 立方英尺的空间，感受到更多呼吸的自由！'
              : 'You found new homes for $declutteredThisYear items, creating ~$spaceCubicFeet cubic feet of breathing room in your space!',
        ),
      );
    }

    // Add resold items insight if there are any
    if (resoldThisYear > 0) {
      final co2SavedKg = (resoldThisYear * 5).toStringAsFixed(0);
      insights.add(
        _buildInsightRow(
          icon: Icons.eco_rounded,
          iconColor: const Color(0xFF10B981),
          text: isChinese
              ? '通过转售 $resoldThisYear 件物品，你让它们继续带来快乐，同时减少了约 $co2SavedKg kg 的碳排放。真是美好的循环！'
              : 'By reselling $resoldThisYear items, you extended their joy to others while saving ~$co2SavedKg kg of CO₂. What a beautiful cycle!',
        ),
      );
    }

    // Add cleaning sessions insight if there are any
    if (sessionsThisYear > 0) {
      final totalHours = (totalMinutes / 60).toStringAsFixed(1);
      insights.add(
        _buildInsightRow(
          icon: Icons.cleaning_services_rounded,
          iconColor: const Color(0xFFB794F6),
          text: isChinese
              ? '完成了 $sessionsThisYear 次大扫除，投入了 $totalHours 小时的时间。每一次整理都是对自己的温柔对待。'
              : 'You completed $sessionsThisYear tidying sessions, investing $totalHours hours in caring for your space and yourself.',
        ),
      );
    }

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

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
            isChinese ? '你的美好改变' : 'Your Joyful Journey',
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? '今年的精彩足迹' : 'Your highlights this year',
            style: const TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: insight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoyTrendChartPainter extends CustomPainter {
  final Map<int, double> monthlyData;
  final int maxMonths;
  final bool isPercent;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  _JoyTrendChartPainter({
    required this.monthlyData,
    required this.maxMonths,
    required this.isPercent,
    required this.colorScheme,
    required this.l10n,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (monthlyData.isEmpty) return;

    final primaryColor = colorScheme.primary;
    final onSurfaceVariantColor = colorScheme.onSurfaceVariant;
    final outlineColor = colorScheme.outlineVariant;

    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    const leftPadding = 40.0;
    const rightPadding = 20.0;
    const topPadding = 20.0;
    const bottomPadding = 40.0;
    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    double maxValue;
    if (isPercent) {
      maxValue = 100.0;
    } else {
      final maxRaw = monthlyData.values.isEmpty
          ? 0
          : monthlyData.values.reduce((a, b) => a > b ? a : b);
      maxValue = maxRaw == 0 ? 5 : maxRaw.toDouble();
      maxValue = (maxValue * 1.25).clamp(5.0, double.infinity);
    }

    // Draw grid lines and labels
    for (int i = 0; i <= 5; i++) {
      final y = topPadding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final value = maxValue * (5 - i) / 5;
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(0),
        style: AppTypography.labelSmall.copyWith(
          color: onSurfaceVariantColor,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width - 12,
          y - textPainter.height / 2,
        ),
      );
    }

    final points = <Offset>[];
    for (int month = 1; month <= 12; month++) {
      final value = monthlyData[month] ?? 0.0;
      final x = leftPadding + (chartWidth * (month - 1) / 11);
      final normalizedValue = value / maxValue;
      final y = topPadding + (chartHeight * (1 - normalizedValue));
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Draw fill
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height - bottomPadding);
    fillPath.lineTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      fillPath.cubicTo(
        current.dx + (next.dx - current.dx) / 3,
        current.dy,
        current.dx + 2 * (next.dx - current.dx) / 3,
        next.dy,
        next.dx,
        next.dy,
      );
    }
    fillPath.lineTo(points.last.dx, size.height - bottomPadding);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      linePath.cubicTo(
        current.dx + (next.dx - current.dx) / 3,
        current.dy,
        current.dx + 2 * (next.dx - current.dx) / 3,
        next.dy,
        next.dx,
        next.dy,
      );
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots and labels
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Only draw dots for every 3 months or if it has non-zero value to keep it clean
      if (i % 2 == 0 || monthlyData[i + 1] != 0) {
        canvas.drawCircle(point, 5, dotPaint);
        canvas.drawCircle(point, 3, Paint()..color = colorScheme.surface);
      }

      final monthName = _getMonthAbbrev(i + 1, l10n.localeName == 'zh');
      textPainter.text = TextSpan(
        text: monthName,
        style: AppTypography.labelSmall.copyWith(
          color: onSurfaceVariantColor,
          fontSize: 9,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          point.dx - textPainter.width / 2,
          size.height - bottomPadding + 10,
        ),
      );
    }
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
