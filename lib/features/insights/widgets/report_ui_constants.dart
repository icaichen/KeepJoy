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
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
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
