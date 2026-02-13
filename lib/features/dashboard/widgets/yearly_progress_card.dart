import 'package:flutter/material.dart';
import '../../insights/widgets/report_ui_constants.dart';

class YearlyProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const YearlyProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ReportUI.cardRadius),
        boxShadow: ReportUI.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ReportUI.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // 1. Subtle Gradient Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors.map((c) => c.withValues(alpha: 0.4)).toList(),
                    ),
                  ),
                ),
              ),

              // 2. Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Glassy Icon Container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: ReportTextStyles.sectionHeader.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: ReportTextStyles.sectionSubtitle.copyWith(
                              color: ReportUI.secondaryTextColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: ReportUI.secondaryTextColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
