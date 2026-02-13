import 'package:flutter/material.dart';

class ReportUI {
  // Colors
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color borderSideColor = Color(0xFFE5E7EA);
  static const Color primaryTextColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color labelTextColor = Color(0xFF9CA3AF);

  // Measurements
  static const double cardRadius = 20.0;
  static const double statCardRadius = 16.0;
  static const double sectionGap = 20.0;
  static const double contentPadding = 20.0;
  static const double cardBlur = 15.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    const BoxShadow(
      color: Color(0x08000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Gradients for Headers
  static const List<Color> yearlyHeaderGradient = [
    Color(0xFF89CFF0),
    Color(0xFFE6F4F9),
    backgroundColor,
  ];

  static const List<Color> memoryHeaderGradient = [
    Color(0xFFB794F6),
    Color(0xFFF3EBFF),
    backgroundColor,
  ];

  static const List<Color> resellHeaderGradient = [
    Color(0xFFFFD93D),
    Color(0xFFFFF9E6),
    backgroundColor,
  ];

  // Common UI Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: borderSideColor),
    boxShadow: cardShadow,
  );

  static BoxDecoration statCardDecoration = BoxDecoration(
    color: const Color(0xFFF9FAFB),
    borderRadius: BorderRadius.circular(statCardRadius),
    border: Border.all(color: borderSideColor),
  );

  // Heatmap Colors
  static Color getHeatmapColor(int count) {
    if (count == 0) return const Color(0xFFE5E7EB);
    if (count <= 3) return const Color(0xFFD4E9F7);
    if (count <= 6) return const Color(0xFFA8D8F0);
    if (count <= 9) return const Color(0xFF7BC8E8);
    if (count <= 12) return const Color(0xFF4FB8E0);
    return const Color(0xFF23A7D8);
  }
}

class ReportTextStyles {
  // Screen Title (e.g., "Yearly Reports", "Memory Lane")
  static const TextStyle screenTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: ReportUI.primaryTextColor,
    letterSpacing: -0.5,
  );

  // Screen Subtitle (e.g., "Your year in review")
  static const TextStyle screenSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ReportUI.secondaryTextColor,
  );

  // Section Headers (e.g., "Memory Heatmap", "Joy Trend")
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 18, // TitleMedium is usually 16/18, reinforcing 18 for headers
    fontWeight: FontWeight.w700,
    color: ReportUI.primaryTextColor,
    letterSpacing: -0.5,
  );

  // Section Subtitles (e.g., "Activity this year")
  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 13, // BodySmall
    fontWeight: FontWeight.w400,
    color: ReportUI.secondaryTextColor,
  );

  // Large Stat Values (e.g., in Summary Cards like "1,240")
  static const TextStyle statValueLarge = TextStyle(
    fontSize: 24, // TitleLarge
    fontWeight: FontWeight.w800,
    color: ReportUI.primaryTextColor,
    letterSpacing: -1.0,
  );

  // Small Stat Cards Values (e.g., in grid stats)
  static const TextStyle statValueSmall = TextStyle(
    fontSize: 16, // TitleSmall
    fontWeight: FontWeight.w800,
    color: ReportUI.primaryTextColor,
  );

  // Labels (e.g., "Total Items", "Improvement")
  static const TextStyle label = TextStyle(
    fontSize: 11, // LabelSmall
    fontWeight: FontWeight.w600,
    color: ReportUI.labelTextColor,
    letterSpacing: 0.1,
  );
  
  // Body text for descriptions/insights
  static const TextStyle body = TextStyle(
    fontSize: 14, // BodyMedium
    fontWeight: FontWeight.w400,
    color: ReportUI.secondaryTextColor,
  );
}
