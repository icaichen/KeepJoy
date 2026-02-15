import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/unified/models/enhanced_report_models.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';
import 'package:keepjoy_app/features/insights/deep_cleaning_analysis_card.dart';

class OrganizeDetailScreen extends StatefulWidget {
  final EnhancedUnifiedReportData data;

  const OrganizeDetailScreen({super.key, required this.data});

  @override
  State<OrganizeDetailScreen> createState() => _OrganizeDetailScreenState();
}

class _OrganizeDetailScreenState extends State<OrganizeDetailScreen> {
  bool _showJoyPercent = true;

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.startsWith('zh');
    final stats = widget.data.declutterStats;

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
                      colors: [
                        Color(0xFF5ECFB8),
                        Color(0xFFE6FFFA),
                        ReportUI.backgroundColor,
                      ],
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
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isChinese ? '整理报告' : 'Declutter Report',
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
                  isChinese ? '分类分布' : 'Category Distribution',
                  _buildCategoryChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '整理热力图' : 'Declutter Heatmap',
                  _buildHeatmapSection(isChinese, widget.data),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '月度趋势' : 'Monthly Trend',
                  _buildMonthlyChart(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '心动趋势图' : 'Joy Trend Chart',
                  _buildJoyRateAnalysis(isChinese, stats),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  isChinese ? '处理效率' : 'Processing Efficiency',
                  _buildEfficiencyAnalysis(isChinese, stats),
                ),
                const SizedBox(height: 16),
                DeepCleaningAnalysisCard(
                  sessions: widget.data.yearlyDeepCleaningSessions,
                  title: isChinese ? '深度清洁分析' : 'Deep Cleaning Analysis',
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapSection(bool isChinese, EnhancedUnifiedReportData data) {
    final activity = <int, int>{};
    // Initialize with 0
    for (int i = 1; i <= 12; i++) {
      activity[i] = 0;
    }

    // Add declutter items
    for (final item in data.yearlyDeclutteredItems) {
      activity[item.createdAt.month] =
          (activity[item.createdAt.month] ?? 0) + 1;
    }

    // Add deep cleaning sessions
    for (final session in data.yearlyDeepCleaningSessions) {
      activity[session.startTime.month] =
          (activity[session.startTime.month] ?? 0) + 1;
    }

    return Column(
      children: [
        // First row (Jan-Jun)
        Row(
          children: List.generate(6, (index) {
            final month = index + 1;
            return _buildHeatmapCell(
              context,
              month,
              activity[month] ?? 0,
              isChinese,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Second row (Jul-Dec)
        Row(
          children: List.generate(6, (index) {
            final month = index + 7;
            return _buildHeatmapCell(
              context,
              month,
              activity[month] ?? 0,
              isChinese,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeatmapCell(
    BuildContext context,
    int month,
    int count,
    bool isChinese,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 32,
              decoration: BoxDecoration(
                color: _getHeatmapColor(count),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isChinese ? '$month月' : _getMonthAbbrev(month),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeatmapColor(int count) {
    if (count == 0) return const Color(0xFFF3F4F6); // gray-100
    if (count < 3) return const Color(0xFFD1FAE5); // green-100
    if (count < 7) return const Color(0xFF6EE7B7); // green-300
    if (count < 15) return const Color(0xFF34D399); // green-400
    return const Color(0xFF10B981); // green-500
  }

  String _getMonthAbbrev(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
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
          child: Text(
            isChinese ? '暂无数据' : 'No data',
            style: ReportTextStyles.body,
          ),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5ECFB8),
                ),
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
          child: Text(
            isChinese ? '暂无数据' : 'No data',
            style: ReportTextStyles.body,
          ),
        ),
      );
    }

    final maxValue = stats.monthlyDistribution.values.reduce(
      (a, b) => a > b ? a : b,
    );
    final months = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
    ];

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: months.asMap().entries.map((entry) {
          final month = int.parse(entry.value);
          final value = stats.monthlyDistribution[month] ?? 0;
          final height = maxValue > 0
              ? (value / maxValue * 80).toDouble()
              : 0.0;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (value > 0)
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  height: height > 0 ? height : 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: value > 0
                        ? const Color(0xFF5ECFB8)
                        : const Color(0xFFE5E7EB),
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

  Widget _buildJoyRateAnalysis(bool isChinese, EnhancedDeclutterStats stats) {
    // Calculate monthly joy percentages
    final monthlyJoyPercent = <int, double>{};
    final monthlyJoyCount = stats.monthlyJoyClicks;

    for (int month = 1; month <= 12; month++) {
      final total = stats.monthlyDistribution[month] ?? 0;
      final joyCount = monthlyJoyCount[month] ?? 0;
      monthlyJoyPercent[month] = total > 0 ? (joyCount / total * 100) : 0.0;
    }

    // Calculate average joy rate (excluding months with no data)
    final monthsWithData = monthlyJoyPercent.values
        .where((v) => v > 0)
        .toList();
    final avgJoyPercent = monthsWithData.isEmpty
        ? 0.0
        : monthsWithData.reduce((a, b) => a + b) / monthsWithData.length;

    // Calculate total joy count
    final totalJoyCount = stats.joyCount;

    // Determine trend (compare recent 3 months vs older 3 months)
    final now = DateTime.now();
    // Use data year or current year if matching
    final dataYear = widget.data.year;
    final isCurrentYear = dataYear == now.year;
    final currentMonth = isCurrentYear ? now.month : 12;

    String trendText;
    String trendIcon;
    Color trendColor;

    if (currentMonth >= 4) {
      // Need at least 3 months for recent avg
      // Average of most recent 3 months of data
      final month1 = monthlyJoyPercent[currentMonth] ?? 0;
      final month2 = monthlyJoyPercent[currentMonth - 1] ?? 0;
      final month3 = monthlyJoyPercent[currentMonth - 2] ?? 0;
      final recentAvg = (month1 + month2 + month3) / 3;

      // Average of first 3 months (January-March)
      final olderAvg =
          ((monthlyJoyPercent[1] ?? 0) +
              (monthlyJoyPercent[2] ?? 0) +
              (monthlyJoyPercent[3] ?? 0)) /
          3;

      if (recentAvg > olderAvg) {
        trendText = isChinese ? '上升' : 'Rising';
        trendIcon = '↑';
        trendColor = const Color(0xFF4CAF50);
      } else if (recentAvg < olderAvg) {
        trendText = isChinese ? '下降' : 'Falling';
        trendIcon = '↓';
        trendColor = const Color(0xFFF44336);
      } else {
        trendText = isChinese ? '稳定' : 'Stable';
        trendIcon = '→';
        trendColor = const Color(0xFF9E9E9E);
      }
    } else {
      trendText = isChinese ? '暂无' : 'N/A';
      trendIcon = '—';
      trendColor = const Color(0xFF9E9E9E);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with inline info
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChinese ? '年度心动轨迹概览' : 'Annual joy trajectory overview',
                    style: ReportTextStyles.sectionSubtitle,
                  ),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: Color(0xFF9CA3AF),
              ),
              tooltip: isChinese ? '数据说明' : 'Data info',
              onPressed: () => _showJoyInfo(context, isChinese),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Metric dropdown for Joy Rate vs Joy Count
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                isChinese ? '指标' : 'Metric',
                style: ReportTextStyles.body.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool>(
                    value: _showJoyPercent,
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
                          _showJoyPercent = value;
                        });
                      }
                    },
                    items: [
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text(
                          isChinese ? '心动率' : 'Joy Rate',
                          style: ReportTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text(
                          isChinese ? '心动次数' : 'Joy Count',
                          style: ReportTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
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

        const SizedBox(height: 20),

        // Chart (always show with 12 months)
        SizedBox(
          height: 250,
          child: CustomPaint(
            size: const Size(double.infinity, 250),
            painter: _JoyTrendChartPainter(
              monthlyData: _showJoyPercent
                  ? monthlyJoyPercent
                  : monthlyJoyCount.map((k, v) => MapEntry(k, v.toDouble())),
              maxMonths: 12,
              isPercent: _showJoyPercent,
              colorScheme: Theme.of(context).colorScheme,
              isChinese: isChinese,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Summary stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              label: isChinese ? '平均心动率' : 'Avg Joy Rate',
              value: '${avgJoyPercent.toStringAsFixed(0)}%',
              color: const Color(0xFF5ECFB8),
            ),
            _buildStatItem(
              context,
              label: isChinese ? '总心动次数' : 'Total Joy Count',
              value: totalJoyCount.toString(),
              color: const Color(0xFFFFD93D),
            ),
            _buildStatItem(
              context,
              label: isChinese ? '趋势分析' : 'Trend Analysis',
              value: '$trendIcon $trendText',
              color: trendColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEfficiencyAnalysis(
    bool isChinese,
    EnhancedDeclutterStats stats,
  ) {
    final efficiency = stats.efficiency;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildEfficiencyCard(
                isChinese ? '平均处理时长' : 'Avg Processing Time',
                '${efficiency.averageDays.toStringAsFixed(1)} ${isChinese ? "天" : "days"}',
                Icons.timer_outlined,
                const Color(0xFF89CFF0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEfficiencyCard(
                isChinese ? '月均处理' : 'Monthly Avg',
                '${efficiency.monthlyRate.toStringAsFixed(1)}',
                Icons.speed_outlined,
                const Color(0xFF5ECFB8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEfficiencyCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showJoyInfo(BuildContext context, bool isChinese) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isChinese ? '心动' : 'Joy',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  isChinese ? '数据统计说明' : 'How it\'s measured',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoBox(
                  context,
                  isChinese
                      ? '心动量化了您在整理每一件物品时的情感联结。心动率越高，代表您的整理过程越具有正向情感和成就感。'
                      : 'Joy quantifies the emotional connection as you declutter each item. A higher joy rate indicates more positive energy and accomplishment in your journey.',
                ),
                const SizedBox(height: 16),
                _buildInfoBox(
                  context,
                  isChinese
                      ? '心动率 = 产生心动感的物品数 ÷ 所有记录心动状态的物品数。'
                      : 'Joy Rate = Count of Joyful items ÷ Total items with joy assessment.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBox(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4B5563),
          height: 1.5,
        ),
      ),
    );
  }
}

class _JoyTrendChartPainter extends CustomPainter {
  final Map<int, double> monthlyData;
  final int maxMonths;
  final bool isPercent;
  final ColorScheme colorScheme;
  final bool isChinese;

  _JoyTrendChartPainter({
    required this.monthlyData,
    required this.maxMonths,
    required this.isPercent,
    required this.colorScheme,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // Calculate max value for scaling
    double maxValue;
    if (isPercent) {
      maxValue = 100.0;
    } else {
      final maxRaw = monthlyData.values.isEmpty
          ? 0
          : monthlyData.values.reduce((a, b) => a > b ? a : b);
      // Ensure we have at least some range, e.g. 5 if everything is 0
      double baseMax = maxRaw == 0 ? 5.0 : maxRaw.toDouble();
      // Add headroom (e.g. 20%) and round up to nice number
      baseMax = baseMax * 1.2;
      maxValue = baseMax < 5 ? 5.0 : baseMax;
    }

    // Draw background lines
    final linePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    final steps = 5;
    final stepHeight = chartHeight / steps;

    for (int i = 0; i <= steps; i++) {
      final y = padding + i * stepHeight;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        linePaint,
      );

      // Draw Y-axis labels
      final value = maxValue * (steps - i) / steps;

      final textSpan = TextSpan(
        text: isPercent ? '${value.toInt()}%' : value.toStringAsFixed(0),
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // Draw data line
    if (monthlyData.isEmpty) return;

    final path = Path();
    final points = <Offset>[];

    final xStep = chartWidth / (maxMonths - 1);

    for (int i = 1; i <= maxMonths; i++) {
      final x = padding + (i - 1) * xStep;
      final value = monthlyData[i] ?? 0;
      // Clamp value to prevent drawing outside chart area if data somehow exceeds 100%
      final safeValue = value > maxValue ? maxValue : value;
      final y = padding + chartHeight - (safeValue / maxValue * chartHeight);

      if (i == 1) {
        path.moveTo(x, y);
      } else {
        path.cubicTo(x - xStep / 2, points.last.dy, x - xStep / 2, y, x, y);
      }
      points.add(Offset(x, y));
    }

    // Draw gradient area
    final gradientPath = Path.from(path);
    gradientPath.lineTo(points.last.dx, padding + chartHeight);
    gradientPath.lineTo(padding, padding + chartHeight);
    gradientPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF5ECFB8).withValues(alpha: 0.3),
        const Color(0xFF5ECFB8).withValues(alpha: 0.0),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(padding, padding, chartWidth, chartHeight),
      );

    canvas.drawPath(gradientPath, paint);

    // Draw line
    final strokePaint = Paint()
      ..color = const Color(0xFF5ECFB8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF5ECFB8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, dotBorderPaint);
    }

    // Draw X-axis labels
    for (int i = 1; i <= maxMonths; i += 2) {
      // Show every other month
      final x = padding + (i - 1) * xStep;
      String label;
      if (isChinese) {
        label = '$i月';
      } else {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        label = months[i - 1];
      }

      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _JoyTrendChartPainter oldDelegate) {
    return oldDelegate.monthlyData != monthlyData ||
        oldDelegate.isPercent != isPercent;
  }
}
