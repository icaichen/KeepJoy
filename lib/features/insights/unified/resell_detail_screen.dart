import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/unified/models/enhanced_report_models.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';


class ResellDetailScreen extends StatefulWidget {
  final EnhancedUnifiedReportData data;

  const ResellDetailScreen({super.key, required this.data});

  @override
  State<ResellDetailScreen> createState() => _ResellDetailScreenState();
}

class _ResellDetailScreenState extends State<ResellDetailScreen> {
  bool _showRevenue = true; // Toggle between revenue and count

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode.startsWith('zh');
    final stats = widget.data.resellStats;

    return Scaffold(
      backgroundColor: ReportUI.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [const Color(0xFFFFD93D), const Color(0xFFFFF9E6), ReportUI.backgroundColor],
                      stops: const [0.0, 0.35, 0.65],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isChinese ? '二手洞察' : 'Resell Insights',
                          style: ReportTextStyles.screenTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.data.year} ${isChinese ? "年数据" : "Year Data"}',
                          style: ReportTextStyles.screenSubtitle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildStatRow(isChinese, stats),
                const SizedBox(height: 24),
                _buildSection(
                  isChinese ? '销售状态' : 'Status',
                  _buildStatusChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildCategorySection(isChinese, stats),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '平台分布' : 'Platform Distribution',
                  _buildPlatformDistribution(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '高价成交' : 'Top Selling',
                  _buildTopSellingItems(isChinese, stats, widget.data.declutteredItems),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '月度趋势' : 'Monthly Trend',
                  _buildMonthlyChart(isChinese, stats),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(bool isChinese, EnhancedResellStats stats) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFFFFD93D),
              value: '¥${stats.totalRevenue.toStringAsFixed(0)}',
              label: isChinese ? '总收入' : 'Revenue',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF5ECFB8),
              value: '${stats.successRate.toStringAsFixed(0)}%',
              label: isChinese ? '成交率' : 'Success Rate',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.trending_up,
              iconColor: const Color(0xFF89CFF0),
              value: '¥${stats.averageSoldPrice.toStringAsFixed(0)}',
              label: isChinese ? '平均售价' : 'Avg Price',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              icon: Icons.timer,
              iconColor: const Color(0xFFFFA07A),
              value: stats.averageListedDays.toStringAsFixed(0),
              label: isChinese ? '平均天数' : 'Avg Days',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.shopping_bag,
              iconColor: const Color(0xFFB794F6),
              value: stats.soldCount.toString(),
              label: isChinese ? '已售出' : 'Sold',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.inventory,
              iconColor: const Color(0xFF9CA3AF),
              value: '${stats.listingCount + stats.toSellCount}',
              label: isChinese ? '待售/在售' : 'Pending',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required Color iconColor, required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ReportUI.statCardDecoration,
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(value, style: ReportTextStyles.statValueSmall),
            const SizedBox(height: 2),
            Text(label, style: ReportTextStyles.label),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ReportTextStyles.sectionHeader),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildStatusChart(bool isChinese, EnhancedResellStats stats) {
    final total = stats.totalItems;
    if (total == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final items = [
      (isChinese ? '已售出' : 'Sold', stats.soldCount, const Color(0xFF5ECFB8)),
      (isChinese ? '在售' : 'Listing', stats.listingCount, const Color(0xFFFFD93D)),
      (isChinese ? '待售' : 'To Sell', stats.toSellCount, const Color(0xFF89CFF0)),
    ];

    return Column(
      children: items.where((item) => item.$2 > 0).map((item) {
        final percentage = (item.$2 / total * 100).toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.$3,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(item.$1, style: const TextStyle(fontSize: 14))),
              Text(
                '${item.$2} ($percentage%)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: item.$3),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection(bool isChinese, EnhancedResellStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ReportUI.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '品类表现' : 'Category Performance',
            style: ReportTextStyles.sectionHeader,
          ),
          const SizedBox(height: 16),
          _buildCategoryPerformance(isChinese, stats),
        ],
      ),
    );
  }

  Widget _buildCategoryPerformance(bool isChinese, EnhancedResellStats stats) {
    if (stats.categoryPerformance.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
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
                        isChinese ? perf.category.chinese : perf.category.english,
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
                              color: const Color(0xFF89CFF0), // Light Blue to match app theme
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                
                // Avg Days
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerRight,
                    height: 40,
                    child: Text(
                      '${perf.averageDays.toStringAsFixed(0)}${isChinese ? "天" : "d"}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
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

  Widget _buildPlatformDistribution(bool isChinese, EnhancedResellStats stats) {
    if (stats.platformDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final sortedPlatforms = stats.platformDistribution.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return Column(
      children: sortedPlatforms.map((platformStat) {
        final platformName = platformStat.platform.label(context);
        final percentage = stats.totalRevenue > 0 
            ? (platformStat.revenue / stats.totalRevenue * 100).toStringAsFixed(1)
            : '0.0';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  platformName.substring(0, 1),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(platformName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      '${platformStat.soldCount} ${isChinese ? "单" : "orders"}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${platformStat.revenue.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFD93D)),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopSellingItems(bool isChinese, EnhancedResellStats stats, List<DeclutterItem> allItems) {
    if (stats.topSellingItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    return Column(
      children: stats.topSellingItems.take(5).map((item) {
        final declutterItem = allItems
            .where((d) => d.id == item.declutterItemId)
            .firstOrNull;
        final name = declutterItem?.name ?? (isChinese ? '未知物品' : 'Unknown Item');
        final category = declutterItem?.category.label(context) ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.sell_outlined, color: Color(0xFFFFD93D), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      category,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              Text(
                '¥${(item.soldPrice ?? 0).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5ECFB8)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  Widget _buildMonthlyChart(bool isChinese, EnhancedResellStats stats) {
    if (stats.monthlyRevenue.isEmpty && stats.monthlySoldCount.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final data = _showRevenue ? stats.monthlyRevenue : stats.monthlySoldCount.map((k, v) => MapEntry(k, v.toDouble()));
    final maxValue = data.values.isNotEmpty ? data.values.reduce((a, b) => a > b ? a : b) : 1;
    final months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
    
    // Trend analysis data
    final trend = stats.trendAnalysis;
    final isUp = trend.isUp;

    return Column(
      children: [
        // Integrated Trend Analysis
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUp ? const Color(0xFF5ECFB8).withValues(alpha: 0.1) : const Color(0xFFFF9AA2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                color: isUp ? const Color(0xFF5ECFB8) : const Color(0xFFFF9AA2),
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese 
                          ? (isUp ? '本月收入上升' : '本月收入下降')
                          : (isUp ? 'Revenue Up' : 'Revenue Down'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isUp ? const Color(0xFF5ECFB8) : const Color(0xFFFF9AA2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isUp ? '+' : '-'}${trend.changePercent.abs().toStringAsFixed(1)}% · '
                      '¥${trend.currentMonthRevenue.toStringAsFixed(0)} ${isChinese ? '本月' : 'this month'}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isUp ? const Color(0xFF5ECFB8) : const Color(0xFFFF9AA2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${isUp ? '+' : '-'}${trend.changePercent.abs().toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: Text(isChinese ? '收入' : 'Revenue'),
              selected: _showRevenue,
              onSelected: (selected) => setState(() => _showRevenue = true),
              selectedColor: const Color(0xFFFFD93D),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(isChinese ? '数量' : 'Count'),
              selected: !_showRevenue,
              onSelected: (selected) => setState(() => _showRevenue = false),
              selectedColor: const Color(0xFFFFD93D),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.asMap().entries.map((entry) {
              final month = int.parse(entry.value);
              final value = data[month] ?? 0;
              final height = maxValue > 0 ? (value / maxValue * 80).toDouble() : 0.0;
              
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (value > 0)
                      Text(
                        _showRevenue ? '¥${(value / 1000).toStringAsFixed(1)}k' : '${value.toInt()}',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      height: height > 0 ? height : 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: value > 0 ? const Color(0xFFFFD93D) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(isChinese ? '${entry.value}月' : entry.value, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
