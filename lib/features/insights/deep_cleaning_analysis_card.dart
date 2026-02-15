import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/deep_cleaning_session.dart';
import '../dashboard/widgets/cleaning_area_legend.dart';

import '../../widgets/smart_image_widget.dart';
import '../../widgets/modern_dialog.dart';
import '../../theme/typography.dart';
import '../insights/widgets/report_ui_constants.dart';

class DeepCleaningAnalysisCard extends StatefulWidget {
  final List<DeepCleaningSession> sessions;
  final String title;
  final String? subtitle;
  final String? emptyStateMessage;
  final void Function(DeepCleaningSession session)? onDeleteSession;

  const DeepCleaningAnalysisCard({
    super.key,
    required this.sessions,
    required this.title,
    this.subtitle,
    this.emptyStateMessage,
    this.onDeleteSession,
  });

  @override
  State<DeepCleaningAnalysisCard> createState() =>
      _DeepCleaningAnalysisCardState();
}

class _DeepCleaningAnalysisCardState extends State<DeepCleaningAnalysisCard> {
  bool _showAllAreas = false;

  @override
  void didUpdateWidget(covariant DeepCleaningAnalysisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Collapse expanded list when underlying data changes (e.g., tab switch)
    if (_showAllAreas && widget.sessions != oldWidget.sessions) {
      setState(() {
        _showAllAreas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Calculate metrics
    final deepCleaningCount = widget.sessions.length;
    final cleanedItemsCount = widget.sessions
        .where((session) => session.itemsCount != null)
        .fold(0, (sum, session) => sum + session.itemsCount!);

    // Total time (in hours)
    final totalTimeSeconds = widget.sessions
        .where((session) => session.elapsedSeconds != null)
        .fold(0, (sum, session) => sum + session.elapsedSeconds!);
    final totalTimeHours = totalTimeSeconds / 3600;

    // Start with all standard areas from CleaningArea enum, count = 0
    final areaCounts = <String, int>{
      for (final area in CleaningArea.values) area.key: 0,
    };

    // Count sessions for each area
    for (final session in widget.sessions) {
      final cleaningArea = CleaningArea.fromString(session.area);
      if (cleaningArea != null) {
        // Standard area - use its key
        areaCounts[cleaningArea.key] = (areaCounts[cleaningArea.key] ?? 0) + 1;
      } else {
        // Custom area entered by user - use the raw string
        areaCounts[session.area] = (areaCounts[session.area] ?? 0) + 1;
      }
    }

    final allAreas = areaCounts.keys.toList()
      ..sort((a, b) {
        final countB = areaCounts[b] ?? 0;
        final countA = areaCounts[a] ?? 0;
        final diff = countB.compareTo(countA);
        if (diff != 0) return diff;
        return a.compareTo(b);
      });

    // Calculate areas cleared (unique areas with sessions)
    final areasCleared = areaCounts.values.where((count) => count > 0).length;

    return Container(
      width: double.infinity,
      decoration: ReportUI.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: ReportTextStyles.sectionHeader),
          if (widget.subtitle != null &&
              widget.subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(widget.subtitle!, style: ReportTextStyles.sectionSubtitle),
          ],
          const SizedBox(height: 20),

          // Metrics grid (2x2)
          Row(
            children: [
              Expanded(
                child: _buildCleanStatCard(
                  value: '$deepCleaningCount',
                  label: l10n.dashboardSessionsLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCleanStatCard(
                  value: '$cleanedItemsCount',
                  label: l10n.dashboardItemsLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCleanStatCard(
                  value: '$areasCleared',
                  label: l10n.dashboardAreasClearedLabel.replaceFirst(
                    'Cleared',
                    'Cleaned',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCleanStatCard(
                  value: totalTimeHours >= 1
                      ? '${totalTimeHours.toStringAsFixed(1)}h'
                      : '${(totalTimeSeconds / 60).toStringAsFixed(0)}m',
                  label: l10n.dashboardTotalTimeLabel,
                ),
              ),
            ],
          ),

          const Divider(height: 32, thickness: 1, color: Color(0xFFE5E7EA)),

          // Cleaning Areas with heatmap
          _buildReportSection(
            context,
            title: l10n.cleaningAreas,
            trailing: CleaningAreaLegend.badge(
              context: context,
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (dialogContext) =>
                      CleaningAreaLegend.dialog(context: dialogContext),
                );
              },
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate button width to fit 3 per row with proper spacing
                final buttonWidth =
                    (constraints.maxWidth - 16) / 3; // 16 = 2 gaps of 8px
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: allAreas.map((area) {
                    final count = areaCounts[area] ?? 0;
                    final entry = CleaningAreaLegend.forCount(count);
                    final displayName = CleaningArea.getDisplayName(
                      area,
                      context,
                    );
                    return Container(
                      width: buttonWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: entry.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: entry.textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 24, thickness: 1, color: Color(0xFFE5E5EA)),
          _buildComparisonsSection(context, l10n, widget.sessions),
        ],
      ),
    );
  }

  Widget _buildComparisonsSection(
    BuildContext context,
    AppLocalizations l10n,
    List<DeepCleaningSession> sessions,
  ) {
    // Group sessions by area (normalized to use CleaningArea.key for standard areas)
    final sessionsByArea = <String, List<DeepCleaningSession>>{};
    for (final session in sessions) {
      final cleaningArea = CleaningArea.fromString(session.area);
      final areaKey = cleaningArea?.key ?? session.area;
      sessionsByArea.putIfAbsent(areaKey, () => []).add(session);
    }

    // Sort areas by session count (descending)
    final sortedAreas = sessionsByArea.keys.toList()
      ..sort((a, b) {
        final countB = sessionsByArea[b]!.length;
        final countA = sessionsByArea[a]!.length;
        return countB.compareTo(countA);
      });

    final visibleAreas = _showAllAreas
        ? sortedAreas
        : sortedAreas.take(3).toList();
    final hiddenCount = _showAllAreas
        ? 0
        : sortedAreas.length > 3
        ? sortedAreas.length - visibleAreas.length
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deepCleaningComparisonsTitle,
          style: ReportTextStyles.sectionHeader,
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Text(
            l10n.deepCleaningComparisonsEmpty,
            style: ReportTextStyles.sectionSubtitle,
          )
        else
          ...visibleAreas.map(
            (area) =>
                _buildAreaGroupRow(context, l10n, area, sessionsByArea[area]!),
          ),
        if (hiddenCount > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showAllAreas = true;
                });
              },
              icon: const Icon(Icons.expand_more_rounded),
              label: Text(
                l10n.localeName.toLowerCase().startsWith('zh')
                    ? '查看更多（$hiddenCount）'
                    : 'View more ($hiddenCount)',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAreaGroupRow(
    BuildContext context,
    AppLocalizations l10n,
    String area,
    List<DeepCleaningSession> areaSessions,
  ) {
    final sessionCount = areaSessions.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAreaSessionsSheet(context, l10n, area, areaSessions),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForArea(area),
                  color: const Color(0xFF6B7280),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CleaningArea.getDisplayName(area, context),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.dashboardSessionTotal(sessionCount),
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAreaSessionsSheet(
    BuildContext context,
    AppLocalizations l10n,
    String area,
    List<DeepCleaningSession> areaSessions,
  ) {
    // Sort sessions by date (newest first)
    final sortedSessions = [...areaSessions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getIconForArea(area),
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CleaningArea.getDisplayName(area, context),
                                style: AppTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              Text(
                                l10n.dashboardSessionTotal(
                                  sortedSessions.length,
                                ),
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      itemCount: sortedSessions.length,
                      itemBuilder: (context, index) {
                        final session = sortedSessions[index];
                        return _buildComparisonRow(context, l10n, session);
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

  Widget _buildComparisonRow(
    BuildContext context,
    AppLocalizations l10n,
    DeepCleaningSession session,
  ) {
    final subtitleParts = <String>[
      _formatSessionDate(session.startTime, l10n),
      _formatSessionTime(session.startTime, l10n),
      if (session.elapsedSeconds != null)
        '${Duration(seconds: session.elapsedSeconds!).inMinutes} min',
    ];

    final row = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showSessionReportSheet(context, l10n, session),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForArea(session.area),
                  color: const Color(0xFF6B7280),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  subtitleParts.join(' · '),
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );

    if (widget.onDeleteSession == null) {
      return row;
    }

    return Dismissible(
      key: Key('deep_cleaning_session_${session.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await ModernDialog.showConfirmation(
              context: context,
              title: l10n.dashboardDeleteSessionTitle,
              content: l10n.dashboardDeleteSessionMessage,
              cancelText: l10n.cancel,
              confirmText: l10n.delete,
            ) ??
            false;
      },
      onDismissed: (_) {
        widget.onDeleteSession?.call(session);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.dashboardSessionDeleted)));
      },
      child: row,
    );
  }

  void _showSessionReportSheet(
    BuildContext context,
    AppLocalizations l10n,
    DeepCleaningSession session,
  ) {
    final improvement = _sessionImprovement(session);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                                    CleaningArea.getDisplayName(
                                      session.area,
                                      context,
                                    ),
                                    style: AppTypography.titleLarge.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatSessionDate(session.startTime, l10n),
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
                                color: const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => Navigator.pop(sheetContext),
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildPhotoCarousel(context, l10n, session),
                        const SizedBox(height: 32),
                        Text(
                          l10n.reportSessionData,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSessionDetailList(
                          l10n: l10n,
                          colon: l10n.localeName.toLowerCase().startsWith('zh')
                              ? '：'
                              : ':',
                          itemsValue: session.itemsCount?.toString() ?? '--',
                          durationValue: session.elapsedSeconds != null
                              ? _formatDuration(session.elapsedSeconds!, l10n)
                              : '--',
                          beforeValue: session.beforeMessinessIndex != null
                              ? session.beforeMessinessIndex!.toStringAsFixed(1)
                              : '--',
                          afterValue: session.afterMessinessIndex != null
                              ? session.afterMessinessIndex!.toStringAsFixed(1)
                              : '--',
                          improvementValue: improvement != null
                              ? '${improvement.toStringAsFixed(0)}%'
                              : '--',
                          focusValue: session.focusIndex?.toString() ?? '--',
                          joyValue: session.moodIndex?.toString() ?? '--',
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

  Widget _buildPhotoCarousel(
    BuildContext context,
    AppLocalizations l10n,
    DeepCleaningSession session,
  ) {
    final slides = [
      _PhotoSlide(
        label: l10n.beforePhoto,
        localPath: session.localBeforePhotoPath,
        remotePath: session.remoteBeforePhotoPath,
      ),
      _PhotoSlide(
        label: l10n.afterPhoto,
        localPath: session.localAfterPhotoPath,
        remotePath: session.remoteAfterPhotoPath,
      ),
    ];

    final allMissing = slides.every(
      (slide) =>
          (slide.localPath == null || slide.localPath!.isEmpty) &&
          (slide.remotePath == null || slide.remotePath!.isEmpty),
    );

    if (allMissing) {
      return Container(
        height: 170,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            l10n.memoryNoPhoto,
            style: const TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 4:3 常见横拍比例，加上标题和间距
        final photoHeight = (constraints.maxWidth * 3 / 4) + 40;
        return SizedBox(
          height: photoHeight,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return _PhotoPage(
                label: slide.label,
                localPath: slide.localPath,
                remotePath: slide.remotePath,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSessionDetailList({
    required AppLocalizations l10n,
    required String colon,
    required String itemsValue,
    required String durationValue,
    required String beforeValue,
    required String afterValue,
    required String improvementValue,
    required String focusValue,
    required String joyValue,
  }) {
    Widget buildRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '$label$colon',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        buildRow(l10n.dashboardItemsLabel, itemsValue),
        buildRow(l10n.dashboardDurationLabel, durationValue),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1),
        ),
        buildRow(l10n.messinessBefore, beforeValue),
        buildRow(l10n.messinessAfter, afterValue),
        buildRow(l10n.dashboardMessinessReducedLabel, improvementValue),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1),
        ),
        buildRow(l10n.dashboardFocusLabel, focusValue),
        buildRow(l10n.dashboardJoyLabel, joyValue),
      ],
    );
  }

  double? _sessionImprovement(DeepCleaningSession session) {
    if (session.beforeMessinessIndex == null ||
        session.afterMessinessIndex == null) {
      return null;
    }
    return _calculateImprovementPercentage(
      session.beforeMessinessIndex,
      session.afterMessinessIndex,
    );
  }

  double? _calculateImprovementPercentage(double? before, double? after) {
    if (before == null || after == null || before <= 0) {
      return null;
    }
    return ((before - after) / before) * 100;
  }

  String _formatDuration(int seconds, AppLocalizations l10n) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    final isChinese = l10n.localeName.toLowerCase().startsWith('zh');

    if (hours > 0) {
      if (isChinese) {
        final buffer = StringBuffer()
          ..write(hours)
          ..write('小时');
        if (minutes > 0) {
          buffer
            ..write(minutes)
            ..write('分钟');
        }
        return buffer.toString();
      }

      final buffer = StringBuffer()
        ..write(hours)
        ..write('h');
      if (minutes > 0) {
        buffer
          ..write(' ')
          ..write(minutes)
          ..write('m');
      }
      return buffer.toString();
    }

    if (minutes > 0) {
      if (isChinese) {
        return '$minutes分钟';
      }
      return (StringBuffer()
            ..write(minutes)
            ..write(' min'))
          .toString();
    }

    if (isChinese) {
      return '$secs秒';
    }
    return (StringBuffer()
          ..write(secs)
          ..write('s'))
        .toString();
  }

  String _formatSessionDate(DateTime date, AppLocalizations l10n) {
    final locale = l10n.localeName;
    return DateFormat.yMMMMd(locale).format(date);
  }

  String _formatSessionTime(DateTime date, AppLocalizations l10n) {
    final locale = l10n.localeName;
    return DateFormat.jm(locale).format(date);
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required List<Color> gradientColors,
    required String value,
    required String label,
    required String subLabel,
  }) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withValues(alpha: 0.15),
            gradientColors[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: gradientColors[0].withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCleanStatCard({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: ReportUI.statCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value, style: ReportTextStyles.statValueSmall),
          const SizedBox(height: 4),
          Text(
            label,
            style: ReportTextStyles.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(
    BuildContext context, {
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  IconData _getIconForArea(String areaValue) {
    final area = CleaningArea.fromString(areaValue);
    if (area != null) {
      switch (area) {
        case CleaningArea.livingRoom:
          return Icons.weekend_outlined;
        case CleaningArea.bedroom:
          return Icons.bed_outlined;
        case CleaningArea.wardrobe:
          return Icons.checkroom_outlined;
        case CleaningArea.bookshelf:
          return Icons.book_outlined;
        case CleaningArea.kitchen:
          return Icons.kitchen_outlined;
        case CleaningArea.desk:
          return Icons.desk_outlined;
      }
    }
    return Icons.home_outlined; // Default icon
  }
}

class _PhotoSlide {
  final String label;
  final String? localPath;
  final String? remotePath;

  const _PhotoSlide({required this.label, this.localPath, this.remotePath});
}

class _PhotoPage extends StatelessWidget {
  final String label;
  final String? localPath;
  final String? remotePath;

  const _PhotoPage({required this.label, this.localPath, this.remotePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 4 / 3, // 常见横向拍摄比例
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF3F4F6),
                child:
                    (localPath == null || localPath!.isEmpty) &&
                        (remotePath == null || remotePath!.isEmpty)
                    ? const Center(
                        child: Icon(
                          Icons.photo_camera_back_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 32,
                        ),
                      )
                    : SmartImageWidget(
                        localPath: localPath,
                        remotePath: remotePath,
                        fit: BoxFit.contain,
                        errorWidget: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Color(0xFF9CA3AF),
                            size: 32,
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
}
