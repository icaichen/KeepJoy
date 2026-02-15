import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';
import 'package:keepjoy_app/features/insights/unified/models/enhanced_report_models.dart';

enum _ReportRange { days7, days30, yearly }

class ResellAnalysisReportScreen extends StatefulWidget {
  const ResellAnalysisReportScreen({
    super.key,
    required this.resellItems,
    required this.declutteredItems,
  });

  final List<ResellItem> resellItems;
  final List<DeclutterItem> declutteredItems;

  @override
  State<ResellAnalysisReportScreen> createState() =>
      _ResellAnalysisReportScreenState();
}

class _ResellAnalysisReportScreenState
    extends State<ResellAnalysisReportScreen> {
  _ReportRange _selectedRange = _ReportRange.yearly;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _rangeStart {
    final now = DateTime.now();
    switch (_selectedRange) {
      case _ReportRange.days7:
        return _todayStart.subtract(const Duration(days: 6));
      case _ReportRange.days30:
        return _todayStart.subtract(const Duration(days: 29));
      case _ReportRange.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime get _rangeEndExclusive {
    final now = DateTime.now();
    switch (_selectedRange) {
      case _ReportRange.days7:
      case _ReportRange.days30:
        return _todayStart.add(const Duration(days: 1));
      case _ReportRange.yearly:
        return DateTime(now.year + 1, 1, 1);
    }
  }

  bool _inSelectedRange(DateTime date) {
    return !date.isBefore(_rangeStart) && date.isBefore(_rangeEndExclusive);
  }

  String _rangeLabel(bool isChinese) {
    switch (_selectedRange) {
      case _ReportRange.days7:
        return isChinese ? '最近7天' : 'Last 7 Days';
      case _ReportRange.days30:
        return isChinese ? '最近30天' : 'Last 30 Days';
      case _ReportRange.yearly:
        return isChinese ? '每年' : 'Yearly';
    }
  }

  List<ResellItem> get _filteredResellItems {
    return widget.resellItems.where((item) {
      final baseDate = item.soldDate ?? item.createdAt;
      return _inSelectedRange(baseDate);
    }).toList();
  }

  void _showRangeSelector(bool isChinese) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        Widget buildOption(_ReportRange range, String label) {
          final selected = _selectedRange == range;
          return ListTile(
            title: Text(
              label,
              style: ReportTextStyles.body.copyWith(
                color: ReportUI.primaryTextColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB))
                : null,
            onTap: () {
              setState(() => _selectedRange = range);
              Navigator.pop(sheetContext);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              buildOption(
                _ReportRange.days7,
                isChinese ? '最近7天' : 'Last 7 Days',
              ),
              buildOption(
                _ReportRange.days30,
                isChinese ? '最近30天' : 'Last 30 Days',
              ),
              buildOption(_ReportRange.yearly, isChinese ? '每年' : 'Yearly'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Chart Data Class
  static const _chartBlue = Color(0xFF2563EB);
  static const _chartTeal = Color(0xFF14B8A6);

  List<_ChartDataPoint> _getChartData() {
    final now = DateTime.now();
    final points = <_ChartDataPoint>[];
    final dataSource = _filteredResellItems;

    if (_selectedRange == _ReportRange.days7) {
      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        // Simple day grouping
        final dayItems = dataSource.where((item) {
          if (item.status != ResellStatus.sold || item.soldDate == null) {
            return false;
          }
          return item.soldDate!.year == date.year &&
              item.soldDate!.month == date.month &&
              item.soldDate!.day == date.day;
        }).toList();

        final revenue = dayItems.fold(
          0.0,
          (sum, item) => sum + (item.soldPrice ?? 0),
        );
        final volume = dayItems.length.toDouble();

        // Weekday labels (Mon, Tue, etc.)
        const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        // Or localized
        const weekdaysZh = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

        final isZh = Localizations.localeOf(
          context,
        ).languageCode.toLowerCase().startsWith('zh');
        final label = isZh
            ? weekdaysZh[date.weekday - 1]
            : weekdays[date.weekday - 1];

        points.add(
          _ChartDataPoint(label: label, revenue: revenue, volume: volume),
        );
      }
    } else if (_selectedRange == _ReportRange.days30) {
      // Aggregate into 6 buckets (5 days each) for a cleaner 30-day trend.
      final rangeStart = _todayStart.subtract(const Duration(days: 29));
      const bucketCount = 6;
      const bucketSizeDays = 5;
      for (int bucket = 0; bucket < bucketCount; bucket++) {
        final bucketStart = rangeStart.add(
          Duration(days: bucket * bucketSizeDays),
        );
        final bucketEnd = bucket == bucketCount - 1
            ? _todayStart.add(const Duration(days: 1))
            : bucketStart.add(const Duration(days: bucketSizeDays));
        final bucketItems = dataSource.where((item) {
          if (item.status != ResellStatus.sold || item.soldDate == null) {
            return false;
          }
          final soldAt = item.soldDate!;
          return !soldAt.isBefore(bucketStart) && soldAt.isBefore(bucketEnd);
        }).toList();

        final revenue = bucketItems.fold(
          0.0,
          (sum, item) => sum + (item.soldPrice ?? 0),
        );
        final volume = bucketItems.length.toDouble();

        points.add(
          _ChartDataPoint(
            label: '${bucketStart.month}/${bucketStart.day}',
            revenue: revenue,
            volume: volume,
          ),
        );
      }
    } else {
      // 1Y - Monthly data
      // We already have monthly stats in EnhancedResellStats but need to regenerate here to ensure consistent structure
      // or use the existing logic. Let's rebuild for dual axis structure.
      for (int i = 1; i <= 12; i++) {
        final monthItems = dataSource.where((item) {
          if (item.status != ResellStatus.sold || item.soldDate == null) {
            return false;
          }
          return item.soldDate!.year == now.year && item.soldDate!.month == i;
        }).toList();

        final revenue = monthItems.fold(
          0.0,
          (sum, item) => sum + (item.soldPrice ?? 0),
        );
        final volume = monthItems.length.toDouble();

        points.add(
          _ChartDataPoint(label: '$i月', revenue: revenue, volume: volume),
        );
      }
    }

    return points;
  }

  Widget _buildChartLegend(bool isChinese) {
    return Row(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _chartBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isChinese ? '收入' : 'Revenue',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _chartBlue,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _chartTeal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isChinese ? '销量' : 'Volume',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _chartTeal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final responsive = context.responsive;
    final horizontalPadding = responsive.horizontalPadding;
    final topPadding = responsive.safeAreaPadding.top;
    final currencySymbol = isChinese ? '¥' : '\$';

    final filteredResellItems = _filteredResellItems;
    final stats = EnhancedResellStats.fromItems(
      filteredResellItems,
      widget.declutteredItems,
    );

    final soldItems = filteredResellItems
        .where((item) => item.status == ResellStatus.sold)
        .toList();

    // Prepare trend data
    final chartPoints = _getChartData();
    final pageName = l10n.dashboardResellReportTitle;

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
                // Background removed for consistency
                Container(
                  height: 800,
                  color: const Color(0xFFF5F5F7), // Standard background
                ),
                // Content on top
                Column(
                  children: [
                    SizedBox(height: responsive.totalTwoLineHeaderHeight),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Metrics Section

                              // Premium Metrics List (Vertical with Charts)
                              _buildPremiumMetricList(
                                context,
                                isChinese,
                                stats,
                                soldItems,
                                currencySymbol,
                              ),

                              const SizedBox(height: ReportUI.sectionGap),

                              // Category Performance Analysis
                              Container(
                                decoration: ReportUI.cardDecoration,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isChinese
                                                    ? '品类表现分析'
                                                    : 'Category Performance',
                                                style: ReportTextStyles
                                                    .sectionHeader,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                isChinese
                                                    ? '各品类的成交金额、成交率与平均售出天数'
                                                    : 'Revenue, sold rate, and avg days to sell',
                                                style: ReportTextStyles
                                                    .sectionSubtitle,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _showCategoryInfo(
                                            context,
                                            isChinese,
                                          ),
                                          icon: const Icon(
                                            Icons.info_outline_rounded,
                                            size: 20,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                          tooltip: isChinese ? '数据说明' : 'Info',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    _buildCategoryPerformance(
                                      context,
                                      isChinese,
                                      stats,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: ReportUI.sectionGap),

                              // Trend Analysis Section
                              Container(
                                decoration: ReportUI.cardDecoration,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isChinese
                                                    ? '趋势分析'
                                                    : 'Trend Analysis',
                                                style: ReportTextStyles
                                                    .sectionHeader,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                isChinese
                                                    ? '成交金额与销量随时间的变化'
                                                    : 'Revenue and sold volume over time',
                                                style: ReportTextStyles
                                                    .sectionSubtitle,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _showTrendInfo(
                                            context,
                                            isChinese,
                                          ),
                                          icon: const Icon(
                                            Icons.info_outline_rounded,
                                            size: 20,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                          tooltip: isChinese ? '数据说明' : 'Info',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Legend
                                    _buildChartLegend(isChinese),
                                    const SizedBox(height: 12),

                                    // Chart (always show, even with no data)
                                    ClipRect(
                                      child: SizedBox(
                                        height: 180,
                                        width: double.infinity,
                                        child: CustomPaint(
                                          size: const Size(
                                            double.infinity,
                                            180,
                                          ),
                                          painter: _DualTrendChartPainter(
                                            dataPoints: chartPoints,
                                            isChinese: isChinese,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: ReportUI.sectionGap),

                              // 30+ Days Unsold Items
                              Container(
                                decoration: ReportUI.cardDecoration,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isChinese
                                                    ? '超过30天未售出统计'
                                                    : '30+ Days Unsold',
                                                style: ReportTextStyles
                                                    .sectionHeader,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                isChinese
                                                    ? '各品类超过30天的件数'
                                                    : 'Count by category (30+ days unsold)',
                                                style: ReportTextStyles
                                                    .sectionSubtitle,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _showUnsoldInfo(
                                            context,
                                            isChinese,
                                          ),
                                          icon: const Icon(
                                            Icons.info_outline_rounded,
                                            size: 20,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                          tooltip: isChinese ? '数据说明' : 'Info',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    _buildUnsoldItems(
                                      context,
                                      isChinese,
                                      filteredResellItems,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: ReportUI.sectionGap),

                              // 交易洞察 Summary Section
                              Container(
                                decoration: ReportUI.cardDecoration,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isChinese
                                          ? '交易洞察'
                                          : 'Transaction Insights',
                                      style: ReportTextStyles.sectionHeader,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildTransactionInsights(
                                      context,
                                      isChinese,
                                      filteredResellItems,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                final scrollProgress =
                    (scrollOffset / responsive.twoLineHeaderContentHeight)
                        .clamp(0.0, 1.0);
                final collapsedHeaderOpacity = scrollProgress >= 1.0
                    ? 1.0
                    : 0.0;
                return IgnorePointer(
                  ignoring: collapsedHeaderOpacity < 0.5,
                  child: Opacity(opacity: collapsedHeaderOpacity, child: child),
                );
              },
              child: Container(
                height: responsive.collapsedHeaderHeight,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding + 6,
                  horizontalPadding,
                  8,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F7),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pageName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: responsive.titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showRangeSelector(isChinese),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: ReportUI.statCardDecoration.copyWith(
                          color: Colors.white,
                          boxShadow: const [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _rangeLabel(isChinese),
                              style: ReportTextStyles.label.copyWith(
                                color: ReportUI.secondaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                final scrollProgress =
                    (scrollOffset / responsive.twoLineHeaderContentHeight)
                        .clamp(0.0, 1.0);
                final headerOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
                return Opacity(opacity: headerOpacity, child: child);
              },
              child: Container(
                height: responsive.totalTwoLineHeaderHeight,
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: topPadding + 12,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pageName,
                            style: TextStyle(
                              fontSize: responsive.largeTitleFontSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.dashboardResellReportSubtitle,
                            style: TextStyle(
                              fontSize: responsive.bodyFontSize,
                              color: const Color(0xFF6B7280),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showRangeSelector(isChinese),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: ReportUI.statCardDecoration.copyWith(
                          color: Colors.white,
                          boxShadow: const [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _rangeLabel(isChinese),
                              style: ReportTextStyles.label.copyWith(
                                color: ReportUI.secondaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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

  Widget _buildPremiumMetricList(
    BuildContext context,
    bool isChinese,
    EnhancedResellStats stats,
    List<ResellItem> soldItems,
    String currencySymbol,
  ) {
    final now = DateTime.now();
    // Generate last 6 months (including current)
    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - 5 + i);
      return d.month;
    });

    // 1. Revenue Data
    final revenueData = months
        .map((m) => stats.monthlyRevenue[m] ?? 0.0)
        .toList();
    final revenueTrend = stats.trendAnalysis.changePercent;

    // 2. Sell-Through Data (Sold Count)
    final soldData = months
        .map((m) => (stats.monthlySoldCount[m] ?? 0).toDouble())
        .toList();
    final soldTrend = stats.monthlyComparison.lastMonth > 0
        ? ((stats.monthlyComparison.thisMonth -
                  stats.monthlyComparison.lastMonth) /
              stats.monthlyComparison.lastMonth *
              100)
        : (stats.monthlyComparison.thisMonth > 0 ? 100.0 : 0.0);

    // 3. Avg Price Data
    final avgPriceData = months.map((m) {
      final rev = stats.monthlyRevenue[m] ?? 0.0;
      final count = stats.monthlySoldCount[m] ?? 0;
      return count > 0 ? rev / count : 0.0;
    }).toList();
    final currentAvgPrice = avgPriceData.last;
    final prevAvgPrice = avgPriceData[4]; // 2nd to last
    final avgPriceTrend = prevAvgPrice > 0
        ? ((currentAvgPrice - prevAvgPrice) / prevAvgPrice * 100)
        : (currentAvgPrice > 0 ? 100.0 : 0.0);

    // 4. Days to Sell Data
    final monthlyAvgDays = <int, double>{};
    for (final m in months) {
      final itemsInMonth = soldItems
          .where((item) => item.soldDate != null && item.soldDate!.month == m)
          .toList();
      if (itemsInMonth.isNotEmpty) {
        final totalDays = itemsInMonth.fold(
          0,
          (sum, item) => sum + item.soldDate!.difference(item.createdAt).inDays,
        );
        monthlyAvgDays[m] = totalDays / itemsInMonth.length;
      } else {
        monthlyAvgDays[m] = 0.0;
      }
    }
    final daysData = months.map((m) => monthlyAvgDays[m] ?? 0.0).toList();
    final currentDays = daysData.last;
    final prevDays = daysData[4];
    final daysTrend = prevDays > 0
        ? ((currentDays - prevDays) / prevDays * 100)
        : 0.0;

    return Column(
      children: [
        _buildNewStyleMetricCard(
          context,
          title: isChinese ? '总收入' : 'Total Revenue',
          value: '$currencySymbol${stats.totalRevenue.toStringAsFixed(0)}',
          icon: Icons.attach_money_rounded,
          color: const Color(0xFF2563EB),
          trend: revenueTrend,
          chartData: revenueData,
        ),
        const SizedBox(height: 10),
        _buildNewStyleMetricCard(
          context,
          title: isChinese ? '成交率' : 'Sell-Through Rate',
          value: '${stats.successRate.toStringAsFixed(0)}%',
          icon: Icons.speed_rounded,
          color: const Color(0xFF14B8A6),
          trend: soldTrend,
          chartData: soldData,
        ),
        const SizedBox(height: 10),
        _buildNewStyleMetricCard(
          context,
          title: isChinese ? '平均售价' : 'Avg. Price',
          value: '$currencySymbol${stats.averageSoldPrice.toStringAsFixed(2)}',
          icon: Icons.local_offer_rounded,
          color: const Color(0xFF9333EA),
          trend: avgPriceTrend,
          chartData: avgPriceData,
        ),
        const SizedBox(height: 10),
        _buildNewStyleMetricCard(
          context,
          title: isChinese ? '售出天数' : 'Days to Sell',
          value:
              '${stats.averageListedDays.toStringAsFixed(0)}${isChinese ? '天' : ' Days'}',
          icon: Icons.hourglass_bottom_rounded,
          color: const Color(0xFFF97316),
          trend: daysTrend,
          chartData: daysData,
          inverseTrend: true,
        ),
      ],
    );
  }

  Widget _buildNewStyleMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double trend,
    required List<double> chartData,
    bool inverseTrend = false,
  }) {
    final isNearZero = trend.abs() < 1;
    final isPositive = trend > 0;
    final isNegative = trend < 0;
    final isGood = inverseTrend ? isNegative : isPositive;

    final trendText = isNearZero ? '0%' : '${trend.abs().toStringAsFixed(0)}%';
    final trendTextColor = isNearZero
        ? const Color(0xFF94A3B8)
        : (isGood ? const Color(0xFF14B8A6) : const Color(0xFFEF4444));
    final trendIcon = isNearZero
        ? Icons.trending_flat_rounded
        : (isPositive
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ReportUI.borderSideColor, width: 1),
        boxShadow: ReportUI.lightShadow,
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SizedBox(
        height: 58,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, size: 17, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: ReportTextStyles.body.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 0),
                        Text(
                          value,
                          style: ReportTextStyles.metricValueMedium.copyWith(
                            color: ReportUI.primaryTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 106,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: trendTextColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(trendIcon, size: 14, color: trendTextColor),
                        const SizedBox(width: 2),
                        Text(
                          trendText,
                          style: ReportTextStyles.label.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: trendTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _buildChartBars(chartData, color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChartBars(List<double> data, Color color) {
    if (data.isEmpty) return [];
    final normalizedData = data.length <= 6
        ? data
        : data.sublist(data.length - 6);
    final max = normalizedData.reduce((a, b) => a > b ? a : b);
    final safeMax = max == 0 ? 1.0 : max;
    const barMaxHeight = 20.0;
    const minHeight = 6.0;

    return List.generate(normalizedData.length, (i) {
      final value = normalizedData[i];
      final height = (value / safeMax * barMaxHeight).clamp(
        minHeight,
        barMaxHeight,
      );
      // Lighter on the left, darker on the right (last bar most prominent)
      final t = (i + 1) / normalizedData.length;
      final opacity = value == 0 ? 0.2 : (0.35 + t * 0.65).clamp(0.0, 1.0);
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: i == normalizedData.length - 1 ? 0 : 4,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
    });
  }

  // Helper method to get category from declutter item ID
  DeclutterCategory? _getCategoryForResellItem(ResellItem resellItem) {
    try {
      final declutterItem = widget.declutteredItems.firstWhere(
        (item) => item.id == resellItem.declutterItemId,
      );
      return declutterItem.category;
    } catch (e) {
      return null;
    }
  }

  // Build category performance widget
  Widget _buildCategoryPerformance(
    BuildContext context,
    bool isChinese,
    EnhancedResellStats stats,
  ) {
    if (stats.categoryPerformance.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            isChinese ? '暂无数据' : 'No data',
            style: ReportTextStyles.body,
          ),
        ),
      );
    }

    final sortedCategories = stats.categoryPerformance.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final currencySymbol = isChinese ? '¥' : '\$';

    String compactAmount(double value) {
      if (value >= 1000) {
        return '$currencySymbol${(value / 1000).toStringAsFixed(1)}k';
      }
      return '$currencySymbol${value.toStringAsFixed(0)}';
    }

    final rateLabel = isChinese ? '成交率' : 'STR';
    return Column(
      children: [
        ...List.generate(sortedCategories.length, (index) {
          final perf = sortedCategories[index];
          final str = perf.successRate.clamp(0, 100).toDouble();
          return Container(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            decoration: BoxDecoration(
              border: index == sortedCategories.length - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Color(0xFFEAECEF), width: 1),
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              perf.category.label(context),
                              style: ReportTextStyles.categoryTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: str / 100,
                                minHeight: 12,
                                backgroundColor: const Color(0xFFE7ECF3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.lerp(
                                        const Color(0xFF8FB0E7),
                                        const Color(0xFF1D4ED8),
                                        str / 100,
                                      ) ??
                                      const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: Color(0xFF14B8A6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${perf.successRate.toStringAsFixed(0)}% $rateLabel',
                            style: ReportTextStyles.metricMeta,
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Color(0xFFFB923C),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${perf.averageDays.toStringAsFixed(0)}${isChinese ? '天均' : 'd Avg'}',
                            style: ReportTextStyles.metricMeta,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 86,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        compactAmount(perf.revenue),
                        style: ReportTextStyles.metricValueMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isChinese ? '成交额' : 'VOLUME',
                        style: ReportTextStyles.label.copyWith(
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Build unsold items widget
  Widget _buildUnsoldItems(
    BuildContext context,
    bool isChinese,
    List<ResellItem> resellItems,
  ) {
    final now = DateTime.now();
    final categoryUnsoldCount = <DeclutterCategory, int>{};

    // Calculate unsold items by category (30+ days)
    for (final resellItem in resellItems) {
      if (resellItem.status != ResellStatus.sold) {
        final daysListed = now.difference(resellItem.createdAt).inDays;
        if (daysListed > 30) {
          final category = _getCategoryForResellItem(resellItem);
          if (category != null) {
            categoryUnsoldCount[category] =
                (categoryUnsoldCount[category] ?? 0) + 1;
          }
        }
      }
    }

    if (categoryUnsoldCount.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF5ECFB8),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              isChinese
                  ? '太棒了！没有超过30天未售出的物品'
                  : 'Great! No items unsold over 30 days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5ECFB8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by count
    final sortedCategories = categoryUnsoldCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.map((entry) {
        final category = entry.key;
        final count = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD93D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isChinese ? '$count 件' : '$count',
                  style: ReportTextStyles.statValueSmall.copyWith(
                    color: const Color(0xFFE6A100),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Build transaction insights summary
  Widget _buildTransactionInsights(
    BuildContext context,
    bool isChinese,
    List<ResellItem> resellItems,
  ) {
    final currencySymbol = isChinese ? '¥' : '\$';
    final soldItems = resellItems
        .where((item) => item.status == ResellStatus.sold)
        .toList();

    if (soldItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: ReportUI.statCardDecoration,
        child: Center(
          child: Text(
            isChinese ? '暂无成交数据' : 'No sold items yet',
            style: ReportTextStyles.sectionSubtitle,
          ),
        ),
      );
    }

    // Helper to get item title
    String getItemTitle(ResellItem item) {
      final declutterItem = widget.declutteredItems.firstWhere(
        (element) => element.id == item.declutterItemId,
        orElse: () => DeclutterItem(
          id: '',
          userId: '',
          name: isChinese ? '未知物品' : 'Unknown Item',
          category: DeclutterCategory.miscellaneous,
          status: DeclutterStatus.resell, // Added required status
          createdAt: DateTime.now(),
        ),
      );
      return declutterItem.name;
    }

    // 1. Top Sale (Highest Price)
    soldItems.sort((a, b) => (b.soldPrice ?? 0).compareTo(a.soldPrice ?? 0));
    final topSaleItem = soldItems.first;

    // 2. Fastest Flip (Shortest time to sell)
    ResellItem? fastestItem;
    int minDays = 9999;
    for (final item in soldItems) {
      if (item.soldDate != null) {
        final days = item.soldDate!.difference(item.createdAt).inDays;
        if (days < minDays) {
          minDays = days;
          fastestItem = item;
        }
      }
    }

    // 3. Best Category (Highest Revenue)
    final categoryRevenue = <DeclutterCategory, double>{};
    for (final item in soldItems) {
      if (item.soldPrice != null) {
        final category = _getCategoryForResellItem(item);
        if (category != null) {
          categoryRevenue[category] =
              (categoryRevenue[category] ?? 0) + item.soldPrice!;
        }
      }
    }
    DeclutterCategory? bestCategory;
    double maxCategoryRevenue = 0;
    categoryRevenue.forEach((category, revenue) {
      if (revenue > maxCategoryRevenue) {
        maxCategoryRevenue = revenue;
        bestCategory = category;
      }
    });

    // 4. Best Month (Highest Revenue)
    final monthRevenue = <int, double>{};
    for (final item in soldItems) {
      if (item.soldPrice != null && item.soldDate != null) {
        final month = item.soldDate!.month;
        monthRevenue[month] = (monthRevenue[month] ?? 0) + item.soldPrice!;
      }
    }
    int bestMonth = 0;
    double maxMonthRevenue = 0;
    monthRevenue.forEach((month, revenue) {
      if (revenue > maxMonthRevenue) {
        maxMonthRevenue = revenue;
        bestMonth = month;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInsightRow(
          context,
          isChinese ? '最高成交' : 'Top Sale',
          '$currencySymbol${topSaleItem.soldPrice?.toStringAsFixed(0)}',
          getItemTitle(topSaleItem),
          const Color(0xFFFFB703),
        ),
        _buildInsightRow(
          context,
          isChinese ? '最快卖出' : 'Fastest Flip',
          '$minDays ${isChinese ? '天' : 'days'}',
          fastestItem != null ? getItemTitle(fastestItem) : '-',
          const Color(0xFFFF5252),
        ),
        _buildInsightRow(
          context,
          isChinese ? '最佳品类' : 'Best Category',
          bestCategory?.label(context) ?? '-',
          '$currencySymbol${maxCategoryRevenue.toStringAsFixed(0)}',
          const Color(0xFF3B82F6),
        ),
        _buildInsightRow(
          context,
          isChinese ? '最佳月份' : 'Best Month',
          '$bestMonth ${isChinese ? '月' : 'Month'}',
          '$currencySymbol${maxMonthRevenue.toStringAsFixed(0)}',
          const Color(0xFF10B981),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildInsightRow(
    BuildContext context,
    String title,
    String value,
    String note,
    Color accent, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFEAECEF), width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ReportTextStyles.label),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: ReportTextStyles.metricValueMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: ReportTextStyles.sectionSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUnsoldInfo(BuildContext context, bool isChinese) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF111827),
      fontWeight: FontWeight.w600,
    );
    final descriptionStyle = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFF4B5563),
      height: 1.3,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isChinese ? '数据说明' : 'Data Info',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isChinese
                                ? '了解30+天未售出的统计口径'
                                : 'See what 30+ days unsold includes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF9CA3AF),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isChinese ? '统计口径' : 'What\'s included',
                  style: labelStyle,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isChinese
                        ? '上架超过30天仍未售出的物品，以及整理超过30天但尚未售出的物品都会被计入。'
                        : 'Items still unsold after 30+ days on listing, and items decluttered 30+ days ago that are not sold yet.',
                    style: descriptionStyle,
                  ),
                ),
                const SizedBox(height: 14),
                Text(isChinese ? '优化建议' : 'Tips', style: labelStyle),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFD93D).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    isChinese
                        ? '尝试适度调价、更新描述或更换转售渠道，帮助这些物品更快售出。'
                        : 'Try a small price tweak, refresh the listing, or switch channels to help these items sell faster.',
                    style: descriptionStyle?.copyWith(
                      color: const Color(0xFF8A6D1F),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(isChinese ? '知道了' : 'Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryInfo(BuildContext context, bool isChinese) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF111827),
      fontWeight: FontWeight.w600,
    );
    final descriptionStyle = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFF4B5563),
      height: 1.3,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isChinese ? '数据说明' : 'Data Info',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isChinese
                                ? '了解品类表现分析的统计口径'
                                : 'See what category performance includes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF9CA3AF),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isChinese ? '统计口径' : 'What\'s included',
                  style: labelStyle,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isChinese
                        ? '展示各品类的关键表现指标，帮助你了解哪些品类转卖效果最好。'
                        : 'Shows key performance metrics for each category to identify which categories perform best for resale.',
                    style: descriptionStyle,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isChinese ? '指标说明' : 'Metrics explained',
                  style: labelStyle,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese
                            ? '• 成交金额：该品类已售出物品的总价值'
                            : '• Revenue: Total value of sold items in this category',
                        style: descriptionStyle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isChinese
                            ? '• 成交率：已售出物品数 ÷ 总物品数 × 100%'
                            : '• Sold Rate: (Sold items ÷ Total items) × 100%',
                        style: descriptionStyle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isChinese
                            ? '• 平均售出天数：从整理到售出的平均时长'
                            : '• Avg Days to Sell: Average time from declutter to sold',
                        style: descriptionStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(isChinese ? '优化建议' : 'Tips', style: labelStyle),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFD93D).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    isChinese
                        ? '专注于表现好的品类，考虑优先整理类似物品以提升整体转卖收益。'
                        : 'Focus on high-performing categories and consider prioritizing similar items to maximize resale returns.',
                    style: descriptionStyle?.copyWith(
                      color: const Color(0xFF8A6D1F),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(isChinese ? '知道了' : 'Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTrendInfo(BuildContext context, bool isChinese) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF111827),
      fontWeight: FontWeight.w600,
    );
    final descriptionStyle = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFF4B5563),
      height: 1.3,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isChinese ? '数据说明' : 'Data Info',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isChinese
                                ? '了解趋势分析的统计口径'
                                : 'See what trend analysis includes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF9CA3AF),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isChinese ? '统计口径' : 'What\'s included',
                  style: labelStyle,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isChinese
                        ? '显示转卖表现随时间的变化趋势，可切换不同指标查看。'
                        : 'Shows how your resale performance changes over time. Switch between different metrics to view trends.',
                    style: descriptionStyle,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isChinese ? '指标说明' : 'Metrics explained',
                  style: labelStyle,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese
                            ? '• 物品数量：每月新增的转卖物品总数'
                            : '• Item Count: Total number of new resale items added each month',
                        style: descriptionStyle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isChinese
                            ? '• 收入：每月已售出物品的总收入'
                            : '• Revenue: Total income from sold items each month',
                        style: descriptionStyle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isChinese
                            ? '• 成交率：每月售出物品数 ÷ 总物品数 × 100%'
                            : '• Sold Rate: (Monthly sold items ÷ Total items) × 100%',
                        style: descriptionStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(isChinese ? '优化建议' : 'Tips', style: labelStyle),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFD93D).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    isChinese
                        ? '留意趋势变化，在表现下滑时及时调整策略，保持稳定的转卖效果。'
                        : 'Monitor trends and adjust your strategy when performance dips to maintain consistent resale results.',
                    style: descriptionStyle?.copyWith(
                      color: const Color(0xFF8A6D1F),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(isChinese ? '知道了' : 'Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChartDataPoint {
  final String label;
  final double revenue;
  final double volume;

  _ChartDataPoint({
    required this.label,
    required this.revenue,
    required this.volume,
  });
}

class _DualTrendChartPainter extends CustomPainter {
  final List<_ChartDataPoint> dataPoints;
  final bool isChinese;

  static const _chartBlue = Color(0xFF2563EB);
  static const _chartTeal = Color(0xFF14B8A6);

  _DualTrendChartPainter({required this.dataPoints, required this.isChinese});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paintRevenue = Paint()
      ..color = _chartBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintVolume = Paint()
      ..color = _chartTeal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaintRevenue = Paint()
      ..color = _chartBlue
      ..style = PaintingStyle.fill;

    final dotPaintVolume = Paint()
      ..color = _chartTeal
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;

    final dottedGridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Layout constants
    const bottomPadding = 30.0;
    const topPadding = 20.0;
    const leftPadding = 10.0;
    const rightPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Draw Grid Lines (Horizontal)
    // 4 grid lines
    for (int i = 0; i <= 3; i++) {
      final y = topPadding + (chartHeight * i / 3);

      // Draw dashed line
      _drawDashedLine(
        canvas,
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        dottedGridPaint,
      );
    }

    // Determine Min/Max for Scaling
    // We normalize both Revenue and Volume to 0.0 - 1.0 range for the chart
    double maxRevenue = 0;
    double maxVolume = 0;

    for (var point in dataPoints) {
      if (point.revenue > maxRevenue) maxRevenue = point.revenue;
      if (point.volume > maxVolume) maxVolume = point.volume;
    }

    // Avoid division by zero
    if (maxRevenue == 0) maxRevenue = 100;
    if (maxVolume == 0) maxVolume = 10;

    // Add some headroom
    maxRevenue *= 1.2;
    maxVolume *= 1.2;

    // Calculate Points
    final revenuePoints = <Offset>[];
    final volumePoints = <Offset>[];

    final interval = chartWidth / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = leftPadding + (i * interval);

      // Revenue Y
      final yRevenue =
          topPadding + chartHeight * (1 - (dataPoints[i].revenue / maxRevenue));
      revenuePoints.add(Offset(x, yRevenue));

      // Volume Y
      final yVolume =
          topPadding + chartHeight * (1 - (dataPoints[i].volume / maxVolume));
      volumePoints.add(Offset(x, yVolume));

      // Draw X-Axis Label
      textPainter.text = TextSpan(
        text: dataPoints[i].label,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }

    // Draw Smooth Curves
    _drawSmoothPath(canvas, revenuePoints, paintRevenue);
    _drawSmoothDashedPath(canvas, volumePoints, paintVolume);

    // Draw dots on top if not too many points
    // if (dataPoints.length <= 12) {
    //   for (var p in revenuePoints) {
    //     canvas.drawCircle(p, 4, Colors.white as Paint); // white bg
    //     canvas.drawCircle(p, 4, Paint()..color = Colors.white);
    //     canvas.drawCircle(p, 2.5, dotPaintRevenue);
    //   }
    //   for (var p in volumePoints) {
    //      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
    //      canvas.drawCircle(p, 2.5, dotPaintVolume);
    //   }
    // }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(startX + dashWidth, p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  void _drawSmoothPath(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      // Cubic bezier for smoothness
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  void _drawSmoothDashedPath(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Draw dashed path manually or using a library logic
    // Since native canvas doesn't support dashed path easily, we can simulate or just draw solid for now.
    // The design shows dotted/dashed.
    // Let's iterate the path metrics to draw dashes.

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      var distance = 0.0;
      const dashWidth = 4.0;
      const dashSpace = 4.0;

      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
