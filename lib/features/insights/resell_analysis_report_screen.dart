import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/widgets/auto_scale_text.dart';

enum TrendMetric {
  soldItems('已售物品', 'Sold Items'),
  listedDays('平均上架天数', 'Avg Listed Days'),
  resellValue('二手收益', 'Resell Value');

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
  successRate;

  String label(bool isChinese) {
    switch (this) {
      case CategoryMetric.revenue:
        return isChinese ? '交易金额' : 'Revenue';
      case CategoryMetric.successRate:
        return isChinese ? '成交率' : 'Success Rate';
    }
  }
}

class _ResellAnalysisReportScreenState
    extends State<ResellAnalysisReportScreen> {
  TrendMetric _selectedMetric = TrendMetric.soldItems;
  CategoryMetric _selectedCategoryMetric = CategoryMetric.revenue;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

    final topPadding = MediaQuery.of(context).padding.top;
    final pageName = isChinese ? '二手洞察' : 'Resale Insights';

    // Calculate scroll-based animations
    const titleAreaHeight = 120.0;
    final scrollProgress = (_scrollOffset / titleAreaHeight).clamp(0.0, 1.0);
    final titleOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
    final realHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;

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
                      stops: [0.0, 0.15, 0.33],
                    ),
                  ),
                ),
                // Content on top
                Column(
                  children: [
                    // Top spacing + title
                    SizedBox(
                      height: 120,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 16,
                          top: topPadding + 12,
                        ),
                        child: Opacity(
                          opacity: titleOpacity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Large title on the left
                              Text(
                                pageName,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
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
                                          label: isChinese
                                              ? '平均交易价'
                                              : 'Avg Price',
                                          value:
                                              '¥${avgPrice.toStringAsFixed(0)}',
                                          icon: Icons.payments_rounded,
                                          color: const Color(0xFFFFD93D),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildMetricCard(
                                          context,
                                          label: isChinese
                                              ? '平均售出天数'
                                              : 'Avg Days',
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
                                          label: isChinese
                                              ? '成交率'
                                              : 'Success Rate',
                                          value:
                                              '${successRate.toStringAsFixed(0)}%',
                                          icon: Icons.check_circle_rounded,
                                          color: const Color(0xFF5ECFB8),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildMetricCard(
                                          context,
                                          label: isChinese
                                              ? '总收入'
                                              : 'Total Revenue',
                                          value:
                                              '¥${totalRevenue.toStringAsFixed(0)}',
                                          icon: Icons
                                              .account_balance_wallet_rounded,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isChinese
                                        ? '转卖表现随时间的变化趋势'
                                        : 'Resell performance over time',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.black54),
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
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: TrendMetric.values.map((
                                              metric,
                                            ) {
                                              final isSelected =
                                                  _selectedMetric == metric;
                                              return Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedMetric = metric;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      boxShadow: isSelected
                                                          ? [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                      alpha:
                                                                          0.1,
                                                                    ),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      2,
                                                                    ),
                                                              ),
                                                            ]
                                                          : [],
                                                    ),
                                                    child: Text(
                                                      metric.label(isChinese),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: isSelected
                                                                ? Colors.black87
                                                                : Colors
                                                                      .black54,
                                                            fontWeight:
                                                                isSelected
                                                                ? FontWeight
                                                                      .w600
                                                                : FontWeight
                                                                      .w500,
                                                            fontSize: 11,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
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
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Category Performance Analysis
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
                                    isChinese
                                        ? '品类表现分析'
                                        : 'Category Performance',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isChinese
                                        ? '各品类的成交金额和成交率'
                                        : 'Revenue and success rate by category',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildCategoryPerformance(context, isChinese),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 30+ Days Unsold Items
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
                                    isChinese
                                        ? '超过30天未售出统计'
                                        : '30+ Days Unsold',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isChinese
                                        ? '按品类统计超过30天未售出的物品'
                                        : 'Unsold items over 30 days by category',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildUnsoldItems(context, isChinese),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 交易洞察 Summary Section
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
                                    isChinese ? '交易洞察' : 'Transaction Insights',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTransactionInsights(context, isChinese),
                                ],
                              ),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: realHeaderOpacity < 0.5,
              child: Opacity(
                opacity: realHeaderOpacity,
                child: Container(
                  height: topPadding + kToolbarHeight,
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
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
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
      };
    }

    // Fill in actual data
    for (final resellItem in widget.resellItems) {
      final category = _getCategoryForResellItem(resellItem);
      if (category == null) continue;

      categoryData[category]!['totalCount'] += 1;

      if (resellItem.status == ResellStatus.sold &&
          resellItem.soldPrice != null) {
        categoryData[category]!['soldCount'] += 1;
        categoryData[category]!['totalRevenue'] += resellItem.soldPrice!;
      }
    }

    // Find max values for scaling
    double maxRevenue = 0;
    for (final data in categoryData.values) {
      if (data['totalRevenue'] > maxRevenue) {
        maxRevenue = data['totalRevenue'];
      }
    }
    // Ensure maxRevenue is at least 1 to avoid division by zero
    if (maxRevenue == 0) maxRevenue = 1;

    // Build toggle for metric selection
    return Column(
      children: [
        // Metric selector
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
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: CategoryMetric.values.map((metric) {
                    final isSelected = _selectedCategoryMetric == metric;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryMetric = metric;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: AutoScaleText(
                            metric.label(isChinese),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? Colors.black87
                                      : Colors.black54,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Bar chart for selected metric
        Column(
          children: DeclutterCategory.values.map((category) {
            final data = categoryData[category]!;
            final revenue = data['totalRevenue'] as double;
            final totalCount = data['totalCount'] as int;
            final soldCount = data['soldCount'] as int;
            final successRate = totalCount > 0
                ? (soldCount / totalCount * 100)
                : 0.0;

            // Calculate bar width based on selected metric
            double barValue;
            String valueText;
            Color barColor;

            if (_selectedCategoryMetric == CategoryMetric.revenue) {
              barValue = maxRevenue > 0 ? revenue / maxRevenue : 0;
              valueText = '¥${revenue.toStringAsFixed(0)}';
              barColor = const Color(0xFFFFD93D);
            } else {
              barValue = successRate / 100;
              valueText = '${successRate.toStringAsFixed(0)}%';
              barColor = const Color(0xFF5ECFB8);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.label(context),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        valueText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Bar
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: barValue,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD93D).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFD93D),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                    Text(
                      isChinese
                          ? '$count 件物品超过30天未售出'
                          : '$count item${count > 1 ? 's' : ''} unsold over 30 days',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black38,
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

    return Column(
      children: [
        // 成交表现
        _buildInsightRow(
          context,
          icon: Icons.trending_up_rounded,
          iconColor: const Color(0xFF10B981),
          label: isChinese ? '成交表现' : 'Success Rate',
          value: '${successRate.toStringAsFixed(0)}%',
          isChinese: isChinese,
        ),
        const SizedBox(height: 12),

        // 优势品类
        if (bestCategory != null)
          _buildInsightRow(
            context,
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFD93D),
            label: isChinese ? '优势品类' : 'Best Category',
            value: bestCategory!.label(context),
            isChinese: isChinese,
          ),
        if (bestCategory != null) const SizedBox(height: 12),

        // 最快成交
        if (fastestDays != null)
          _buildInsightRow(
            context,
            icon: Icons.flash_on_rounded,
            iconColor: const Color(0xFFFF9AA2),
            label: isChinese ? '最快成交' : 'Fastest Sale',
            value: '$fastestDays ${isChinese ? '天' : 'days'}',
            isChinese: isChinese,
          ),
        if (fastestDays != null) const SizedBox(height: 12),

        // 最高价格
        if (highestPrice > 0)
          _buildInsightRow(
            context,
            icon: Icons.attach_money_rounded,
            iconColor: const Color(0xFF5ECFB8),
            label: isChinese ? '最高价格' : 'Highest Price',
            value: '¥${highestPrice.toStringAsFixed(0)}',
            isChinese: isChinese,
          ),
      ],
    );
  }

  // Helper method to build insight row
  Widget _buildInsightRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isChinese,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
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
          AutoScaleText(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontSize: 12,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 4),
          AutoScaleText(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left,
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
      // Only include items from current year
      if (item.createdAt.year == now.year) {
        final month = item.createdAt.month; // 1-12
        switch (_selectedMetric) {
          case TrendMetric.soldItems:
            // Only count sold items
            if (item.status == ResellStatus.sold) {
              monthlyData[month]!.add(1);
            }
            break;
          case TrendMetric.listedDays:
            if (item.status == ResellStatus.sold && item.soldDate != null) {
              final days = item.soldDate!
                  .difference(item.createdAt)
                  .inDays
                  .toDouble();
              monthlyData[month]!.add(days);
            }
            break;
          case TrendMetric.resellValue:
            if (item.status == ResellStatus.sold && item.soldPrice != null) {
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
        } else if (_selectedMetric == TrendMetric.resellValue) {
          result[month] = values.reduce((a, b) => a + b); // Total value
        } else {
          result[month] =
              values.reduce((a, b) => a + b) / values.length; // Average
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

    final axisPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right, // Right-align Y-axis labels
    );

    // Find max value first (ensure at least 1 to avoid division by zero)
    double maxValue = trendData.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) {
      maxValue = 5; // default minimum
    } else {
      maxValue = maxValue * 1.25;
    }

    // Calculate required left padding based on max label width
    textPainter.text = TextSpan(
      text: maxValue.toStringAsFixed(0),
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
        text: value.toStringAsFixed(0),
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
