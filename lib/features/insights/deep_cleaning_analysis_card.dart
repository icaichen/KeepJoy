import 'package:flutter/material.dart';
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

    // Messiness insights
    final sessionsWithBefore = sessions
        .where((s) => s.beforeMessinessIndex != null)
        .toList();
    final sessionsWithAfter = sessions
        .where((s) => s.afterMessinessIndex != null)
        .toList();
    final sessionsWithBoth = sessions
        .where(
          (s) =>
              s.beforeMessinessIndex != null && s.afterMessinessIndex != null,
        )
        .toList();

    final beforeAverage = _calculateAverageMessiness(
      sessionsWithBefore,
      (s) => s.beforeMessinessIndex,
    );
    final afterAverage = _calculateAverageMessiness(
      sessionsWithAfter,
      (s) => s.afterMessinessIndex,
    );

    final improvementPercent = _calculateImprovementPercentage(
      beforeAverage,
      afterAverage,
    );
    final bestImprovementSession = _findBestImprovementSession(
      sessionsWithBoth,
    );
    final bestImprovementPercent = bestImprovementSession != null
        ? _calculateImprovementPercentage(
            bestImprovementSession.beforeMessinessIndex,
            bestImprovementSession.afterMessinessIndex,
          )
        : null;

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
    final allAreas = <String>{...commonAreas, ...sessionsByArea.keys}.toList();

    // Calculate area counts for heatmap
    final areaCounts = <String, int>{};
    for (final area in allAreas) {
      areaCounts[area] = sessionsByArea[area]?.length ?? 0;
    }

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

          if (sessionsWithBefore.isNotEmpty || sessionsWithAfter.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: _buildReportSection(
                context,
                title: l10n.beforeAfterComparison,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMessinessSummaryCard(
                            context,
                            label: l10n.messinessBefore,
                            value: beforeAverage,
                            color: const Color(0xFFEF6C99),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMessinessSummaryCard(
                            context,
                            label: l10n.messinessAfter,
                            value: afterAverage,
                            color: const Color(0xFF34D399),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (improvementPercent != null)
                      _buildImprovementCallout(
                        context,
                        improvementPercent: improvementPercent,
                        topArea: bestImprovementSession?.area,
                        topAreaImprovement: bestImprovementPercent,
                        improvementLabel: l10n.improvement,
                        areaLabel: l10n.cleaningAreas,
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.dashboardNoDetailedMetrics,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
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
        ],
      ),
    );
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

  Widget _buildMessinessSummaryCard(
    BuildContext context, {
    required String label,
    required double? value,
    required Color color,
  }) {
    final displayValue = () {
      if (value == null) return '--';
      final decimals = value >= 100 ? 0 : 1;
      return value.toStringAsFixed(decimals);
    }();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayValue,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementCallout(
    BuildContext context, {
    required double improvementPercent,
    String? topArea,
    double? topAreaImprovement,
    required String improvementLabel,
    required String areaLabel,
  }) {
    final improvementText = improvementPercent.isFinite
        ? '${improvementPercent.round()}%'
        : '--';
    final areaText = (topArea != null && topAreaImprovement != null)
        ? '${topAreaImprovement.round()}% · $topArea'
        : topArea;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF111827).withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_down_rounded,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  improvementLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  improvementText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                if (areaText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    areaLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    areaText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  double? _calculateAverageMessiness(
    List<DeepCleaningSession> data,
    double? Function(DeepCleaningSession) selector,
  ) {
    if (data.isEmpty) return null;
    final values = data
        .map(selector)
        .whereType<double>()
        .where((value) => value.isFinite)
        .toList();
    if (values.isEmpty) return null;
    final sum = values.reduce((a, b) => a + b);
    return sum / values.length;
  }

  double? _calculateImprovementPercentage(double? before, double? after) {
    if (before == null || after == null || before <= 0) return null;
    return ((before - after) / before) * 100;
  }

  DeepCleaningSession? _findBestImprovementSession(
    List<DeepCleaningSession> sessions,
  ) {
    DeepCleaningSession? bestSession;
    double? bestImprovement;

    for (final session in sessions) {
      final improvement = _calculateImprovementPercentage(
        session.beforeMessinessIndex,
        session.afterMessinessIndex,
      );
      if (improvement == null) continue;
      if (bestImprovement == null || improvement > bestImprovement) {
        bestImprovement = improvement;
        bestSession = session;
      }
    }

    return bestSession;
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
