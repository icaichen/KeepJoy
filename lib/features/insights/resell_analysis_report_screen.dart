import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/resell_item.dart';

enum TrendMetric {
  resellItems('转卖数量', 'Resell Items'),
  listedDays('平均上架天数', 'Avg Listed Days'),
  resellValue('转卖价值', 'Resell Value');

  const TrendMetric(this.chinese, this.english);
  final String chinese;
  final String english;

  String label(bool isChinese) => isChinese ? chinese : english;
}

class ResellAnalysisReportScreen extends StatefulWidget {
  const ResellAnalysisReportScreen({super.key, required this.resellItems});

  final List<ResellItem> resellItems;

  @override
  State<ResellAnalysisReportScreen> createState() =>
      _ResellAnalysisReportScreenState();
}

class _ResellAnalysisReportScreenState
    extends State<ResellAnalysisReportScreen> {
  TrendMetric _selectedMetric = TrendMetric.resellItems;

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    // Calculate metrics
    final soldItems = widget.resellItems
        .where((item) => item.status == ResellStatus.sold)
        .toList();
    final totalSoldItems = soldItems.length;

    // Average transaction price
    final avgPrice = soldItems.isEmpty
        ? 0.0
        : soldItems
                  .map((item) => item.soldPrice ?? 0.0)
                  .reduce((a, b) => a + b) /
              totalSoldItems;

    // Average days to sell
    final avgDays = soldItems.isEmpty
        ? 0.0
        : soldItems
                  .where((item) => item.soldDate != null)
                  .map(
                    (item) => item.soldDate!.difference(item.createdAt).inDays,
                  )
                  .fold(0, (a, b) => a + b) /
              soldItems.where((item) => item.soldDate != null).length;

    // Success rate
    final successRate = widget.resellItems.isEmpty
        ? 0.0
        : (totalSoldItems / widget.resellItems.length) * 100;

    // Total revenue
    final totalRevenue = soldItems.isEmpty
        ? 0.0
        : soldItems
              .map((item) => item.soldPrice ?? 0.0)
              .reduce((a, b) => a + b);

    // Prepare trend data
    final trendData = _calculateTrendData();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final scrollY = (constraints.maxHeight - kToolbarHeight).clamp(
                  0.0,
                  150.0,
                );
                final progress = 1 - (scrollY / 150.0);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background
                    Transform.translate(
                      offset: Offset(0, progress * -30),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFF9E6), Color(0xFFFFD93D)],
                          ),
                        ),
                      ),
                    ),

                    // Large title
                    Positioned(
                      left: 24,
                      bottom: 40,
                      child: Opacity(
                        opacity: 1 - progress,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isChinese ? '转卖分析' : 'Resell Analysis',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isChinese ? '完整报告' : 'Full Report',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top pinned header with blur
                    Align(
                      alignment: Alignment.topCenter,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10 * progress,
                            sigmaY: 10 * progress,
                          ),
                          child: Container(
                            height:
                                kToolbarHeight +
                                MediaQuery.of(context).padding.top,
                            color: Colors.white.withValues(
                              alpha: progress * 0.9,
                            ),
                            alignment: Alignment.center,
                            child: SafeArea(
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.black.withValues(
                                        alpha: progress,
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Expanded(
                                    child: Opacity(
                                      opacity: progress,
                                      child: Text(
                                        isChinese ? '转卖分析' : 'Resell Analysis',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
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
                    ),
                  ],
                );
              },
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metrics Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
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
                            isChinese ? '核心指标' : 'Key Metrics',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  label: isChinese ? '平均交易价' : 'Avg Price',
                                  value: '¥${avgPrice.toStringAsFixed(0)}',
                                  icon: Icons.payments_rounded,
                                  color: const Color(0xFFFFD93D),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  label: isChinese ? '平均售出天数' : 'Avg Days',
                                  value: avgDays.toStringAsFixed(0),
                                  icon: Icons.schedule_rounded,
                                  color: const Color(0xFF89CFF0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  label: isChinese ? '成交率' : 'Success Rate',
                                  value: '${successRate.toStringAsFixed(0)}%',
                                  icon: Icons.check_circle_rounded,
                                  color: const Color(0xFF5ECFB8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  label: isChinese ? '总收入' : 'Total Revenue',
                                  value: '¥${totalRevenue.toStringAsFixed(0)}',
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: const Color(0xFFFF9AA2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Trend Analysis Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
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
                            isChinese ? '趋势分析' : 'Trend Analysis',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 16),

                          // Metric selector
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: TrendMetric.values.map((metric) {
                                final isSelected = _selectedMetric == metric;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMetric = metric;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Text(
                                        metric.label(isChinese),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isSelected
                                                  ? Colors.black87
                                                  : Colors.black54,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              fontSize: 11,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Chart
                          if (trendData.isEmpty)
                            Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: Text(
                                isChinese ? '暂无数据' : 'No data available',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                            )
                          else
                            SizedBox(
                              height: 250,
                              child: CustomPaint(
                                painter: _TrendChartPainter(
                                  trendData: trendData,
                                  selectedMetric: _selectedMetric,
                                  isChinese: isChinese,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateTrendData() {
    final now = DateTime.now();
    final monthlyData = <int, List<double>>{};

    // Group data by month (last 6 months)
    for (final item in widget.resellItems) {
      final monthsAgo =
          ((now.year - item.createdAt.year) * 12 +
                  (now.month - item.createdAt.month))
              .clamp(0, 5);

      if (monthsAgo < 6) {
        monthlyData.putIfAbsent(monthsAgo, () => []);

        switch (_selectedMetric) {
          case TrendMetric.resellItems:
            monthlyData[monthsAgo]!.add(1); // Count items
            break;
          case TrendMetric.listedDays:
            if (item.status == ResellStatus.sold && item.soldDate != null) {
              final days = item.soldDate!
                  .difference(item.createdAt)
                  .inDays
                  .toDouble();
              monthlyData[monthsAgo]!.add(days);
            }
            break;
          case TrendMetric.resellValue:
            if (item.status == ResellStatus.sold && item.soldPrice != null) {
              monthlyData[monthsAgo]!.add(item.soldPrice!);
            }
            break;
        }
      }
    }

    // Calculate aggregate values
    final result = <int, double>{};
    monthlyData.forEach((month, values) {
      if (values.isNotEmpty) {
        if (_selectedMetric == TrendMetric.resellItems) {
          result[month] = values.length.toDouble(); // Total count
        } else if (_selectedMetric == TrendMetric.resellValue) {
          result[month] = values.reduce((a, b) => a + b); // Total value
        } else {
          result[month] =
              values.reduce((a, b) => a + b) / values.length; // Average
        }
      }
    });

    return result;
  }
}

// Trend chart painter
class _TrendChartPainter extends CustomPainter {
  final Map<int, double> trendData;
  final TrendMetric selectedMetric;
  final bool isChinese;

  _TrendChartPainter({
    required this.trendData,
    required this.selectedMetric,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trendData.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFFFD93D)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFFFD93D).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = const Color(0xFFFFD93D)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Dimensions
    const padding = 40.0;
    const bottomPadding = 50.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - padding - bottomPadding;

    // Find max value
    final maxValue = trendData.values.reduce((a, b) => a > b ? a : b) * 1.2;

    // Draw horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = padding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Prepare data points (reverse order so month 0 is on the right)
    final points = <Offset>[];
    final labels = <String>[];
    final sortedMonths = trendData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final value = trendData[month]!;

      final x =
          padding +
          (chartWidth *
              i /
              (sortedMonths.length - 1).clamp(1, double.infinity));
      final normalizedValue = value / maxValue;
      final y = padding + (chartHeight * (1 - normalizedValue));

      points.add(Offset(x, y));

      final monthDate = DateTime(now.year, now.month - month, 1);
      labels.add('${monthDate.month}${isChinese ? '月' : 'M'}');
    }

    if (points.isEmpty) return;

    // Draw filled area
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

    // Draw line
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

    // Draw dots and labels
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      canvas.drawCircle(point, 6, dotPaint);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);

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
