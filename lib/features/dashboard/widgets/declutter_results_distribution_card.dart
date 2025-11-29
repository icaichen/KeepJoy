import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/declutter_item.dart';

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
            child: SizedBox(
              height: 220,
              width: 220,
              child: CustomPaint(
                painter: _OutcomePiePainter(
                  slices: chartSlices,
                  total: total,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildOutcomeLegend(
            breakdowns: breakdowns,
            total: total,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeLegend({
    required List<_OutcomeBreakdown> breakdowns,
    required int total,
    required ThemeData theme,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 2 * 8) / 3; // 3 columns
        return Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: breakdowns.map((b) {
              final percentValue = total > 0 ? (b.count / total * 100) : 0.0;
              final percent = percentValue >= 10
                  ? percentValue.toStringAsFixed(0)
                  : percentValue.toStringAsFixed(1);
              const labelColor = Color(0xFF111827);
              const percentColor = Color(0xFF6B7280);
              return SizedBox(
                width: itemWidth,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: b.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                            b.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: labelColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$percent%',
                            style: TextStyle(
                              fontSize: 11,
                              color: percentColor,
                            ),
                          ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
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

class _OutcomePiePainter extends CustomPainter {
  final List<_OutcomeBreakdown> slices;
  final int total;

  _OutcomePiePainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (total == 0) {
      final basePaint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, basePaint);
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    final separatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    double startAngle = -math.pi / 2;
    for (final slice in slices) {
      if (slice.count <= 0) continue;
      final sweepAngle = (slice.count / total) * math.pi * 2;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      canvas.drawArc(rect, startAngle, sweepAngle, true, separatorPaint);

      // Count label inside slice
      final midAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius * 0.6;
      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(midAngle),
        center.dy + labelRadius * math.sin(midAngle),
      );
      final labelColor =
          Color.lerp(slice.color, Colors.black, 0.3) ?? Colors.black87;
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${slice.count}',
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - textPainter.width / 2,
          labelOffset.dy - textPainter.height / 2,
        ),
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
