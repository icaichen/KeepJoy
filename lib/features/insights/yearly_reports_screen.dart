import 'package:flutter/material.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/resell_item.dart';

class YearlyReportsScreen extends StatefulWidget {
  const YearlyReportsScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.deepCleaningSessions,
  });

  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;

  @override
  State<YearlyReportsScreen> createState() => _YearlyReportsScreenState();
}

class _YearlyReportsScreenState extends State<YearlyReportsScreen> {
  bool _showJoyPercent = true; // true = Joy Percent, false = Joy Count
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
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final topPadding = MediaQuery.of(context).padding.top;
    final pageName = isChinese ? '年度报告' : 'Yearly Reports';

    // Calculate past 12 months activity (for heatmap)
    final past12MonthsActivity = <String, int>{};
    String? mostActiveMonth;
    int mostActiveCount = 0;
    int peakActivity = 0;

    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(monthDate.year, monthDate.month, 1);
      final monthEnd = monthDate.month == 12
          ? DateTime(monthDate.year + 1, 1, 1)
          : DateTime(monthDate.year, monthDate.month + 1, 1);

      final count = widget.declutteredItems.where((item) =>
        item.createdAt.isAfter(monthStart.subtract(const Duration(days: 1))) &&
        item.createdAt.isBefore(monthEnd)
      ).length + widget.deepCleaningSessions.where((session) =>
        session.startTime.isAfter(monthStart.subtract(const Duration(days: 1))) &&
        session.startTime.isBefore(monthEnd)
      ).length;

      final monthKey = '${monthDate.year}-${monthDate.month}';
      past12MonthsActivity[monthKey] = count;

      if (count > mostActiveCount) {
        mostActiveCount = count;
        mostActiveMonth = _getMonthName(monthDate.month, isChinese);
      }

      if (count > peakActivity) {
        peakActivity = count;
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int currentStreak = 0;
    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = '${monthDate.year}-${monthDate.month}';
      final count = past12MonthsActivity[monthKey] ?? 0;

      if (count > 0) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    final maxActivityPast12 = past12MonthsActivity.values.isEmpty
        ? 1
        : past12MonthsActivity.values.reduce((a, b) => a > b ? a : b);

    // Calculate yearly stats
    final yearlyItems = widget.declutteredItems
        .where((item) => item.createdAt.isAfter(yearStart))
        .toList();

    final yearlySessions = widget.deepCleaningSessions
        .where((session) => session.startTime.isAfter(yearStart))
        .toList();

    // Calculate area counts
    final areaCounts = <String, int>{};
    for (final session in yearlySessions) {
      areaCounts.update(session.area, (value) => value + 1, ifAbsent: () => 1);
    }

    // Calculate category counts
    final categoryCounts = <String, int>{};
    for (final item in yearlyItems) {
      final categoryName = item.category.toString().split('.').last;
      categoryCounts[categoryName] = (categoryCounts[categoryName] ?? 0) + 1;
    }

    // Calculate Joy Index
    final itemsWithJoy = yearlyItems.where((item) => item.joyLevel != null).toList();
    final avgJoyIndex = itemsWithJoy.isEmpty
        ? 0.0
        : itemsWithJoy.map((item) => item.joyLevel!).reduce((a, b) => a + b) / itemsWithJoy.length;

    // Disposal method counts
    final resellCount = yearlyItems.where((item) => item.status == DeclutterStatus.resell).length;
    final recycleCount = yearlyItems.where((item) => item.status == DeclutterStatus.recycle).length;
    final donateCount = yearlyItems.where((item) => item.status == DeclutterStatus.donate).length;
    final discardCount = yearlyItems.where((item) => item.status == DeclutterStatus.discard).length;

    // Calculate scroll-based animations
    const titleAreaHeight = 120.0;
    final scrollProgress = (_scrollOffset / titleAreaHeight).clamp(0.0, 1.0);
    final titleOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
    final realHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
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
                  height: 500,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF89CFF0), // Blue
                        Color(0xFFE6F4F9), // Light blue
                        Colors.white,
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
                                  fontSize: 46,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Year header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE6F4F9), Color(0xFFD4E9F3)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${now.year}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF89CFF0),
                    ),
                  ),
                  Text(
                    isChinese ? '年度整理总结' : 'Annual Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Declutter Heatmap (Past 12 months)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChinese ? '整理热力图' : 'Declutter Heatmap',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isChinese ? '过去12个月的活动' : 'Activity in past 12 months',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2 rows of 6 months each
                  Column(
                    children: [
                      // First row
                      Row(
                        children: List.generate(6, (index) {
                          final monthDate = DateTime(now.year, now.month - (11 - index), 1);
                          final monthKey = '${monthDate.year}-${monthDate.month}';
                          final activity = past12MonthsActivity[monthKey] ?? 0;
                          final intensity = maxActivityPast12 > 0 ? (activity / maxActivityPast12) : 0.0;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getHeatmapColor(intensity),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _getMonthAbbrev(monthDate.month, isChinese),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      // Second row
                      Row(
                        children: List.generate(6, (index) {
                          final monthDate = DateTime(now.year, now.month - (5 - index), 1);
                          final monthKey = '${monthDate.year}-${monthDate.month}';
                          final activity = past12MonthsActivity[monthKey] ?? 0;
                          final intensity = maxActivityPast12 > 0 ? (activity / maxActivityPast12) : 0.0;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getHeatmapColor(intensity),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _getMonthAbbrev(monthDate.month, isChinese),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Color legend
                  Row(
                    children: [
                      Text(
                        isChinese ? '较少' : 'Less',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(5, (index) {
                        return Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: _getHeatmapColor(index / 4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        isChinese ? '较多' : 'More',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Statistics - All in one row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isChinese ? '最活跃' : 'Most Active',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mostActiveMonth ?? 'N/A',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isChinese ? '最长连续' : 'Longest Streak',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isChinese ? '$longestStreak 个月' : '$longestStreak months',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isChinese ? '峰值活动' : 'Peak Activity',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isChinese ? '$peakActivity 项' : '$peakActivity items',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Joy Index Trend
            _buildJoyIndexCard(context, isChinese),
            const SizedBox(height: 20),

            // Yearly Report Card (Similar to Monthly Report)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChinese ? '年度整理报告' : 'Yearly Report',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cleaning Frequency
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFrequencyItem(
                        context,
                        icon: Icons.cleaning_services_rounded,
                        color: const Color(0xFFB794F6),
                        count: yearlySessions.length,
                        label: isChinese ? '深度整理' : 'Deep Clean',
                      ),
                      _buildFrequencyItem(
                        context,
                        icon: Icons.inventory_2_rounded,
                        color: const Color(0xFF5ECFB8),
                        count: yearlyItems.length,
                        label: isChinese ? '已整理物品' : 'Items Sorted',
                      ),
                      _buildFrequencyItem(
                        context,
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFFFF9AA2),
                        count: avgJoyIndex.toInt(),
                        label: isChinese ? '心动指数' : 'Joy Index',
                      ),
                    ],
                  ),

                  const Divider(height: 40, thickness: 1, color: Color(0xFFE5E5EA)),

                  // Categories
                  Text(
                    isChinese ? '整理类别' : 'Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  categoryCounts.isEmpty
                      ? Text(
                          isChinese ? '本年还没有分类整理记录' : 'No categorized items yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categoryCounts.entries.map((entry) {
                            return Chip(
                              label: Text('${entry.key} (${entry.value})'),
                              backgroundColor: const Color(0xFFF5F5F5),
                            );
                          }).toList(),
                        ),

                  const Divider(height: 40, thickness: 1, color: Color(0xFFE5E5EA)),

                  // Areas
                  Text(
                    isChinese ? '整理区域' : 'Cleaning Areas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  areaCounts.isEmpty
                      ? Text(
                          isChinese ? '还没有记录整理区域' : 'No areas recorded yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: areaCounts.entries.map((entry) {
                            final maxCount = areaCounts.values.reduce((a, b) => a > b ? a : b);
                            final intensity = entry.value / maxCount;
                            final color = Color.lerp(
                              const Color(0xFFE0E0E0),
                              const Color(0xFF5ECFB8),
                              intensity,
                            )!;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.key} (${entry.value})',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: intensity > 0.5 ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Letting Go Details (Disposal Methods) with Pie Chart
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChinese ? '放手详情' : 'Letting Go Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pie Chart
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: _PieChartPainter(
                          resellCount: resellCount,
                          recycleCount: recycleCount,
                          donateCount: donateCount,
                          discardCount: discardCount,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDisposalItem(
                        context,
                        label: isChinese ? '出售' : 'Sell',
                        count: resellCount,
                        color: const Color(0xFFFFD93D),
                      ),
                      _buildDisposalItem(
                        context,
                        label: isChinese ? '回收' : 'Recycle',
                        count: recycleCount,
                        color: const Color(0xFF5ECFB8),
                      ),
                      _buildDisposalItem(
                        context,
                        label: isChinese ? '捐赠' : 'Donate',
                        count: donateCount,
                        color: const Color(0xFFFF9AA2),
                      ),
                      _buildDisposalItem(
                        context,
                        label: isChinese ? '丢弃' : 'Discard',
                        count: discardCount,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
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
                        bottom: BorderSide(
                          color: Color(0xFFE5E5EA),
                          width: 0.5,
                        ),
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

  Widget _buildFrequencyItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDisposalItem(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87),
        ),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity == 0) {
      return const Color(0xFFE5E7EB); // Gray for no activity
    } else if (intensity <= 0.2) {
      return const Color(0xFFDDD6FE); // Very light purple
    } else if (intensity <= 0.4) {
      return const Color(0xFFC4B5FD); // Light purple
    } else if (intensity <= 0.6) {
      return const Color(0xFFA78BFA); // Medium purple
    } else if (intensity <= 0.8) {
      return const Color(0xFF8B5CF6); // Dark purple
    } else {
      return const Color(0xFF7C3AED); // Darkest purple
    }
  }

  String _getMonthAbbrev(int month, bool isChinese) {
    if (isChinese) {
      return '$month月';
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getMonthName(int month, bool isChinese) {
    if (isChinese) {
      return '$month月';
    }
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  Widget _buildJoyIndexCard(BuildContext context, bool isChinese) {
    // Calculate joy index trend over past 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Group items by week
    final weeklyJoyData = <int, List<int>>{}; // week -> list of joy levels
    final weeklyJoyCount = <int, int>{}; // week -> count of items with joy
    final weeklyTotalCount = <int, int>{}; // week -> total items decluttered

    for (final item in widget.declutteredItems) {
      if (item.createdAt.isAfter(thirtyDaysAgo)) {
        final weekIndex =
            now.difference(item.createdAt).inDays ~/
            7; // 0 = this week, 1 = last week, etc.
        if (weekIndex < 5) {
          // Only last 5 weeks
          weeklyTotalCount[weekIndex] = (weeklyTotalCount[weekIndex] ?? 0) + 1;

          if (item.joyLevel != null && item.joyLevel! > 0) {
            weeklyJoyData.putIfAbsent(weekIndex, () => []).add(item.joyLevel!);
            weeklyJoyCount[weekIndex] = (weeklyJoyCount[weekIndex] ?? 0) + 1;
          }
        }
      }
    }

    // Calculate weekly joy percent
    final weeklyJoyPercent = <int, double>{};
    weeklyTotalCount.forEach((week, total) {
      final joyCount = weeklyJoyCount[week] ?? 0;
      weeklyJoyPercent[week] = total > 0 ? (joyCount / total * 100) : 0.0;
    });

    // Calculate average joy percent
    final avgJoyPercent = weeklyJoyPercent.isEmpty
        ? 0.0
        : weeklyJoyPercent.values.reduce((a, b) => a + b) /
              weeklyJoyPercent.length;

    // Calculate total joy count
    final itemsWithJoy = widget.declutteredItems
        .where((item) => item.joyLevel != null && item.joyLevel! > 0)
        .toList();
    final totalJoyCount = itemsWithJoy.length;

    // Determine trend
    String trendText;
    String trendIcon;
    Color trendColor;

    if (weeklyJoyPercent.length >= 2) {
      final weeks = weeklyJoyPercent.keys.toList()..sort();
      final recentWeek = weeklyJoyPercent[weeks.first] ?? 0;
      final olderWeek = weeklyJoyPercent[weeks.last] ?? 0;

      if (recentWeek > olderWeek) {
        trendText = isChinese ? '上升' : 'Rising';
        trendIcon = '↑';
        trendColor = const Color(0xFF4CAF50);
      } else if (recentWeek < olderWeek) {
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            isChinese ? '心动指数趋势' : 'Joy Index Trend',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isChinese ? '年度心动轨迹概览' : 'Annual joy trajectory overview',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),

          // Toggle between Joy Percent and Joy Count
          Row(
            children: [
              Text(
                isChinese ? '趋势指标' : 'Trend Metric',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showJoyPercent = true;
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _showJoyPercent
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _showJoyPercent
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
                            alignment: Alignment.center,
                            child: Text(
                              isChinese ? '心动比例' : 'Joy Percent',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: _showJoyPercent
                                        ? Colors.black87
                                        : Colors.black45,
                                    fontWeight: _showJoyPercent
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showJoyPercent = false;
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: !_showJoyPercent
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: !_showJoyPercent
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
                            alignment: Alignment.center,
                            child: Text(
                              isChinese ? '心动次数' : 'Joy Count',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: !_showJoyPercent
                                        ? Colors.black87
                                        : Colors.black45,
                                    fontWeight: !_showJoyPercent
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart
          if (weeklyJoyPercent.isEmpty && weeklyJoyCount.isEmpty)
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Text(
                isChinese
                    ? '还没有足够的数据来显示趋势'
                    : 'Not enough data to show trend yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _JoyTrendChartPainter(
                  weeklyData: _showJoyPercent
                      ? weeklyJoyPercent
                      : weeklyJoyCount.map((k, v) => MapEntry(k, v.toDouble())),
                  maxWeeks: 5,
                  isPercent: _showJoyPercent,
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
                label: isChinese ? '平均心动比例' : 'Avg Joy %',
                value: '${avgJoyPercent.toStringAsFixed(0)}%',
                color: const Color(0xFFFF9AA2),
              ),
              _buildStatItem(
                context,
                label: isChinese ? '总心动次数' : 'Total Joy',
                value: totalJoyCount.toString(),
                color: const Color(0xFF5ECFB8),
              ),
              _buildStatItem(
                context,
                label: isChinese ? '趋势分析' : 'Trend',
                value: '$trendIcon $trendText',
                color: trendColor,
              ),
            ],
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Pie Chart Painter for disposal methods
class _PieChartPainter extends CustomPainter {
  final int resellCount;
  final int recycleCount;
  final int donateCount;
  final int discardCount;

  _PieChartPainter({
    required this.resellCount,
    required this.recycleCount,
    required this.donateCount,
    required this.discardCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final total = resellCount + recycleCount + donateCount + discardCount;

    // If no data, show empty circle
    if (total == 0) {
      final paint = Paint()
        ..color = const Color(0xFFE5E5EA)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.fill;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    // Draw resell segment (yellow)
    if (resellCount > 0) {
      final sweepAngle = (resellCount / total) * 2 * 3.14159;
      paint.color = const Color(0xFFFFD93D);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw recycle segment (teal)
    if (recycleCount > 0) {
      final sweepAngle = (recycleCount / total) * 2 * 3.14159;
      paint.color = const Color(0xFF5ECFB8);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw donate segment (pink)
    if (donateCount > 0) {
      final sweepAngle = (donateCount / total) * 2 * 3.14159;
      paint.color = const Color(0xFFFF9AA2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw discard segment (grey)
    if (discardCount > 0) {
      final sweepAngle = (discardCount / total) * 2 * 3.14159;
      paint.color = const Color(0xFF9E9E9E);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Joy trend chart painter (line chart)
class _JoyTrendChartPainter extends CustomPainter {
  final Map<int, double> weeklyData; // week index -> value (percent or count)
  final int maxWeeks;
  final bool isPercent;
  final bool isChinese;

  _JoyTrendChartPainter({
    required this.weeklyData,
    required this.maxWeeks,
    required this.isPercent,
    required this.isChinese,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weeklyData.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFFF9AA2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFFF9AA2).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = const Color(0xFFFF9AA2)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;

    final textPaint = TextPainter(textDirection: TextDirection.ltr);

    // Calculate dimensions
    final padding = 30.0;
    final bottomPadding = 40.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - padding - bottomPadding;

    // Find max value for scaling
    final maxValue = isPercent
        ? 100.0
        : weeklyData.values.reduce((a, b) => a > b ? a : b) *
              1.2; // Add 20% padding for count

    // Draw horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = padding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Prepare data points (reverse order so week 0 is on the right)
    final points = <Offset>[];
    final labels = <String>[];
    final sortedWeeks = weeklyData.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order

    // Generate month labels
    final now = DateTime.now();
    for (int i = 0; i < sortedWeeks.length; i++) {
      final week = sortedWeeks[i];
      final value = weeklyData[week]!;

      // X position: spread evenly across chart width
      final x =
          padding +
          (chartWidth * i / (sortedWeeks.length - 1).clamp(1, double.infinity));

      // Y position: scale based on max value
      final normalizedValue = value / maxValue;
      final y = padding + (chartHeight * (1 - normalizedValue));

      points.add(Offset(x, y));

      // Calculate which month this week belongs to
      final weekDate = now.subtract(Duration(days: week * 7));
      final monthLabel = '${weekDate.month}${isChinese ? '月' : 'M'}';
      labels.add(monthLabel);
    }

    if (points.isEmpty) return;

    // Draw filled area under the line
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

    // Draw the line
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

    // Draw dots and labels at each data point
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw dot
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);

      // Draw month label below
      textPaint.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPaint.layout();
      textPaint.paint(
        canvas,
        Offset(
          point.dx - textPaint.width / 2,
          size.height - bottomPadding + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
