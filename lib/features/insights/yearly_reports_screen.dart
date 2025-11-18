import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keepjoy_app/features/dashboard/widgets/cleaning_area_legend.dart';
import 'package:keepjoy_app/features/dashboard/widgets/declutter_results_distribution_card.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/features/insights/deep_cleaning_analysis_card.dart';
import 'package:keepjoy_app/widgets/auto_scale_text.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';

class YearlyReportsScreen extends StatefulWidget {
  const YearlyReportsScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.deepCleaningSessions,
  });

  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;

  @override
  State<YearlyReportsScreen> createState() => _YearlyReportsScreenState();
}

class _YearlyReportsScreenState extends State<YearlyReportsScreen> {
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

  void _showSessionDetail(
    BuildContext context,
    DeepCleaningSession session,
    bool isChinese,
  ) {
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
                session.beforePhotoPath != null &&
                session.afterPhotoPath != null;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isChinese ? '整理数据' : 'Session Data',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (hasPhotos) ...[
                          Container(
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[200],
                            ),
                            child: PageView(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(session.beforePhotoPath!),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isChinese ? '整理前' : 'Before',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(session.afterPhotoPath!),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isChinese ? '整理后' : 'After',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (improvement != null)
                          _buildMetricRow(
                            label: isChinese ? '整理改善' : 'Improvement',
                            value: '$improvement%',
                          ),
                        if (session.elapsedSeconds != null)
                          _buildMetricRow(
                            label: isChinese ? '整理时长' : 'Duration',
                            value: '${session.elapsedSeconds! ~/ 60} min',
                          ),
                        if (session.itemsCount != null)
                          _buildMetricRow(
                            label: isChinese ? '清理物品' : 'Items Cleaned',
                            value: session.itemsCount.toString(),
                          ),
                        if (session.focusIndex != null)
                          _buildMetricRow(
                            label: isChinese ? '专注度' : 'Focus',
                            value: '${session.focusIndex}/5',
                          ),
                        if (session.moodIndex != null)
                          _buildMetricRow(
                            label: isChinese ? '愉悦度' : 'Joy',
                            value: '${session.moodIndex}/5',
                          ),
                        if (session.beforeMessinessIndex != null &&
                            session.afterMessinessIndex != null) ...[
                          _buildMetricRow(
                            label: isChinese ? '整理前凌乱度' : 'Before Messiness',
                            value: session.beforeMessinessIndex!
                                .toStringAsFixed(1),
                          ),
                          _buildMetricRow(
                            label: isChinese ? '整理后整洁度' : 'After Tidiness',
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
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isChinese ? '未记录详细数据' : 'No Detailed Metrics',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isChinese
                                      ? '这次整理只保存了照片记录\n下次整理时可以记录更多数据'
                                      : 'This session only saved photos\nNext time you can record more details',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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

  void _showAreaDeepCleaningReport(
    BuildContext context,
    String area,
    bool isChinese,
  ) {
    final areaSessions =
        widget.deepCleaningSessions
            .where((session) => session.area == area)
            .toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          expand: false,
          builder: (builderContext, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$area ${isChinese ? '整理记录' : 'Cleaning History'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${areaSessions.length} ${isChinese ? '次整理' : 'sessions'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: areaSessions.length,
                      itemBuilder: (context, index) {
                        final session = areaSessions[index];
                        final dateStr = DateFormat(
                          isChinese ? 'yyyy年M月d日' : 'MMM d, yyyy',
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

                        return GestureDetector(
                          onTap: () {
                            _showSessionDetail(context, session, isChinese);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EA),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
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
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    if (improvement != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          isChinese
                                              ? '改善 $improvement%'
                                              : '$improvement% better',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (session.focusIndex != null) ...[
                                      Icon(
                                        Icons.spa_rounded,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${isChinese ? '专注度' : 'Focus'}: ${session.focusIndex}/5',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    if (session.moodIndex != null) ...[
                                      Icon(
                                        Icons.sentiment_satisfied_rounded,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${isChinese ? '愉悦度' : 'Joy'}: ${session.moodIndex}/5',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (session.itemsCount != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${isChinese ? '清理物品' : 'Items cleaned'}: ${session.itemsCount}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
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

    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final nextYearStart = DateTime(now.year + 1, 1, 1);
    final topPadding = MediaQuery.of(context).padding.top;
    final pageName = isChinese ? '年度报告' : 'Yearly Reports';

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

    final maxActivityPast12 = past12MonthsActivity.values.isEmpty
        ? 1
        : past12MonthsActivity.values.reduce((a, b) => a > b ? a : b);

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

    // Disposal method counts
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
                        Color(0xFF89CFF0), // Blue
                        Color(0xFFE6F4F9), // Light blue
                        Color(0xFFF5F5F7),
                      ],
                      stops: [0.0, 0.15, 0.33],
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

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                // Year-to-date metrics summary
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildAchievementCard(
                                        icon: Icons.cleaning_services_rounded,
                                        iconColor: const Color(0xFFB794F6),
                                        value: yearlySessions.length.toString(),
                                        label: isChinese
                                            ? '深度整理'
                                            : 'Deep Cleaning',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildAchievementCard(
                                        icon: Icons.inventory_2_rounded,
                                        iconColor: const Color(0xFF5ECFB8),
                                        value: yearlyItems.length.toString(),
                                        label: isChinese
                                            ? '已整理物品'
                                            : 'Decluttered Items',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildAchievementCard(
                                        icon: Icons.attach_money_rounded,
                                        iconColor: const Color(0xFFFFD93D),
                                        value: yearlyResellValueDisplay,
                                        label: isChinese
                                            ? '转售收入'
                                            : 'Resell Value',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Declutter Heatmap (Past 12 months)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isChinese
                                            ? '整理热力图'
                                            : 'Declutter Heatmap',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF111827),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isChinese
                                            ? '过去12个月的活动'
                                            : 'Activity in past 12 months',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
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
                                                  '${monthDate.year}-${monthDate.month}';
                                              final activity =
                                                  past12MonthsActivity[monthKey] ??
                                                  0;

                                              return Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 48,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              _getHeatmapColor(
                                                                activity,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        _getMonthAbbrev(
                                                          monthDate.month,
                                                          isChinese,
                                                        ),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xFF6B7280,
                                                                  ),
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
                                                  '${monthDate.year}-${monthDate.month}';
                                              final activity =
                                                  past12MonthsActivity[monthKey] ??
                                                  0;

                                              return Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 48,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              _getHeatmapColor(
                                                                activity,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        _getMonthAbbrev(
                                                          monthDate.month,
                                                          isChinese,
                                                        ),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xFF6B7280,
                                                                  ),
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: const Color(
                                                      0xFF9CA3AF,
                                                    ),
                                                    fontSize: 12,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            ...List.generate(5, (index) {
                                              return Container(
                                                width: 16,
                                                height: 16,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getHeatmapColor(
                                                    (index * 3) + 1, // Demo colors: 1, 4, 7, 10, 13
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              );
                                            }),
                                            const SizedBox(width: 8),
                                            Text(
                                              isChinese ? '较多' : 'More',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: const Color(
                                                      0xFF9CA3AF,
                                                    ),
                                                    fontSize: 12,
                                                  ),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () => _showHeatmapLegendDialog(context, isChinese),
                                              child: const Icon(
                                                Icons.info_outline,
                                                size: 18,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Statistics - All in one row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                minHeight: 96,
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF9FAFB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isChinese
                                                        ? '最活跃'
                                                        : 'Most Active',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: const Color(
                                                            0xFF6B7280,
                                                          ),
                                                          fontSize: 11,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    mostActiveMonth ?? 'N/A',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color(
                                                            0xFF111827,
                                                          ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                minHeight: 96,
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF9FAFB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isChinese
                                                        ? '最长连续'
                                                        : 'Longest Streak',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: const Color(
                                                            0xFF6B7280,
                                                          ),
                                                          fontSize: 11,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    isChinese
                                                        ? '$longestStreak 个月'
                                                        : '$longestStreak months',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color(
                                                            0xFF111827,
                                                          ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                minHeight: 96,
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF9FAFB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isChinese
                                                        ? '峰值活动'
                                                        : 'Peak Activity',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: const Color(
                                                            0xFF6B7280,
                                                          ),
                                                          fontSize: 11,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    isChinese
                                                        ? '$peakActivity 项'
                                                        : '$peakActivity items',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color(
                                                            0xFF111827,
                                                          ),
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
                                ),
                                const SizedBox(height: 20),

                                DeclutterResultsDistributionCard(
                                  items: yearlyItems,
                                  title: isChinese
                                      ? '整理结果分布'
                                      : 'Declutter Results Distribution',
                                  subtitle: isChinese
                                      ? '年初至今的整理结果'
                                      : 'Year-to-date declutter results',
                                  keptLabel: DeclutterStatus.keep.label(
                                    context,
                                  ),
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

                                // Deep Cleaning Analysis (Yearly)
                                DeepCleaningAnalysisCard(
                                  sessions: yearlySessions,
                                  title: isChinese
                                      ? '深度整理分析'
                                      : 'Deep Cleaning Analysis',
                                  emptyStateMessage: isChinese
                                      ? '今年还没有深度整理记录，开始一次专注的整理吧。'
                                      : 'No deep cleaning records yet this year. Start your first focused session.',
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

  Widget _buildAchievementCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          AutoScaleText(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 4),
          AutoScaleText(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(int count) {
    // Use actual count instead of relative intensity for consistent colors
    if (count == 0) {
      return const Color(0xFFE5E7EB); // Gray for no activity
    } else if (count <= 3) {
      return const Color(0xFFD4E9F7); // Very light blue
    } else if (count <= 6) {
      return const Color(0xFFA8D8F0); // Light blue
    } else if (count <= 9) {
      return const Color(0xFF7BC8E8); // Medium blue
    } else if (count <= 12) {
      return const Color(0xFF4FB8E0); // Dark blue
    } else {
      return const Color(0xFF23A7D8); // Darkest blue
    }
  }

  Color _getHeatmapColorByCount(int count) {
    // Same logic as _getHeatmapColor for legend consistency
    if (count == 0) {
      return const Color(0xFFE5E7EB); // Gray
    } else if (count <= 3) {
      return const Color(0xFFD4E9F7); // Very light blue
    } else if (count <= 6) {
      return const Color(0xFFA8D8F0); // Light blue
    } else if (count <= 9) {
      return const Color(0xFF7BC8E8); // Medium blue
    } else {
      return const Color(0xFF4FB8E0); // Dark blue (for 10+)
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
                            decoration: TextDecoration.none,
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
    // Calculate joy index trend year-to-date (January to current month)
    final now = DateTime.now();

    // Initialize all 12 months (1-12)
    final monthlyJoyData = <int, List<int>>{}; // month -> list of joy levels
    final monthlyJoyCount = <int, int>{}; // month -> count of items with joy
    final monthlyTotalCount = <int, int>{}; // month -> total items decluttered

    for (int month = 1; month <= 12; month++) {
      monthlyJoyData[month] = [];
      monthlyJoyCount[month] = 0;
      monthlyTotalCount[month] = 0;
    }

    for (final item in widget.declutteredItems) {
      // Only include items from current year
      if (item.createdAt.year == now.year) {
        final month = item.createdAt.month; // 1-12

        monthlyTotalCount[month] = (monthlyTotalCount[month] ?? 0) + 1;

        if (item.joyLevel != null && item.joyLevel! > 0) {
          monthlyJoyData.putIfAbsent(month, () => []).add(item.joyLevel!);
          monthlyJoyCount[month] = (monthlyJoyCount[month] ?? 0) + 1;
        }
      }
    }

    // Calculate monthly joy percent for all 12 months
    final monthlyJoyPercent = <int, double>{};
    for (int month = 1; month <= 12; month++) {
      final total = monthlyTotalCount[month] ?? 0;
      final joyCount = monthlyJoyCount[month] ?? 0;
      monthlyJoyPercent[month] = total > 0 ? (joyCount / total * 100) : 0.0;
    }

    // Calculate average joy percent (excluding months with no data)
    final monthsWithData = monthlyJoyPercent.values.where((v) => v > 0).toList();
    final avgJoyPercent = monthsWithData.isEmpty
        ? 0.0
        : monthsWithData.reduce((a, b) => a + b) / monthsWithData.length;

    // Calculate total joy count
    final itemsWithJoy = widget.declutteredItems
        .where((item) => item.joyLevel != null && item.joyLevel! > 0)
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
      final olderAvg = (monthlyJoyPercent[1]! + monthlyJoyPercent[2]! + monthlyJoyPercent[3]!) / 3;

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            isChinese ? '心动指数趋势' : 'Joy Index Trend',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '年度心动轨迹概览' : 'Annual joy trajectory overview',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),

          // Toggle between Joy Percent and Joy Count
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
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
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
              ? '完成了 $sessionsThisYear 次深度整理，投入了 $totalHours 小时的时间。每一次整理都是对自己的温柔对待。'
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
  final Map<int, double> monthlyData; // month index -> value (percent or count)
  final int maxMonths;
  final bool isPercent;
  final bool isChinese;

  _JoyTrendChartPainter({
    required this.monthlyData,
    required this.maxMonths,
    required this.isPercent,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (monthlyData.isEmpty) return;

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

    final axisPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 2;

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    // Calculate dimensions with space for Y-axis labels
    const leftPadding = 20.0;
    const rightPadding = 20.0;
    const topPadding = 20.0;
    const bottomPadding = 40.0;
    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Find max value for scaling
    double maxValue = isPercent
        ? 100.0
        : monthlyData.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 10; // Default when no data
    if (!isPercent) maxValue = maxValue * 1.2; // Add 20% padding for count

    // Draw Y-axis
    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, size.height - bottomPadding),
      axisPaint,
    );

    // Draw X-axis
    canvas.drawLine(
      Offset(leftPadding, size.height - bottomPadding),
      Offset(size.width - rightPadding, size.height - bottomPadding),
      axisPaint,
    );

    // Draw horizontal grid lines and Y-axis labels
    for (int i = 0; i <= 5; i++) {
      final y = topPadding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      // Y-axis labels
      final value = maxValue * (1 - i / 5);
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(0),
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width - 8,
          y - textPainter.height / 2,
        ),
      );
    }

    // Prepare data points for all 12 months (1-12, January to December)
    final points = <Offset>[];
    final labels = <String>[];

    for (int month = 1; month <= 12; month++) {
      final value = monthlyData[month] ?? 0.0;

      final x = leftPadding + (chartWidth * (month - 1) / 11);
      final normalizedValue = value / maxValue;
      final y = topPadding + (chartHeight * (1 - normalizedValue));

      points.add(Offset(x, y));
      labels.add('$month');
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
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 12,
          fontWeight: FontWeight.w500,
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
