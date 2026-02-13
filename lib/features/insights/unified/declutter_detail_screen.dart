import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/unified/models/enhanced_report_models.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';
import 'package:keepjoy_app/models/declutter_item.dart';

class DeclutterDetailScreen extends StatelessWidget {
  final EnhancedUnifiedReportData data;

  const DeclutterDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode.startsWith('zh');
    final stats = data.declutterStats;

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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF5ECFB8), Color(0xFFE6F9F5), ReportUI.backgroundColor],
                      stops: [0.0, 0.35, 0.65],
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
                          isChinese ? '整理统计' : 'Declutter Stats',
                          style: ReportTextStyles.screenTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.year} ${isChinese ? "年数据" : "Year Data"}',
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
                  isChinese ? '处理结果' : 'Outcomes',
                  _buildOutcomeChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '购买评价分布' : 'Purchase Reviews',
                  _buildReviewChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '心动度分布' : 'Joy Level Distribution',
                  _buildJoyLevelChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '热门品类' : 'Top Categories',
                  _buildTopCategories(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '品类分布' : 'Categories',
                  _buildCategoryList(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '处理效率' : 'Processing Efficiency',
                  _buildEfficiencyStats(isChinese, stats),
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

  Widget _buildStatRow(bool isChinese, EnhancedDeclutterStats stats) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF5ECFB8),
              value: '${stats.totalItems}',
              label: isChinese ? '总物品' : 'Total',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.favorite,
              iconColor: const Color(0xFFFF9AA2),
              value: '${stats.joyRate.toStringAsFixed(0)}%',
              label: isChinese ? '心动率' : 'Joy Rate',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF89CFF0),
              value: '${stats.processedCount}',
              label: isChinese ? '已处理' : 'Processed',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              icon: Icons.timer_outlined,
              iconColor: const Color(0xFFFFD93D),
              value: stats.averageProcessingDays.toStringAsFixed(0),
              label: isChinese ? '平均处理天数' : 'Avg Days',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.trending_up,
              iconColor: const Color(0xFFB794F6),
              value: stats.efficiency.monthlyRate.toStringAsFixed(1),
              label: isChinese ? '月均处理' : 'Monthly Avg',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.pending_actions,
              iconColor: const Color(0xFFFFA07A),
              value: '${stats.pendingCount}',
              label: isChinese ? '待处理' : 'Pending',
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

  Widget _buildOutcomeChart(bool isChinese, EnhancedDeclutterStats stats) {
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
      (isChinese ? '保留' : 'Kept', stats.keptCount, const Color(0xFF5ECFB8)),
      (isChinese ? '转卖' : 'Resell', stats.resellCount, const Color(0xFFFFD93D)),
      (isChinese ? '捐赠' : 'Donate', stats.donateCount, const Color(0xFF89CFF0)),
      (isChinese ? '回收' : 'Recycle', stats.recycleCount, const Color(0xFFB794F6)),
      (isChinese ? '丢弃' : 'Discard', stats.discardCount, const Color(0xFFFF9AA2)),
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
              Expanded(
                child: Text(item.$1, style: const TextStyle(fontSize: 14)),
              ),
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

  Widget _buildReviewChart(bool isChinese, EnhancedDeclutterStats stats) {
    if (stats.purchaseReviewDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final total = stats.purchaseReviewDistribution.values.fold<int>(0, (sum, count) => sum + count);
    final reviews = [
      (PurchaseReview.worthIt, isChinese ? '值得购买' : 'Worth it', '⭐', const Color(0xFF5ECFB8)),
      (PurchaseReview.wouldBuyAgain, isChinese ? '会再入手' : 'Buy again', '🔄', const Color(0xFFFFD93D)),
      (PurchaseReview.neutral, isChinese ? '无感' : 'Neutral', '😐', const Color(0xFF9CA3AF)),
      (PurchaseReview.wasteMoney, isChinese ? '浪费金钱' : 'Waste', '💸', const Color(0xFFFF9AA2)),
    ];

    return Column(
      children: reviews.map((review) {
        final count = stats.purchaseReviewDistribution[review.$1] ?? 0;
        if (count == 0) return const SizedBox.shrink();
        final percentage = (count / total * 100).toStringAsFixed(1);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(review.$3, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(review.$2, style: const TextStyle(fontSize: 14))),
              Text(
                '$count ($percentage%)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: review.$4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildJoyLevelChart(bool isChinese, EnhancedDeclutterStats stats) {
    if (stats.joyLevelDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final maxCount = stats.joyLevelDistribution.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(10, (index) {
          final level = index + 1;
          final count = stats.joyLevelDistribution[level] ?? 0;
          final height = maxCount > 0 ? (count / maxCount * 70).toDouble() : 0.0;
          final color = level >= 6 ? const Color(0xFFFF9AA2) : const Color(0xFF9CA3AF);
          
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (count > 0)
                  Text('$count', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                  height: height > 0 ? height : 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: count > 0 ? color : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$level', style: const TextStyle(fontSize: 10)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopCategories(bool isChinese, EnhancedDeclutterStats stats) {
    if (stats.topCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    return Column(
      children: stats.topCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final rankColors = [
          const Color(0xFFFFD93D), // Gold
          const Color(0xFFC0C0C0), // Silver
          const Color(0xFFCD7F32), // Bronze
          const Color(0xFF9CA3AF),
          const Color(0xFF9CA3AF),
        ];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: rankColors[index],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isChinese ? category.category.chinese : category.category.english,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '${category.count} (${category.percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryList(bool isChinese, EnhancedDeclutterStats stats) {
    if (stats.categoryDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final sortedEntries = stats.categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final category = entry.key;
        final count = entry.value;
        final percentage = (count / stats.totalItems * 100).toStringAsFixed(1);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? category.chinese : category.english,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: count / stats.totalItems,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF5ECFB8)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$count ($percentage%)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEfficiencyStats(bool isChinese, EnhancedDeclutterStats stats) {
    return Column(
      children: [
        _buildEfficiencyRow(
          isChinese ? '总处理物品' : 'Total Processed',
          '${stats.efficiency.totalProcessed}',
          Icons.done_all,
          const Color(0xFF5ECFB8),
        ),
        const SizedBox(height: 12),
        _buildEfficiencyRow(
          isChinese ? '平均处理时间' : 'Avg Processing Time',
          '${stats.efficiency.averageDays.toStringAsFixed(1)} ${isChinese ? '天' : 'days'}',
          Icons.timer,
          const Color(0xFFFFD93D),
        ),
        const SizedBox(height: 12),
        _buildEfficiencyRow(
          isChinese ? '月均处理量' : 'Monthly Rate',
          '${stats.efficiency.monthlyRate.toStringAsFixed(1)} ${isChinese ? '件/月' : 'items/month'}',
          Icons.speed,
          const Color(0xFF89CFF0),
        ),
      ],
    );
  }

  Widget _buildEfficiencyRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMonthlyChart(bool isChinese, EnhancedDeclutterStats stats) {
    if (stats.monthlyDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final maxCount = stats.monthlyDistribution.values.reduce((a, b) => a > b ? a : b);
    final months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: months.asMap().entries.map((entry) {
          final month = int.parse(entry.value);
          final count = stats.monthlyDistribution[month] ?? 0;
          final height = maxCount > 0 ? (count / maxCount * 80).toDouble() : 0.0;
          
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (count > 0)
                  Text(
                    '$count',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 4),
                Container(
                  height: height > 0 ? height : 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: count > 0 ? const Color(0xFF5ECFB8) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isChinese ? '${entry.value}月' : entry.value,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
