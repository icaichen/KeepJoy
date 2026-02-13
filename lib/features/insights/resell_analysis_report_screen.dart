import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/widgets/auto_scale_text.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';

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

enum CategoryMetric {
  revenue,
  successRate,
  avgListedDays;

  String label(bool isChinese) {
    switch (this) {
      case CategoryMetric.revenue:
        return isChinese ? '交易金额' : 'Revenue';
      case CategoryMetric.successRate:
        return isChinese ? '成交率' : 'Sold Rate';
      case CategoryMetric.avgListedDays:
        return isChinese ? '平均售出天数' : 'Avg Days to Sell';
    }
  }
}

class _ResellAnalysisReportScreenState
    extends State<ResellAnalysisReportScreen> {
  TrendMetric _selectedMetric = TrendMetric.soldItems;
  CategoryMetric _selectedCategoryMetric = CategoryMetric.revenue;
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

    // Average listed days (sold: created->sold, unsold: created->now)
    final nowTime = DateTime.now();
    final avgDays = widget.resellItems.isEmpty
        ? 0.0
        : widget.resellItems
                  .map((item) {
                    final end =
                        (item.status == ResellStatus.sold &&
                            item.soldDate != null)
                        ? item.soldDate!
                        : nowTime;
                    return end.difference(item.createdAt).inDays;
                  })
                  .fold<int>(0, (a, b) => a + b) /
              widget.resellItems.length;

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
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  label: isChinese ? '平均交易价' : 'Avg Price',
                                  value:
                                      '$currencySymbol${avgPrice.toStringAsFixed(0)}',
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
                                  label: isChinese ? '成交率' : 'Sold Rate',
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
                                  value:
                                      '$currencySymbol${totalRevenue.toStringAsFixed(0)}',
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: const Color(0xFFFF9AA2),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Category Performance Analysis
                          Container(
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
                                _buildCategoryPerformance(context, isChinese),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Trend Analysis Section
                          Container(
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

                          const SizedBox(height: 24),

                          // 30+ Days Unsold Items
                          Container(
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

                          const SizedBox(height: 24),

                          // 交易洞察 Summary Section
                          Container(
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
                                  isChinese ? '交易洞察' : 'Transaction Insights',
                                  style: ReportTextStyles.sectionHeader,
                                ),
                                const SizedBox(height: 20),
                                _buildTransactionInsights(context, isChinese),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
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
  Widget _buildCategoryPerformance(BuildContext context, bool isChinese) {
    // Calculate category data for ALL categories
    final categoryData = <DeclutterCategory, Map<String, dynamic>>{};

    // Initialize all categories with zeros
    for (final category in DeclutterCategory.values) {
      categoryData[category] = {
        'totalRevenue': 0.0,
        'totalCount': 0,
        'soldCount': 0,
        'totalListedDays': 0.0,
      };
    }

    // Fill in actual data
    for (final resellItem in widget.resellItems) {
      final category = _getCategoryForResellItem(resellItem);
      if (category == null) continue;

      categoryData[category]!['totalCount'] += 1;

      // Days listed: sold uses售出日期，未售用当前日期
      final listedDays =
          (resellItem.status == ResellStatus.sold &&
              resellItem.soldDate != null)
          ? resellItem.soldDate!.difference(resellItem.createdAt).inDays
          : DateTime.now().difference(resellItem.createdAt).inDays;
      categoryData[category]!['totalListedDays'] += listedDays;

      if (resellItem.status == ResellStatus.sold &&
          resellItem.soldPrice != null) {
        categoryData[category]!['soldCount'] += 1;
        categoryData[category]!['totalRevenue'] += resellItem.soldPrice!;
      }
    }

    // Find max values for scaling
    double maxRevenue = 0;
    double maxAvgDays = 0;
    for (final data in categoryData.values) {
      if (data['totalRevenue'] > maxRevenue) {
        maxRevenue = data['totalRevenue'];
      }
      final totalCount = data['totalCount'] as int;
      if (totalCount > 0) {
        final avgDays = (data['totalListedDays'] as double) / totalCount;
        if (avgDays > maxAvgDays) {
          maxAvgDays = avgDays;
        }
      }
    }
    // Ensure maxRevenue is at least 1 to avoid division by zero
    if (maxRevenue == 0) maxRevenue = 1;
    if (maxAvgDays == 0) maxAvgDays = 1;

    // Filter out categories with 0 items for cleaner view
    final activeCategories = DeclutterCategory.values.where((c) {
      return (categoryData[c]!['totalCount'] as int) > 0;
    }).toList();

    // Sort accordingly
    if (_selectedCategoryMetric == CategoryMetric.revenue) {
      activeCategories.sort(
        (a, b) => (categoryData[b]!['totalRevenue'] as double).compareTo(
          categoryData[a]!['totalRevenue'] as double,
        ),
      );
    } else if (_selectedCategoryMetric == CategoryMetric.successRate) {
      activeCategories.sort((a, b) {
        final countA = categoryData[a]!['totalCount'] as int;
        final soldA = categoryData[a]!['soldCount'] as int;
        final rateA = countA > 0 ? soldA / countA : 0.0;

        final countB = categoryData[b]!['totalCount'] as int;
        final soldB = categoryData[b]!['soldCount'] as int;
        final rateB = countB > 0 ? soldB / countB : 0.0;
        return rateB.compareTo(rateA);
      });
    } else {
      // Average days
      activeCategories.sort((a, b) {
        final countA = categoryData[a]!['totalCount'] as int;
        final daysA = categoryData[a]!['totalListedDays'] as double;
        final avgA = countA > 0 ? daysA / countA : 0.0;

        final countB = categoryData[b]!['totalCount'] as int;
        final daysB = categoryData[b]!['totalListedDays'] as double;
        final avgB = countB > 0 ? daysB / countB : 0.0;
        return avgA.compareTo(avgB); // Fast to slow
      });
    }

    return Column(
      children: [
        // Metric selector (Matching Trend Analysis style)
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                isChinese ? '指标' : 'Metric',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CategoryMetric>(
                    value: _selectedCategoryMetric,
                    isExpanded: true,
                    isDense: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6B7280),
                    ),
                    dropdownColor: Colors.white,
                    focusColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategoryMetric = value;
                        });
                      }
                    },
                    items: CategoryMetric.values
                        .map(
                          (metric) => DropdownMenuItem<CategoryMetric>(
                            value: metric,
                            child: Text(
                              metric.label(isChinese),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
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
        const SizedBox(height: 8),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeCategories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = activeCategories[index];
            final data = categoryData[category]!;
            final revenue = data['totalRevenue'] as double;
            final totalCount = data['totalCount'] as int;
            final soldCount = data['soldCount'] as int;
            final successRate = totalCount > 0
                ? (soldCount / totalCount * 100)
                : 0.0;
            final avgDays = totalCount > 0
                ? (data['totalListedDays'] as double) / totalCount
                : 0.0;

            // Calculate bar width based on selected metric
            double barValue;
            String valueText;
            List<Color> barColors;

            if (_selectedCategoryMetric == CategoryMetric.revenue) {
              barValue = maxRevenue > 0 ? revenue / maxRevenue : 0;
              valueText = '$_currencySymbol${revenue.toStringAsFixed(0)}';
              barColors = const [Color(0xFFFFD93D), Color(0xFFFFB703)];
            } else if (_selectedCategoryMetric == CategoryMetric.successRate) {
              barValue = successRate / 100;
              valueText = '${successRate.toStringAsFixed(0)}%';
              barColors = const [Color(0xFF5ECFB8), Color(0xFF34D399)];
            } else {
              barValue = (avgDays / maxAvgDays).clamp(0.0, 1.0);
              valueText = isChinese
                  ? '${avgDays.toStringAsFixed(0)} 天'
                  : '${avgDays.toStringAsFixed(0)} d';
              barColors = const [Color(0xFF89CFF0), Color(0xFF60A5FA)];
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3, // Thinner accent
                          height: 14,
                          decoration: BoxDecoration(
                            color: barColors[0],
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.label(context),
                          style: ReportTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13, // Slightly smaller text
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      valueText,
                      style: ReportTextStyles.statValueSmall.copyWith(
                        fontSize: 13, // Matches label size
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Tighter spacing
                Stack(
                  children: [
                    Container(
                      height: 5, // Thinner bar
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: barValue.clamp(0.05, 1.0),
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: barColors),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
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

  // Build transaction insights summary
  Widget _buildTransactionInsights(BuildContext context, bool isChinese) {
    final soldItems = widget.resellItems
        .where((item) => item.status == ResellStatus.sold)
        .toList();
    final now = DateTime.now();
    final unsoldOver30 = widget.resellItems.where((item) {
      if (item.status == ResellStatus.sold) return false;
      return now.difference(item.createdAt).inDays > 30;
    }).length;

    if (soldItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            isChinese ? '暂无成交数据' : 'No sold items yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ),
      );
    }

    // Calculate insights
    // 1. 成交表现 (Transaction Performance) - success rate
    final successRate = widget.resellItems.isEmpty
        ? 0.0
        : (soldItems.length / widget.resellItems.length * 100);

    // 2. 优势品类 (Best Category) - category with highest revenue
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
    double bestRevenue = 0;
    categoryRevenue.forEach((category, revenue) {
      if (revenue > bestRevenue) {
        bestRevenue = revenue;
        bestCategory = category;
      }
    });

    // 3. 最快成交 (Fastest Sale) - shortest days to sell
    int? fastestDays;
    for (final item in soldItems) {
      if (item.soldDate != null) {
        final days = item.soldDate!.difference(item.createdAt).inDays;
        if (fastestDays == null || days < fastestDays) {
          fastestDays = days;
        }
      }
    }

    // 4. 最高价格 (Highest Price)
    double highestPrice = 0;
    for (final item in soldItems) {
      if (item.soldPrice != null && item.soldPrice! > highestPrice) {
        highestPrice = item.soldPrice!;
      }
    }

    // Bento Box Grid Layout
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                context,
                title: isChinese ? '成交表现' : 'Sold Rate',
                value: '${successRate.toStringAsFixed(0)}%',
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF10B981),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE0F2F1), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                context,
                title: isChinese ? '优势品类' : 'Best Category',
                value: bestCategory?.label(context) ?? '-',
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFFFB703),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8E1), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                context,
                title: isChinese ? '最快成交' : 'Fastest Sale',
                value: fastestDays != null
                    ? '$fastestDays ${isChinese ? '天' : 'days'}'
                    : '-',
                icon: Icons.flash_on_rounded,
                iconColor: const Color(0xFFFF9AA2), // Soft Red
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEBEE), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                context,
                title: isChinese ? '最高价格' : 'Top Price',
                value: highestPrice > 0
                    ? '$_currencySymbol${highestPrice.toStringAsFixed(0)}'
                    : '-',
                icon: Icons.attach_money_rounded,
                iconColor: const Color(0xFF5ECFB8), // Mint
                gradient: const LinearGradient(
                  colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),

        if (unsoldOver30 > 0) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7E5), Color(0xFFFFFDF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD93D).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD93D).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChinese ? '滞销提醒' : 'Unsold Alert',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unsoldOver30 >= 5
                            ? (isChinese
                                  ? '有 $unsoldOver30 件物品已超过30天未售出，建议集中优化。'
                                  : 'You have $unsoldOver30 items unsold for 30+ days. Consider optimizing.')
                            : (isChinese
                                  ? '$unsoldOver30 件物品超过30天未售出，试试小幅调价。'
                                  : '$unsoldOver30 item(s) unsold for 30+ days. Try a small price drop.'),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: const Color(0xFF92400E).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBentoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const Spacer(),
              // Optional: Add trend arrow or indicator? Kept simple for now.
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: ReportTextStyles.statValueLarge.copyWith(fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(title, style: ReportTextStyles.sectionSubtitle),
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

  // Helper method to build insight row

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          AutoScaleText(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          AutoScaleText(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 21,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateTrendData() {
    final now = DateTime.now();
    final monthlyData = <int, List<double>>{};

    // Initialize all 12 months with empty lists
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = [];
    }

    // Group data by month (year to date - January to current month)
    for (final item in widget.resellItems) {
      if (item.status != ResellStatus.sold || item.soldDate == null) continue;
      // Only include items sold this year
      if (item.soldDate!.year == now.year) {
        final month = item.soldDate!.month; // 1-12
        switch (_selectedMetric) {
          case TrendMetric.soldItems:
            monthlyData[month]!.add(1);
            break;
          case TrendMetric.resellValue:
            if (item.soldPrice != null) {
              monthlyData[month]!.add(item.soldPrice!);
            }
            break;
        }
      }
    }

    // Calculate aggregate values for all 12 months
    final result = <int, double>{};
    monthlyData.forEach((month, values) {
      if (values.isNotEmpty) {
        if (_selectedMetric == TrendMetric.soldItems) {
          result[month] = values.length.toDouble(); // Total count
        } else {
          result[month] = values.reduce((a, b) => a + b); // Total value
        }
      } else {
        // Set zero for months with no data
        result[month] = 0.0;
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
