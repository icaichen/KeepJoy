import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/unified/models/enhanced_report_models.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';

class OrganizeDetailScreen extends StatelessWidget {
  final EnhancedUnifiedReportData data;

  const OrganizeDetailScreen({super.key, required this.data});

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
                      colors: [Color(0xFF5ECFB8), Color(0xFFE6FFFA), ReportUI.backgroundColor],
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
                          isChinese ? '整理统计' : 'Organize Stats',
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
                  isChinese ? '分类分布' : 'Category Distribution',
                  _buildCategoryChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '月度趋势' : 'Monthly Trend',
                  _buildMonthlyChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '心动率分析' : 'Joy Rate Analysis',
                  _buildJoyRateAnalysis(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '处理效率' : 'Processing Efficiency',
                  _buildEfficiencyAnalysis(isChinese, stats),
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
              icon: Icons.favorite_outline,
              iconColor: const Color(0xFFFFD93D),
              value: '${stats.joyCount}',
              label: isChinese ? '心动' : 'Joy',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.percent,
              iconColor: const Color(0xFF89CFF0),
              value: '${stats.joyRate.toStringAsFixed(0)}%',
              label: isChinese ? '心动率' : 'Joy Rate',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFFFFA07A),
              value: '${stats.keptCount}',
              label: isChinese ? '保留' : 'Kept',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.sell_outlined,
              iconColor: const Color(0xFFB794F6),
              value: '${stats.resellCount}',
              label: isChinese ? '转售' : 'Resell',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.volunteer_activism_outlined,
              iconColor: const Color(0xFFFF9AA2),
              value: '${stats.donateCount}',
              label: isChinese ? '捐赠' : 'Donate',
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

  Widget _buildCategoryChart(bool isChinese, EnhancedDeclutterStats stats) {
    if (stats.categoryDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final sortedCategories = stats.categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sortedCategories.fold<int>(0, (sum, e) => sum + e.value);

    return Column(
      children: sortedCategories.take(6).map((entry) {
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF5ECFB8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isChinese ? entry.key.chinese : entry.key.english,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '${entry.value} ($percentage%)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5ECFB8)),
              ),
            ],
          ),
        );
      }).toList(),
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

    final maxValue = stats.monthlyDistribution.values.reduce((a, b) => a > b ? a : b);
    final months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: months.asMap().entries.map((entry) {
          final month = int.parse(entry.value);
          final value = stats.monthlyDistribution[month] ?? 0;
          final height = maxValue > 0 ? (value / maxValue * 80).toDouble() : 0.0;
          
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (value > 0)
                  Text(
                    '$value',
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 4),
                Container(
                  height: height > 0 ? height : 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: value > 0 ? const Color(0xFF5ECFB8) : const Color(0xFFE5E7EB),
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
    );
  }

  Widget _buildJoyRateAnalysis(bool isChinese, EnhancedDeclutterStats stats) {
    if (stats.joyLevelDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final sortedJoyLevels = stats.joyLevelDistribution.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final total = sortedJoyLevels.fold<int>(0, (sum, e) => sum + e.value);

    final joyColors = {
      5: const Color(0xFFFFD93D),
      4: const Color(0xFFFFE066),
      3: const Color(0xFFFFEB99),
      2: const Color(0xFFFFF0B3),
      1: const Color(0xFFFFF5CC),
    };

    return Column(
      children: sortedJoyLevels.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0.0';
        final color = joyColors[entry.key] ?? const Color(0xFFE5E7EB);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: entry.key >= 4 ? Colors.orange : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.key}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? entry.value / total : 0,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${entry.value} ($percentage%)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEfficiencyAnalysis(bool isChinese, EnhancedDeclutterStats stats) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF5ECFB8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF5ECFB8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stats.averageProcessingDays.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isChinese ? '天' : 'days',
                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '平均处理时间' : 'Avg Processing Time',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isChinese 
                          ? '从创建到处理的平均天数'
                          : 'Average days from creation to processing',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (stats.topCategories.isNotEmpty) ...[
          Text(
            isChinese ? '主要分类' : 'Top Categories',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.topCategories.take(5).map((cat) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5ECFB8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5ECFB8).withValues(alpha: 0.3)),
                ),
                child: Text(
                  isChinese ? cat.category.chinese : cat.category.english,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
