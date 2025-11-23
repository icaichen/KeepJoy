import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/deep_cleaning_session.dart';
import '../dashboard/widgets/cleaning_area_legend.dart';
import '../../widgets/auto_scale_text.dart';
import '../../widgets/smart_image_widget.dart';

class DeepCleaningAnalysisCard extends StatelessWidget {
  final List<DeepCleaningSession> sessions;
  final String title;
  final String? emptyStateMessage;

  const DeepCleaningAnalysisCard({
    super.key,
    required this.sessions,
    required this.title,
    this.emptyStateMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Calculate metrics
    final deepCleaningCount = sessions.length;
    final cleanedItemsCount = sessions
        .where((session) => session.itemsCount != null)
        .fold(0, (sum, session) => sum + session.itemsCount!);

    // Total time (in hours)
    final totalTimeSeconds = sessions
        .where((session) => session.elapsedSeconds != null)
        .fold(0, (sum, session) => sum + session.elapsedSeconds!);
    final totalTimeHours = totalTimeSeconds / 3600;

    // Start with all standard areas from CleaningArea enum, count = 0
    final areaCounts = <String, int>{
      for (final area in CleaningArea.values) area.key: 0,
    };

    // Count sessions for each area
    for (final session in sessions) {
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
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Metrics Row 1
          Row(
            children: [
              Expanded(
                child: _buildDeepCleaningMetricItem(
                  context,
                  icon: Icons.cleaning_services_rounded,
                  color: const Color(0xFFB794F6),
                  value: '$deepCleaningCount',
                  label: l10n.dashboardSessionsLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeepCleaningMetricItem(
                  context,
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF5ECFB8),
                  value: '$cleanedItemsCount',
                  label: l10n.dashboardItemsLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Metrics Row 2
          Row(
            children: [
              Expanded(
                child: _buildDeepCleaningMetricItem(
                  context,
                  icon: Icons.location_on_rounded,
                  color: const Color(0xFF89CFF0),
                  value: '$areasCleared',
                  label: l10n.dashboardAreasClearedLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDeepCleaningMetricItem(
                  context,
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFFFFD93D),
                  value: '${totalTimeHours.toStringAsFixed(1)}h',
                  label: l10n.dashboardTotalTimeLabel,
                ),
              ),
            ],
          ),

          const Divider(height: 40, thickness: 1, color: Color(0xFFE5E5EA)),

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
                        '$displayName ($count)',
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
          const SizedBox(height: 24),
          const Divider(height: 40, thickness: 1, color: Color(0xFFE5E5EA)),
          _buildComparisonsSection(context, l10n, sessions),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deepCleaningComparisonsTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Text(
            l10n.deepCleaningComparisonsEmpty,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          )
        else
          ...sortedAreas.map(
            (area) => _buildAreaGroupRow(
              context,
              l10n,
              area,
              sessionsByArea[area]!,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAreaSessionsSheet(context, l10n, area, areaSessions),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EA)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForArea(area),
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  CleaningArea.getDisplayName(area, context),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EA),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIconForArea(area),
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CleaningArea.getDisplayName(area, context),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Text(
                                '${sortedSessions.length} ${sortedSessions.length == 1 ? 'session' : 'sessions'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
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
          ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showSessionReportSheet(context, l10n, session),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EA)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForArea(session.area),
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CleaningArea.getDisplayName(session.area, context),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleParts.join(' · '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${CleaningArea.getDisplayName(session.area, context)} · ${_formatSessionDate(session.startTime, l10n)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatSessionTime(session.startTime, l10n),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPhotoCarousel(context, l10n, session),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: _buildSessionDetailList(
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
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(l10n.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

    return SizedBox(
      height: 180,
      child: PageView.builder(
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
    final labelStyle = const TextStyle(fontSize: 14, color: Color(0xFF6B7280));
    final valueStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
    );

    Widget buildRow(String label, String value) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text('$label$colon', style: labelStyle)),
          Text(value, style: valueStyle),
        ],
      );
    }

    return Column(
      children: [
        buildRow(l10n.dashboardItemsLabel, itemsValue),
        const SizedBox(height: 10),
        buildRow(l10n.dashboardDurationLabel, durationValue),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        const SizedBox(height: 14),
        buildRow(l10n.messinessBefore, beforeValue),
        const SizedBox(height: 10),
        buildRow(l10n.messinessAfter, afterValue),
        const SizedBox(height: 10),
        buildRow(l10n.dashboardMessinessReducedLabel, improvementValue),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        const SizedBox(height: 14),
        buildRow(l10n.dashboardFocusLabel, focusValue),
        const SizedBox(height: 10),
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

  Widget _buildDeepCleaningMetricItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          AutoScaleText(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          AutoScaleText(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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
        if (trailing != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              trailing,
            ],
          )
        else
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        const SizedBox(height: 12),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF3F4F6),
                child: (localPath == null || localPath!.isEmpty) &&
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
                        fit: BoxFit.cover,
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
