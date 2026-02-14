import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/widgets/auto_scale_text.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';
import 'package:keepjoy_app/features/insights/unified/models/enhanced_report_models.dart';

enum TrendMetric {
  soldItems('已售物品', 'Sold Items'),
  resellValue('二手收益', 'Resale Earnings');

  const TrendMetric(this.chinese, this.english);
  final String chinese;
  final String english;

  String label(bool isChinese) => isChinese ? chinese : english;
}

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
  TrendMetric _selectedMetric = TrendMetric.soldItems;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTrendSummary(
    BuildContext context,
    bool isChinese,
    Map<int, double> trendData,
  ) {
    final now = DateTime.now();
    final soldThisYear = widget.resellItems
        .where(
          (item) =>
              item.status == ResellStatus.sold &&
              item.createdAt.year == now.year,
        )
        .length;
    final monthsElapsed = now.month;
    final avgPerMonth = monthsElapsed > 0
        ? (soldThisYear / monthsElapsed)
        : 0.0;

    // Compute trend: compare recent 3 months vs previous 3 months
    // Trend: this month vs last month (by sold date)
    final currentMonthValue = trendData[now.month] ?? 0.0;
    final prevMonthValue = now.month > 1
        ? (trendData[now.month - 1] ?? 0.0)
        : 0.0;
    final changePercent = prevMonthValue > 0
        ? ((currentMonthValue - prevMonthValue) / prevMonthValue) * 100
        : (currentMonthValue > 0 ? 100.0 : 0.0);
    final trendUp = changePercent >= 0;

    Widget pill(String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: ReportUI.statCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ReportTextStyles.label),
              const SizedBox(height: 6),
              Text(
                value,
                style: ReportTextStyles.statValueSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ReportUI.statCardDecoration,
      child: Row(
        children: [
          pill(isChinese ? '已售件数' : 'Sold Items', soldThisYear.toString()),
          const SizedBox(width: 12),
          pill(
            isChinese ? '月均售出' : 'Avg / Month',
            avgPerMonth.toStringAsFixed(1),
          ),
          const SizedBox(width: 12),
          pill(
            isChinese ? '趋势' : 'Trend',
            trendUp
                ? '+${changePercent.abs().toStringAsFixed(changePercent.abs() >= 10 ? 0 : 1)}%'
                : '-${changePercent.abs().toStringAsFixed(changePercent.abs() >= 10 ? 0 : 1)}%',
          ),
        ],
      ),
    );
  }

  String get _currencySymbol {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode.toLowerCase().startsWith('zh');
    return isZh ? '¥' : '\$';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final responsive = context.responsive;
    final horizontalPadding = responsive.horizontalPadding;
    final headerHeight = responsive.totalTwoLineHeaderHeight + 12;
    final topPadding = responsive.safeAreaPadding.top;
    final currencySymbol = isChinese ? '¥' : '\$';

    // Calculate metrics using EnhancedResellStats
    // 1. Lifetime stats for total counters
    final lifetimeStats = EnhancedResellStats.fromItems(
      widget.resellItems,
      widget.declutteredItems,
    );

    // 2. Year stats for trends/charts (to avoid mixing years in Jan/Feb buckets)
    final now = DateTime.now();
    final thisYearItems =
        widget.resellItems.where((item) {
          // Logic matching EnhancedResellStats grouping
          final date = item.soldDate ?? item.createdAt;
          return date.year == now.year;
        }).toList();

    final yearStats = EnhancedResellStats.fromItems(
      thisYearItems,
      widget.declutteredItems,
    );

    // 3. Hybrid stats for display
    final stats = EnhancedResellStats(
      totalItems: lifetimeStats.totalItems,
      soldCount: lifetimeStats.soldCount,
      listingCount: lifetimeStats.listingCount,
      toSellCount: lifetimeStats.toSellCount,
      totalRevenue: lifetimeStats.totalRevenue,
      successRate: lifetimeStats.successRate,
      averageSoldPrice: lifetimeStats.averageSoldPrice,
      averageListedDays: lifetimeStats.averageListedDays,
      // Use year stats for monthly distributions (charts)
      monthlyRevenue: yearStats.monthlyRevenue,
      monthlySoldCount: yearStats.monthlySoldCount,
      categoryPerformance: lifetimeStats.categoryPerformance,
      platformDistribution: lifetimeStats.platformDistribution,
      trendAnalysis: yearStats.trendAnalysis,
      topSellingItems: lifetimeStats.topSellingItems,
      monthlyComparison: yearStats.monthlyComparison,
    );

    // Keep soldItems for helper methods
    final soldItems = widget.resellItems
        .where((item) => item.status == ResellStatus.sold)
        .toList();

    // Prepare trend data
    final trendData =
        _selectedMetric == TrendMetric.soldItems
            ? stats.monthlySoldCount.map((k, v) => MapEntry(k, v.toDouble()))
            : stats.monthlyRevenue;
    final pageName = isChinese ? '二手洞察' : 'Resale Insights';

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
                        Color(0xFFFFD93D), // Yellow
                        Color(0xFFFFF9E6), // Light yellow
                        Color(0xFFF5F5F7),
                      ],
                      stops: [0.0, 0.25, 0.45],
                    ),
                  ),
                ),
                // Content on top
                Column(
                  children: [
                    // Top spacing + title
                    SizedBox(
                      height: headerHeight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: topPadding + 28,
                          bottom: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Large title on the left
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  pageName,
                                  style: ReportTextStyles.screenTitle,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.dashboardResellReportSubtitle,
                                  style: ReportTextStyles.screenSubtitle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        0,
                      ),
                      child: Column(
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
                            padding: const EdgeInsets.all(20),
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
                                            style:
                                                ReportTextStyles.sectionHeader,
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
                                      onPressed: () =>
                                          _showCategoryInfo(context, isChinese),
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
                                const SizedBox(height: 24),
                                _buildCategoryPerformance(
                                  context,
                                  isChinese,
                                  EnhancedResellStats.fromItems(
                                    widget.resellItems,
                                    widget.declutteredItems,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: ReportUI.sectionGap),

                          // Trend Analysis Section
                          Container(
                            decoration: ReportUI.cardDecoration,
                            padding: const EdgeInsets.all(20),
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
                                            style:
                                                ReportTextStyles.sectionHeader,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isChinese
                                                ? '转卖表现随时间的变化趋势'
                                                : 'Resale performance over time',
                                            style: ReportTextStyles
                                                .sectionSubtitle,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _showTrendInfo(context, isChinese),
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
                                const SizedBox(height: 16),

                                // Metric selector
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        isChinese ? '指标' : 'Metric',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: const Color(0xFF6B7280),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<TrendMetric>(
                                            value: _selectedMetric,
                                            isExpanded: true,
                                            isDense: true,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Color(0xFF6B7280),
                                            ),
                                            dropdownColor: Colors.white,
                                            focusColor: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _selectedMetric = value;
                                                });
                                              }
                                            },
                                            items: TrendMetric.values
                                                .map(
                                                  (metric) =>
                                                      DropdownMenuItem<
                                                        TrendMetric
                                                      >(
                                                        value: metric,
                                                        child: Text(
                                                          metric.label(
                                                            isChinese,
                                                          ),
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    const Color(
                                                                      0xFF111827,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Chart (always show, even with no data)
                                ClipRect(
                                  child: SizedBox(
                                    height: 250,
                                    width: double.infinity,
                                    child: CustomPaint(
                                      size: const Size(double.infinity, 250),
                                      painter: _TrendChartPainter(
                                        trendData: trendData,
                                        selectedMetric: _selectedMetric,
                                        isChinese: isChinese,
                                        currencySymbol: _currencySymbol,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTrendSummary(
                                  context,
                                  isChinese,
                                  trendData,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: ReportUI.sectionGap),

                          // 30+ Days Unsold Items
                          Container(
                            decoration: ReportUI.cardDecoration,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            style:
                                                ReportTextStyles.sectionHeader,
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
                                      onPressed: () =>
                                          _showUnsoldInfo(context, isChinese),
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
                                const SizedBox(height: 24),
                                _buildUnsoldItems(context, isChinese),
                              ],
                            ),
                          ),

                          const SizedBox(height: ReportUI.sectionGap),

                          // 交易洞察 Summary Section
                          Container(
                            decoration: ReportUI.cardDecoration,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isChinese ? '交易洞察' : 'Transaction Insights',
                                  style: ReportTextStyles.sectionHeader,
                                ),
                                const SizedBox(height: 20),
                                _buildTransactionInsights(context, isChinese),
                              ],
                            ),
                          ),

                          const SizedBox(height: ReportUI.sectionGap),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Real header that appears when scrolling is complete
          // Real header - only this rebuilds on scroll
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
                final scrollProgress = (scrollOffset / headerHeight).clamp(
                  0.0,
                  1.0,
                );
                final realHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;
                return IgnorePointer(
                  ignoring: realHeaderOpacity < 0.5,
                  child: Opacity(opacity: realHeaderOpacity, child: child),
                );
              },
              child: Container(
                height: responsive.collapsedHeaderHeight,
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
                          style: ReportTextStyles.sectionHeader.copyWith(
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
    final revenueData =
        months.map((m) => stats.monthlyRevenue[m] ?? 0.0).toList();
    final revenueTrend = stats.trendAnalysis.changePercent;

    // 2. Sell-Through Data (Sold Count)
    final soldData =
        months.map((m) => (stats.monthlySoldCount[m] ?? 0).toDouble()).toList();
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
          .where(
            (item) => item.soldDate != null && item.soldDate!.month == m,
          )
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
          color: const Color(0xFF6366F1), // Indigo/Blue
          trend: revenueTrend,
          chartData: revenueData,
        ),
        const SizedBox(height: 12),
        _buildNewStyleMetricCard(
          context,
          title: isChinese ? '售出率' : 'Sell-Through Rate',
          value: '${stats.successRate.toStringAsFixed(0)}%',
          icon: Icons.speed_rounded,
          color: const Color(0xFF10B981), // Emerald/Green
          trend: soldTrend,
          chartData: soldData,
        ),
        const SizedBox(height: 12),
        _buildNewStyleMetricCard(
          context,
          title: isChinese ? '平均售价' : 'Avg. Price',
          value: '$currencySymbol${stats.averageSoldPrice.toStringAsFixed(2)}',
          icon: Icons.local_offer_rounded,
          color: const Color(0xFF8B5CF6), // Violet/Purple
          trend: avgPriceTrend,
          chartData: avgPriceData,
        ),
        const SizedBox(height: 12),
        _buildNewStyleMetricCard(
          context,
          title: isChinese ? '售出天数' : 'Days to Sell',
          value:
              '${stats.averageListedDays.toStringAsFixed(0)} ${isChinese ? '天' : 'Days'}',
          icon: Icons.hourglass_empty_rounded,
          color: const Color(0xFFF97316), // Orange
          trend: daysTrend,
          chartData: daysData,
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
  }) {
    final trendText = '${trend.abs().toStringAsFixed(0)}%';
    Color badgeColor;
    Color badgeTextColor;
    IconData badgeIcon;

    if (trend.abs() < 1) {
      badgeColor = const Color(0xFFF3F4F6);
      badgeTextColor = const Color(0xFF6B7280);
      badgeIcon = Icons.remove;
    } else if (trend > 0) {
      badgeColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF10B981);
      badgeIcon = Icons.trending_up_rounded;
    } else {
      badgeColor = const Color(0xFFFEF2F2);
      badgeTextColor = const Color(0xFFEF4444);
      badgeIcon = Icons.trending_down_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),

          // Title & Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Right Side: Badge & Chart
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Trend Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badgeIcon != Icons.remove)
                      Icon(badgeIcon, size: 14, color: badgeTextColor),
                    if (badgeIcon != Icons.remove) const SizedBox(width: 2),
                    Text(
                      trendText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Mini Chart
              SizedBox(
                height: 24,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildChartBars(chartData, color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars(List<double> data, Color color) {
    if (data.isEmpty) return [];
    final max = data.reduce((a, b) => a > b ? a : b);
    final safeMax = max == 0 ? 1.0 : max;

    return data.map((value) {
      final height = (value / safeMax * 24).clamp(4.0, 24.0);
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Container(
          width: 6,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(
              value == 0 ? 0.2 : (0.4 + (value / safeMax) * 0.6).clamp(0.0, 1.0),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }).toList();
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
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    // Calculate max volume for scaling
    int maxVolume = 0;
    for (final perf in sortedCategories) {
      if (perf.totalListed > maxVolume) maxVolume = perf.totalListed;
    }
    if (maxVolume == 0) maxVolume = 1;

    return Column(
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  isChinese ? '品类 & 量级' : 'CATEGORY & VOLUME',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  isChinese ? '成交率' : 'STR %',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  isChinese ? '平均天数' : 'AVG DAYS',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        const SizedBox(height: 16),

        // List Items
        ...sortedCategories.map((perf) {
          final volumeRatio = perf.totalListed / maxVolume;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top
              children: [
                // Category & Volume
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese
                            ? perf.category.chinese
                            : perf.category.english,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Volume Bar
                      Container(
                        height: 6,
                        width: 100, // Fixed width base for the bar container
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: volumeRatio.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF89CFF0,
                              ), // Light Blue to match app theme
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // STR %
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    height: 40, // Match height of left column roughly
                    child: Text(
                      '${perf.successRate.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),

                // AVG DAYS
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerRight,
                    height: 40, // Match height of left column roughly
                    child: Text(
                      perf.averageListedDays.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
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
  Widget _buildUnsoldItems(BuildContext context, bool isChinese) {
    final now = DateTime.now();
    final categoryUnsoldCount = <DeclutterCategory, int>{};

    // Calculate unsold items by category (30+ days)
    for (final resellItem in widget.resellItems) {
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

  // Build transaction insights summary (Redesigned as Highlights)
  Widget _buildTransactionInsights(BuildContext context, bool isChinese) {
    final currencySymbol = isChinese ? '¥' : '\$';
    final soldItems = widget.resellItems
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
      children: [
        _buildInsightHero(
          title: isChinese ? '最高成交' : 'Top Sale',
          value: '$currencySymbol${topSaleItem.soldPrice?.toStringAsFixed(0)}',
          subtitle: getItemTitle(topSaleItem),
          icon: Icons.emoji_events_rounded,
          iconColor: const Color(0xFFFFB703),
        ),
        const SizedBox(height: 12),
        _buildInsightMiniRow(
          title: isChinese ? '最快卖出' : 'Fastest Flip',
          value: '$minDays ${isChinese ? '天' : 'days'}',
          subtitle: fastestItem != null ? getItemTitle(fastestItem) : '-',
          icon: Icons.flash_on_rounded,
          iconColor: const Color(0xFFFF5252),
        ),
        const SizedBox(height: 8),
        _buildInsightMiniRow(
          title: isChinese ? '最佳品类' : 'Best Category',
          value: bestCategory?.label(context) ?? '-',
          subtitle: '$currencySymbol${maxCategoryRevenue.toStringAsFixed(0)}',
          icon: Icons.category_rounded,
          iconColor: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 8),
        _buildInsightMiniRow(
          title: isChinese ? '最佳月份' : 'Best Month',
          value: '$bestMonth ${isChinese ? '月' : 'Month'}',
          subtitle: '$currencySymbol${maxMonthRevenue.toStringAsFixed(0)}',
          icon: Icons.calendar_month_rounded,
          iconColor: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildInsightHero({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: ReportUI.statCardDecoration,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ReportTextStyles.label),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: ReportTextStyles.statValueLarge.copyWith(fontSize: 26),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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

  Widget _buildInsightMiniRow({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ReportUI.statCardDecoration,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: ReportTextStyles.label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: ReportTextStyles.statValueSmall,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: ReportTextStyles.sectionSubtitle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
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

// Trend chart painter
class _TrendChartPainter extends CustomPainter {
  final Map<int, double> trendData;
  final TrendMetric selectedMetric;
  final bool isChinese;
  final String currencySymbol;

  _TrendChartPainter({
    required this.trendData,
    required this.selectedMetric,
    required this.isChinese,
    required this.currencySymbol,
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

    final axisPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right, // Right-align Y-axis labels
    );

    String formatLabel(double value) {
      if (selectedMetric == TrendMetric.resellValue) {
        return '$currencySymbol${value.toStringAsFixed(0)}';
      }
      return value.toStringAsFixed(0);
    }

    // Find max value first (ensure at least 1 to avoid division by zero)
    double maxValue = trendData.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) {
      maxValue = 5; // default minimum
    } else {
      maxValue = maxValue * 1.25;
    }

    // Calculate required left padding based on max label width
    textPainter.text = TextSpan(
      text: formatLabel(maxValue),
      style: const TextStyle(
        color: Color(0xFF9E9E9E),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    final maxLabelWidth = textPainter.width;
    final leftPadding = maxLabelWidth + 12.0; // Label width + gap

    // Dimensions with space for Y-axis labels
    const rightPadding = 20.0;
    const topPadding = 20.0;
    const bottomPadding = 40.0;
    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

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

      // Y-axis labels - corrected to show values from max at top to 0 at bottom
      final value = maxValue * (5 - i) / 5;
      textPainter.text = TextSpan(
        text: formatLabel(value),
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Prepare data points for all 12 months (1-12, January to December)
    final points = <Offset>[];
    final labels = <String>[];

    for (int month = 1; month <= 12; month++) {
      final value = trendData[month] ?? 0.0;

      final x = leftPadding + (chartWidth * (month - 1) / 11);
      final normalizedValue = value / maxValue;
      final y = topPadding + (chartHeight * (1 - normalizedValue));

      points.add(Offset(x, y));
      labels.add('$month');
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
