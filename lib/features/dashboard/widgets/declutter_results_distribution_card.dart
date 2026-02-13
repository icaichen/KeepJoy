import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../models/declutter_item.dart';
import '../../insights/widgets/report_ui_constants.dart';

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
      decoration: ReportUI.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ReportTextStyles.sectionHeader),
          const SizedBox(height: 4),
          Text(subtitle, style: ReportTextStyles.sectionSubtitle),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              height: 220,
              width: 220,
              child: CustomPaint(
                painter: _OutcomePiePainter(slices: chartSlices, total: total),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
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

    // Shadow for slices (drawn per-slice)
    final sliceShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    double startAngle = -math.pi / 2;
    const baseGapAngle = 0.03; // base gap (~1.7°) between slices
    final maxCount = slices.isEmpty
        ? 0
        : slices.map((s) => s.count).reduce((a, b) => a > b ? a : b);

    for (final slice in slices) {
      if (slice.count <= 0) continue;
      final sweepAngle = (slice.count / total) * math.pi * 2;
      if (sweepAngle <= baseGapAngle) {
        startAngle += sweepAngle;
        continue;
      }

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      final midAngle = startAngle + sweepAngle / 2;
      // Explode slices outward; larger slices move farther (but capped)
      final explodeFactor = (slice.count / total).clamp(0.0, 1.0);
      final explodeDist = radius * (0.018 + 0.03 * explodeFactor);
      final dx = explodeDist * math.cos(midAngle);
      final dy = explodeDist * math.sin(midAngle);

      // Apply consistent angular gap and scale largest slice
      final gapAngle = baseGapAngle;
      final effectiveStart = startAngle + gapAngle / 2;
      final effectiveSweep = sweepAngle - gapAngle;
      final scale = maxCount > 0
          ? (0.94 + 0.08 * (slice.count / maxCount))
          : 1.0;
      final sliceRect = Rect.fromCircle(center: center, radius: radius * scale);

      canvas.save();
      canvas.translate(dx, dy);

      // Shadow under each slice
      canvas.drawArc(
        sliceRect,
        effectiveStart,
        effectiveSweep,
        true,
        sliceShadowPaint,
      );

      canvas.drawArc(sliceRect, effectiveStart, effectiveSweep, true, paint);
      // Percentage inside slice, tinted darker version of the slice color
      final percent = ((slice.count / total) * 100).toStringAsFixed(
        ((slice.count / total) * 100) >= 10 ? 0 : 1,
      );
      final innerRadius = (radius * scale) * 0.58;
      final innerOffset = Offset(
        center.dx + innerRadius * math.cos(midAngle),
        center.dy + innerRadius * math.sin(midAngle),
      );
      final textColor =
          Color.lerp(slice.color, Colors.black, 0.35) ??
          slice.color.withValues(alpha: 0.9);
      final innerTextPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$percent%\n',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: '${slice.count}',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      innerTextPainter.layout();
      innerTextPainter.paint(
        canvas,
        Offset(
          innerOffset.dx - innerTextPainter.width / 2,
          innerOffset.dy - innerTextPainter.height / 2,
        ),
      );

      // Outside label using slice label
      final labelRadius = radius * scale * 1.05;
      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(midAngle),
        center.dy + labelRadius * math.sin(midAngle),
      );
      final titleColor =
          Color.lerp(slice.color, Colors.black, 0.35) ??
          slice.color.withValues(alpha: 0.9);
      final labelPainter = TextPainter(
        text: TextSpan(
          text: slice.label,
          style: TextStyle(
            color: titleColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout(maxWidth: radius);
      final isRight = math.cos(midAngle) >= 0;
      final labelPos = Offset(
        labelOffset.dx - (isRight ? 0 : labelPainter.width),
        labelOffset.dy - labelPainter.height / 2,
      );
      labelPainter.paint(canvas, labelPos);

      canvas.restore();

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
