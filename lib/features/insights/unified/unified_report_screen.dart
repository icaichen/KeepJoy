import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/unified/models/enhanced_report_models.dart';
import 'package:keepjoy_app/features/insights/unified/organize_detail_screen.dart';
import 'package:keepjoy_app/features/insights/unified/memory_detail_screen.dart';
import 'package:keepjoy_app/features/insights/unified/resell_detail_screen.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';

class UnifiedReportScreen extends StatefulWidget {
  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<Memory> memories;
  final List<DeepCleaningSession> deepCleaningSessions;

  const UnifiedReportScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.memories,
    required this.deepCleaningSessions,
  });

  @override
  State<UnifiedReportScreen> createState() => _UnifiedReportScreenState();
}

class _UnifiedReportScreenState extends State<UnifiedReportScreen> {
  late int _selectedYear;
  late List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    _initializeYears();
  }

  void _initializeYears() {
    final now = DateTime.now();
    final years = <int>{now.year};
    
    for (final item in widget.declutteredItems) {
      years.add(item.createdAt.year);
    }
    for (final item in widget.resellItems) {
      years.add(item.createdAt.year);
    }
    for (final memory in widget.memories) {
      years.add(memory.createdAt.year);
    }
    for (final session in widget.deepCleaningSessions) {
      years.add(session.startTime.year);
    }
    
    _availableYears = years.toList()..sort((a, b) => b.compareTo(a));
    _selectedYear = now.year;
  }

  EnhancedUnifiedReportData get _reportData => EnhancedUnifiedReportData(
    declutteredItems: widget.declutteredItems,
    resellItems: widget.resellItems,
    memories: widget.memories,
    deepCleaningSessions: widget.deepCleaningSessions,
    year: _selectedYear,
  );

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final isChinese = Localizations.localeOf(context).languageCode.startsWith('zh');
    final reportData = _reportData;
    final topPadding = responsive.safeAreaPadding.top;
    final horizontalPadding = responsive.horizontalPadding;
    
    return Scaffold(
      backgroundColor: ReportUI.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: topPadding + 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFB794F6),
                        Color(0xFFF3EBFF),
                        ReportUI.backgroundColor,
                      ],
                      stops: [0.0, 0.35, 0.65],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isChinese ? '年度总结' : 'Yearly Summary',
                                    style: ReportTextStyles.screenTitle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isChinese ? '整理 · 回忆 · 二手' : 'Declutter · Memories · Resale',
                                    style: ReportTextStyles.screenSubtitle,
                                  ),
                                ],
                              ),
                            ),
                            _buildYearSelector(),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildStatRow(context, isChinese, reportData),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                Text(
                  isChinese ? '详细数据' : 'Details',
                  style: ReportTextStyles.sectionHeader,
                ),
                const SizedBox(height: 4),
                Text(
                  isChinese ? '查看各维度完整分析' : 'View complete analysis',
                  style: ReportTextStyles.sectionSubtitle,
                ),
                const SizedBox(height: 16),
                _buildDimensionCard(
                  context: context,
                  title: isChinese ? '整理统计' : 'Declutter Stats',
                  subtitle: isChinese 
                      ? '${reportData.declutterStats.totalItems} 件 · 心动率 ${reportData.declutterStats.joyRate.toStringAsFixed(0)}%'
                      : '${reportData.declutterStats.totalItems} items · ${reportData.declutterStats.joyRate.toStringAsFixed(0)}% joy',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF5ECFB8),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrganizeDetailScreen(data: reportData))),
                ),
                const SizedBox(height: 12),
                _buildDimensionCard(
                  context: context,
                  title: isChinese ? '回忆统计' : 'Memory Stats',
                  subtitle: isChinese
                      ? '${reportData.memoryStats.totalCount} 个回忆'
                      : '${reportData.memoryStats.totalCount} memories',
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFFB794F6),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MemoryDetailScreen(data: reportData))),
                ),
                const SizedBox(height: 12),
                _buildDimensionCard(
                  context: context,
                  title: isChinese ? '二手统计' : 'Resale Stats',
                  subtitle: isChinese
                      ? '售出 ${reportData.resellStats.soldCount} 件 · 收入 ${reportData.resellStats.totalRevenue.toStringAsFixed(0)}'
                      : '${reportData.resellStats.soldCount} sold · ${reportData.resellStats.totalRevenue.toStringAsFixed(0)} revenue',
                  icon: Icons.payments_outlined,
                  color: const Color(0xFFFFD93D),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResellDetailScreen(data: reportData))),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black87),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
          items: _availableYears.map((year) => DropdownMenuItem(value: year, child: Text('$year'))).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedYear = value);
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, bool isChinese, EnhancedUnifiedReportData reportData) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.inventory_2_outlined, const Color(0xFF5ECFB8), '${reportData.declutterStats.totalItems}', isChinese ? '整理' : 'Declutter')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.photo_library_outlined, const Color(0xFFB794F6), '${reportData.memoryStats.totalCount}', isChinese ? '回忆' : 'Memories')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.payments_outlined, const Color(0xFFFFD93D), reportData.resellStats.totalRevenue.toStringAsFixed(0), isChinese ? '收入' : 'Revenue')),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: ReportUI.statCardDecoration,
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: ReportTextStyles.statValueSmall),
          const SizedBox(height: 2),
          Text(label, style: ReportTextStyles.label),
        ],
      ),
    );
  }

  Widget _buildDimensionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ReportUI.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
