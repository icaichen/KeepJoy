import 'package:flutter/material.dart';
import 'package:keepjoy_app/features/insights/memory_lane_report_screen.dart';
import 'package:keepjoy_app/features/insights/resell_analysis_report_screen.dart';
import 'package:keepjoy_app/features/insights/widgets/report_ui_constants.dart';
import 'package:keepjoy_app/features/insights/yearly_reports_screen.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/utils/responsive_utils.dart';

class UnifiedReportScreen extends StatelessWidget {
  const UnifiedReportScreen({
    super.key,
    required this.declutteredItems,
    required this.resellItems,
    required this.memories,
    required this.deepCleaningSessions,
  });

  final List<DeclutterItem> declutteredItems;
  final List<ResellItem> resellItems;
  final List<Memory> memories;
  final List<DeepCleaningSession> deepCleaningSessions;

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final responsive = context.responsive;
    final horizontalPadding = responsive.horizontalPadding;

    final soldCount = resellItems
        .where((item) => item.status == ResellStatus.sold)
        .length;
    final totalRevenue = resellItems
        .where((item) => item.status == ResellStatus.sold)
        .fold<double>(0, (sum, item) => sum + (item.soldPrice ?? 0));
    final areaCount = deepCleaningSessions
        .map((session) => session.area.trim())
        .where((area) => area.isNotEmpty)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: ReportUI.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EA)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                isChinese ? '整理洞察报告' : 'Declutter Insight Report',
                style: ReportTextStyles.screenTitle,
              ),
              const SizedBox(height: 4),
              Text(
                isChinese
                    ? '选择你要查看的报告分区'
                    : 'Choose a report section to continue',
                style: ReportTextStyles.screenSubtitle,
              ),
              const SizedBox(height: 18),
              _buildReportEntry(
                context: context,
                icon: Icons.home_repair_service_rounded,
                color: const Color(0xFF14B8A6),
                title: isChinese ? '整理报告' : 'Declutter Report',
                subtitle: isChinese
                    ? '共 ${declutteredItems.length} 件 · $areaCount 个区域'
                    : '${declutteredItems.length} items · $areaCount areas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => YearlyReportsScreen(
                        declutteredItems: declutteredItems,
                        resellItems: resellItems,
                        deepCleaningSessions: deepCleaningSessions,
                        memories: memories,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildReportEntry(
                context: context,
                icon: Icons.sell_rounded,
                color: const Color(0xFFF59E0B),
                title: isChinese ? '二手洞察' : 'Resell Insights',
                subtitle: isChinese
                    ? '售出 $soldCount 件 · 收入 ¥${totalRevenue.toStringAsFixed(0)}'
                    : '$soldCount sold · \$${totalRevenue.toStringAsFixed(0)} revenue',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResellAnalysisReportScreen(
                        resellItems: resellItems,
                        declutteredItems: declutteredItems,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildReportEntry(
                context: context,
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF8E88E8),
                title: isChinese ? '回忆报告' : 'Memory Report',
                subtitle: isChinese
                    ? '${memories.length} 条回忆'
                    : '${memories.length} memories',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MemoryLaneReportScreen(memories: memories),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportEntry({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EA)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ReportTextStyles.categoryTitle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReportTextStyles.sectionSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
