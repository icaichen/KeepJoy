import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/deep_cleaning_session.dart';
import '../dashboard/widgets/cleaning_area_legend.dart';
import '../../widgets/auto_scale_text.dart';

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

    if (sessions.isEmpty) {
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
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              emptyStateMessage ?? 'No deep cleaning records yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      );
    }

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

    // Group sessions by area
    final sessionsByArea = <String, List<DeepCleaningSession>>{};
    for (final session in sessions) {
      sessionsByArea.update(
        session.area,
        (list) => list..add(session),
        ifAbsent: () => [session],
      );
    }

    // Common areas
    final commonAreas = [
      l10n.kitchen,
      l10n.bedroom,
      l10n.livingRoom,
      l10n.bathroom,
      l10n.study,
      l10n.closet,
    ];

    // Combine common areas with custom areas
    final areaSet = <String>{...commonAreas, ...sessionsByArea.keys};

    // Calculate area counts for heatmap
    final areaCounts = <String, int>{
      for (final area in areaSet) area: sessionsByArea[area]?.length ?? 0,
    };

    final allAreas = areaSet.toList()
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
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allAreas.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final area = allAreas[index];
                  final count = areaCounts[area] ?? 0;
                  final entry = CleaningAreaLegend.forCount(count);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: entry.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$area ($count)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: entry.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
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
    if (sessions.isEmpty) {
      return Text(
        l10n.deepCleaningComparisonsEmpty,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.black54),
      );
    }

    final sortedSessions = [...sessions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

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
        ...sortedSessions.map(
          (session) => _buildComparisonRow(context, l10n, session),
        ),
      ],
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
                child: const Icon(
                  Icons.compare_rounded,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.area,
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
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
              ),
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
                  '${session.area} · ${_formatSessionDate(session.startTime, l10n)}',
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
                    colon: l10n.localeName.toLowerCase().startsWith('zh') ? '：' : ':',
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
      _PhotoSlide(label: l10n.beforePhoto, path: session.beforePhotoPath),
      _PhotoSlide(label: l10n.afterPhoto, path: session.afterPhotoPath),
    ];

    final allMissing = slides.every(
      (slide) => slide.path == null || slide.path!.isEmpty,
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
          return _PhotoPage(label: slide.label, path: slide.path);
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
    final labelStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF6B7280),
    );
    final valueStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
    );

    Widget buildRow(String label, String value) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$label$colon',
              style: labelStyle,
            ),
          ),
          Text(
            value,
            style: valueStyle,
          ),
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
  }

class _PhotoSlide {
  final String label;
  final String? path;

  const _PhotoSlide({required this.label, this.path});
}

class _PhotoPage extends StatelessWidget {
  final String label;
  final String? path;

  const _PhotoPage({required this.label, this.path});

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
                child: path == null || path!.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.photo_camera_back_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 32,
                        ),
                      )
                    : Image.file(
                        File(path!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
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
