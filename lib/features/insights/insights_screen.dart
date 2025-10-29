import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';

// Metric Card Data Model
class MetricCardData {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const MetricCardData({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

// Insights Screen with month/year selection and reports
class InsightsScreen extends StatefulWidget {
  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<DeepCleaningSession> deepCleaningSessions;
  final int streak;

  const InsightsScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.deepCleaningSessions,
    required this.streak,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  String _getMonthName(int month, bool isChinese) {
    if (isChinese) {
      return '$month月';
    }
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

  void _showMonthYearPicker(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempYear = _selectedYear;
        int tempMonth = _selectedMonth;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isChinese ? '选择时间段' : 'Select Period'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setDialogState(() {
                              tempYear--;
                            });
                          },
                        ),
                        Text(
                          '$tempYear',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setDialogState(() {
                              tempYear++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final month = index + 1;
                        final isSelected = month == tempMonth;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              tempMonth = month;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _getMonthName(month, isChinese),
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isChinese ? '取消' : 'Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedYear = tempYear;
                      _selectedMonth = tempMonth;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(isChinese ? '确认' : 'Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<DeclutterItem> _getFilteredItems() {
    return widget.declutteredItems.where((item) {
      return item.createdAt.year == _selectedYear &&
          item.createdAt.month == _selectedMonth;
    }).toList();
  }

  List<ResellItem> _getFilteredResellItems() {
    return widget.resellItems.where((item) {
      return item.createdAt.year == _selectedYear &&
          item.createdAt.month == _selectedMonth;
    }).toList();
  }

  List<DeepCleaningSession> _getFilteredSessions() {
    return widget.deepCleaningSessions.where((session) {
      return session.startTime.year == _selectedYear &&
          session.startTime.month == _selectedMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    final filteredItems = _getFilteredItems();
    final filteredSessions = _getFilteredSessions();
    final filteredResellItems = _getFilteredResellItems();

    // Calculate metrics
    final totalItems = filteredItems.length;
    final recycleCount = filteredItems
        .where((item) => item.status == DeclutterStatus.recycle)
        .length;
    final donateCount = filteredItems
        .where((item) => item.status == DeclutterStatus.donate)
        .length;
    final soldCount = filteredResellItems
        .where((item) => item.status == ResellStatus.sold)
        .length;
    final carbonSaved =
        (recycleCount * 2.5) + (donateCount * 5.0) + (soldCount * 7.5);
    final spaceFreed = filteredItems.length * 0.1;
    final totalRevenue = filteredResellItems
        .where((item) => item.status == ResellStatus.sold)
        .fold<double>(0.0, (sum, item) => sum + (item.soldPrice ?? 0));
    final avgItemsPerSession = filteredSessions.isNotEmpty
        ? (filteredItems.length / filteredSessions.length)
        : 0.0;
    final avgMood =
        filteredSessions.isNotEmpty &&
            filteredSessions.where((s) => s.moodIndex != null).isNotEmpty
        ? filteredSessions
                  .where((s) => s.moodIndex != null)
                  .fold<double>(
                    0.0,
                    (sum, s) => sum + (s.moodIndex ?? 0).toDouble(),
                  ) /
              filteredSessions.where((s) => s.moodIndex != null).length
        : 0.0;
    final avgFocus =
        filteredSessions.isNotEmpty &&
            filteredSessions.where((s) => s.focusIndex != null).isNotEmpty
        ? filteredSessions
                  .where((s) => s.focusIndex != null)
                  .fold<double>(
                    0.0,
                    (sum, s) => sum + (s.focusIndex ?? 0).toDouble(),
                  ) /
              filteredSessions.where((s) => s.focusIndex != null).length
        : 0.0;

    final metricsCards = <MetricCardData>[
      MetricCardData(
        value: totalItems.toString(),
        label: isChinese ? '物品已整理' : 'Items Decluttered',
        icon: Icons.inventory_2,
        color: const Color(0xFF6B5CE7),
      ),
      MetricCardData(
        value: '${widget.streak}',
        label: isChinese ? '连续天数' : 'Day Streak',
        icon: Icons.local_fire_department,
        color: const Color(0xFFFF6B35),
      ),
      MetricCardData(
        value: '¥${totalRevenue.toStringAsFixed(0)}',
        label: isChinese ? '创造价值' : 'Value Created',
        icon: Icons.monetization_on,
        color: const Color(0xFFFFD700),
      ),
      MetricCardData(
        value: '${carbonSaved.toStringAsFixed(1)}kg',
        label: isChinese ? 'CO₂ 减排' : 'CO₂ Reduced',
        icon: Icons.eco,
        color: const Color(0xFF4CAF50),
      ),
      MetricCardData(
        value: '${spaceFreed.toStringAsFixed(1)}m²',
        label: isChinese ? '空间释放' : 'Space Freed',
        icon: Icons.space_dashboard,
        color: const Color(0xFF2196F3),
      ),
      MetricCardData(
        value: avgItemsPerSession.toStringAsFixed(1),
        label: isChinese ? '效率指数' : 'Efficiency',
        icon: Icons.bolt,
        color: const Color(0xFFFF9800),
      ),
      if (avgMood > 0)
        MetricCardData(
          value: '${avgMood.toStringAsFixed(1)}/10',
          label: isChinese ? '幸福指数' : 'Happiness',
          icon: Icons.sentiment_very_satisfied,
          color: const Color(0xFFE91E63),
        ),
      if (avgFocus > 0)
        MetricCardData(
          value: '${avgFocus.toStringAsFixed(1)}/10',
          label: isChinese ? '专注力' : 'Focus',
          icon: Icons.center_focus_strong,
          color: const Color(0xFF9C27B0),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insights),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Month/Year Selector Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B5CE7), Color(0xFF5ECFB8)],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChinese ? '报告时间段' : 'Report Period',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showMonthYearPicker(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_getMonthName(_selectedMonth, isChinese)} $_selectedYear',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Monthly Achievement Section
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isChinese ? '月度成就' : 'Monthly Achievement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ScrollableMetricsCarousel(metrics: metricsCards),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Scrollable Metrics Carousel with center zoom effect
class ScrollableMetricsCarousel extends StatefulWidget {
  final List<MetricCardData> metrics;

  const ScrollableMetricsCarousel({super.key, required this.metrics});

  @override
  State<ScrollableMetricsCarousel> createState() =>
      _ScrollableMetricsCarouselState();
}

class _ScrollableMetricsCarouselState extends State<ScrollableMetricsCarousel> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.metrics.length,
      itemBuilder: (context, index) {
        final metric = widget.metrics[index];
        // Calculate scale based on distance from center
        final diff = (index - _currentPage).abs();
        final scale = (1 - (diff * 0.3)).clamp(0.7, 1.0);
        final opacity = (1 - (diff * 0.5)).clamp(0.3, 1.0);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    metric.color.withValues(alpha: 0.15),
                    metric.color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: metric.color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: metric.color.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(metric.icon, size: 36, color: metric.color),
                    const SizedBox(height: 12),
                    Text(
                      metric.value,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: metric.color,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        metric.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
