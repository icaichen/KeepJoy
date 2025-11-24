import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/declutter_item.dart';
import '../../../widgets/auto_scale_text.dart';

class DeclutterResultsDistributionCard extends StatelessWidget {
  const DeclutterResultsDistributionCard({
    super.key,
    required this.items,
    required this.title,
    required this.subtitle,
    required this.keptLabel,
    required this.resellLabel,
    required this.recycleLabel,
    required this.donateLabel,
    required this.discardLabel,
    required this.totalItemsLabel,
    required this.isChinese,
  });

  final List<DeclutterItem> items;
  final String title;
  final String subtitle;
  final String keptLabel;
  final String resellLabel;
  final String recycleLabel;
  final String donateLabel;
  final String discardLabel;
  final String totalItemsLabel;
  final bool isChinese;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final keepCount = items
        .where((item) => item.status == DeclutterStatus.keep)
        .length;
    final resellCount = items
        .where((item) => item.status == DeclutterStatus.resell)
        .length;
    final recycleCount = items
        .where((item) => item.status == DeclutterStatus.recycle)
        .length;
    final donateCount = items
        .where((item) => item.status == DeclutterStatus.donate)
        .length;
    final discardCount = items
        .where((item) => item.status == DeclutterStatus.discard)
        .length;

    final total =
        keepCount + resellCount + recycleCount + donateCount + discardCount;

    const keepColor = Color(0xFF9FAEF8);
    const resellColor = Color(0xFFFFC857);
    const recycleColor = Color(0xFF4CC9B0);
    const donateColor = Color(0xFFFF8FA3);
    const discardColor = Color(0xFFB99CFF);

    final breakdowns = [
      _OutcomeBreakdown(color: keepColor, label: keptLabel, count: keepCount),
      _OutcomeBreakdown(
        color: resellColor,
        label: resellLabel,
        count: resellCount,
      ),
      _OutcomeBreakdown(
        color: recycleColor,
        label: recycleLabel,
        count: recycleCount,
      ),
      _OutcomeBreakdown(
        color: donateColor,
        label: donateLabel,
        count: donateCount,
      ),
      _OutcomeBreakdown(
        color: discardColor,
        label: discardLabel,
        count: discardCount,
      ),
    ];

    final chartSlices = total > 0
        ? breakdowns.where((b) => b.count > 0).toList()
        : breakdowns;

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
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Center(
            child: _buildOutcomeDonut(
              theme: theme,
              chartSize: 220,
              slices: chartSlices,
              total: total,
            ),
          ),
          const SizedBox(height: 24),
          _buildOutcomeLegend(breakdowns: breakdowns, theme: theme),
        ],
      ),
    );
  }

  Widget _buildOutcomeDonut({
    required ThemeData theme,
    required double chartSize,
    required List<_OutcomeBreakdown> slices,
    required int total,
  }) {
    final hasData = total > 0;
    final emptyTitle = isChinese ? '暂无整理数据' : 'No data yet';
    final emptySubtitle = isChinese
        ? '记录一次整理后即可看到比例。'
        : 'Log a letting-go result to see the breakdown.';

    final innerWidth = chartSize * 0.65;

    return SizedBox(
      width: chartSize,
      height: chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(chartSize),
            painter: _OutcomeDonutPainter(
              slices: hasData ? slices : const <_OutcomeBreakdown>[],
              total: total,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: hasData
                ? SizedBox(
                    key: const ValueKey('letGoData'),
                    width: innerWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalItemsLabel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('letGoEmpty'),
                    width: innerWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emptyTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          emptySubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeLegend({
    required List<_OutcomeBreakdown> breakdowns,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final breakdown in breakdowns)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: breakdown.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: AutoScaleText(
                      breakdown.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AutoScaleText(
                    '${breakdown.count}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF111827),
                    ),
                  ),
                  if (isChinese)
                    Text(
                      '件',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _OutcomeBreakdown {
  final Color color;
  final String label;
  final int count;

  const _OutcomeBreakdown({
    required this.color,
    required this.label,
    required this.count,
  });
}

class _OutcomeDonutPainter extends CustomPainter {
  final List<_OutcomeBreakdown> slices;
  final int total;

  _OutcomeDonutPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.32;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFE7EAF6);

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);

    if (total == 0) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    for (final slice in slices) {
      if (slice.count <= 0) continue;
      final sweepAngle = (slice.count / total) * math.pi * 2;
      if (sweepAngle <= 0) continue;

      paint.shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [slice.color.withValues(alpha: 0.65), slice.color],
      ).createShader(rect);

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
