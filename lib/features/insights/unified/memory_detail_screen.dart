import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/unified/models/enhanced_report_models.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';

class MemoryDetailScreen extends StatelessWidget {
  final EnhancedUnifiedReportData data;

  const MemoryDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode.startsWith('zh');
    final stats = data.memoryStats;

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
                      colors: [Color(0xFF89CFF0), Color(0xFFF0F9FF), ReportUI.backgroundColor],
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
                          isChinese ? '回忆统计' : 'Memory Stats',
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
                  isChinese ? '月度对比' : 'Monthly Comparison',
                  _buildMonthlyComparison(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '回忆类型' : 'Memory Types',
                  _buildTypeChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '情感分布' : 'Emotion Distribution',
                  _buildEmotionChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '标签分析' : 'Tag Analysis',
                  _buildTagAnalysis(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '活跃时段' : 'Active Hours',
                  _buildActiveHours(isChinese, stats),
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

  Widget _buildStatRow(bool isChinese, EnhancedMemoryStats stats) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              icon: Icons.photo_library_outlined,
              iconColor: const Color(0xFF89CFF0),
              value: '${stats.totalCount}',
              label: isChinese ? '总回忆数' : 'Total',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.image_outlined,
              iconColor: const Color(0xFFFFD93D),
              value: '${stats.totalPhotos}',
              label: isChinese ? '照片数' : 'Photos',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.videocam_outlined,
              iconColor: const Color(0xFF5ECFB8),
              value: '${stats.totalVideos}',
              label: isChinese ? '视频数' : 'Videos',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFFFFA07A),
              value: '${stats.locationsCount}',
              label: isChinese ? '地点数' : 'Locations',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.local_offer_outlined,
              iconColor: const Color(0xFFB794F6),
              value: '${stats.tagsCount}',
              label: isChinese ? '标签数' : 'Tags',
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.favorite_outline,
              iconColor: const Color(0xFFFF9AA2),
              value: '${stats.favoriteCount}',
              label: isChinese ? '收藏' : 'Favorites',
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

  Widget _buildMonthlyComparison(bool isChinese, EnhancedMemoryStats stats) {
    final comparison = stats.monthlyComparison;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                isChinese ? '本月新增' : 'This Month',
                '${comparison.thisMonth}',
                Icons.calendar_today,
                const Color(0xFF89CFF0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonCard(
                isChinese ? '上月新增' : 'Last Month',
                '${comparison.lastMonth}',
                Icons.calendar_month,
                const Color(0xFFFFD93D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                isChinese ? '月均新增' : 'Monthly Avg',
                comparison.averagePerMonth.toStringAsFixed(1),
                Icons.trending_up,
                const Color(0xFF5ECFB8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonCard(
                isChinese ? '年度总计' : 'Year Total',
                '${comparison.totalSold}',
                Icons.assessment,
                const Color(0xFFB794F6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChart(bool isChinese, EnhancedMemoryStats stats) {
    final total = stats.totalCount;
    if (total == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final items = [
      (isChinese ? '照片' : 'Photo', stats.photoCount, const Color(0xFF89CFF0)),
      (isChinese ? '视频' : 'Video', stats.videoCount, const Color(0xFF5ECFB8)),
      (isChinese ? '文字' : 'Text', stats.textCount, const Color(0xFFFFD93D)),
      (isChinese ? '混合' : 'Mixed', stats.mixedCount, const Color(0xFFB794F6)),
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

  Widget _buildEmotionChart(bool isChinese, EnhancedMemoryStats stats) {
    if (stats.emotionDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final sortedEmotions = stats.emotionDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sortedEmotions.fold<int>(0, (sum, e) => sum + e.value);

    final emotionColors = {
      'happy': const Color(0xFFFFD93D),
      'joy': const Color(0xFFFFD93D),
      'sad': const Color(0xFF89CFF0),
      'angry': const Color(0xFFFF9AA2),
      'calm': const Color(0xFF5ECFB8),
      'excited': const Color(0xFFFFA07A),
      'neutral': const Color(0xFF9CA3AF),
    };

    return Column(
      children: sortedEmotions.take(5).map((entry) {
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        final color = emotionColors[entry.key.toLowerCase()] ?? const Color(0xFFB794F6);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_getEmotionName(entry.key, isChinese), style: const TextStyle(fontSize: 14))),
              Text(
                '${entry.value} ($percentage%)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getEmotionName(String key, bool isChinese) {
    final names = {
      'happy': isChinese ? '开心' : 'Happy',
      'joy': isChinese ? '快乐' : 'Joy',
      'sad': isChinese ? '悲伤' : 'Sad',
      'angry': isChinese ? '生气' : 'Angry',
      'calm': isChinese ? '平静' : 'Calm',
      'excited': isChinese ? '兴奋' : 'Excited',
      'neutral': isChinese ? '中性' : 'Neutral',
    };
    return names[key.toLowerCase()] ?? key;
  }

  Widget _buildTagAnalysis(bool isChinese, EnhancedMemoryStats stats) {
    if (stats.tagDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final sortedTags = stats.tagDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedTags.take(15).map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF89CFF0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF89CFF0).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_offer, size: 14, color: Color(0xFF89CFF0)),
              const SizedBox(width: 4),
              Text(
                entry.key,
                style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.value}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveHours(bool isChinese, EnhancedMemoryStats stats) {
    if (stats.hourlyDistribution.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final maxCount = stats.hourlyDistribution.values.reduce((a, b) => a > b ? a : b);
    final hours = List.generate(24, (i) => i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: hours.map((hour) {
              final count = stats.hourlyDistribution[hour] ?? 0;
              final height = maxCount > 0 ? (count / maxCount * 60).toDouble() : 0.0;
              
              return Expanded(
                child: Tooltip(
                  message: '$hour:00 - $count',
                  child: Container(
                    height: height > 0 ? height : 2,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: count > 0 ? const Color(0xFF89CFF0) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('00:00', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            Text('06:00', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            Text('12:00', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            Text('18:00', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            Text('23:00', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(bool isChinese, EnhancedMemoryStats stats) {
    if (stats.monthlyCount.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(isChinese ? '暂无数据' : 'No data', style: ReportTextStyles.body),
        ),
      );
    }

    final maxValue = stats.monthlyCount.values.reduce((a, b) => a > b ? a : b);
    final months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: months.asMap().entries.map((entry) {
          final month = int.parse(entry.value);
          final value = stats.monthlyCount[month] ?? 0;
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
                    color: value > 0 ? const Color(0xFF89CFF0) : const Color(0xFFE5E7EB),
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
}
