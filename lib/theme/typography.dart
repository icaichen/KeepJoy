import 'package:flutter/material.dart';

/// KeepJoy Typography System
///
/// A comprehensive typography system optimized for bilingual (Chinese & English) content.
/// Designed for readability, hierarchy, and the app's mindful aesthetic.

class AppTypography {
  // ============================================================================
  // FONT FAMILIES
  // ============================================================================

  /// Primary font family for English text
  /// SF Pro provides excellent readability and a modern, clean aesthetic
  static const String primaryFont = 'SF Pro';

  /// Display-specific font for large titles
  /// SF Pro Display is optimized for larger sizes (≥20pt)
  static const String displayFont = 'SF Pro Display';

  /// Text-specific font for body content
  /// SF Pro Text is optimized for smaller sizes (<20pt)
  static const String textFont = 'SF Pro Text';

  /// Fallback fonts for Chinese characters
  /// Ordered by preference and availability
  static const List<String> chineseFallbacks = [
    'PingFang SC',        // Apple's modern Chinese font (best for iOS/macOS)
    'Source Han Sans CN', // Adobe's open-source Chinese font
    'Noto Sans SC',       // Google's Pan-CJK font
    'Roboto',             // Android fallback
    'Inter',              // Web fallback
  ];

  // ============================================================================
  // TEXT THEME
  // ============================================================================

  /// Complete Material 3 TextTheme with optimized styles for both languages
  static TextTheme get textTheme => const TextTheme(
    // -------------------------------------------------------------------------
    // DISPLAY STYLES - For hero content and large titles
    // Best for: App name, major section headers, splash screens
    // -------------------------------------------------------------------------
    displayLarge: TextStyle(
      fontFamily: displayFont,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,  // Tighter for English, ignored for Chinese
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontFamily: displayFont,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontFamily: displayFont,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.3,
    ),

    // -------------------------------------------------------------------------
    // HEADLINE STYLES - For section headers and important titles
    // Best for: Screen titles, card headers, section dividers
    // -------------------------------------------------------------------------
    headlineLarge: TextStyle(
      fontFamily: displayFont,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontFamily: displayFont,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontFamily: displayFont,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.3,
    ),

    // -------------------------------------------------------------------------
    // TITLE STYLES - For card titles and emphasized text
    // Best for: List item titles, dialog headers, emphasized labels
    // -------------------------------------------------------------------------
    titleLarge: TextStyle(
      fontFamily: textFont,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontFamily: textFont,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontFamily: textFont,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.4,
    ),

    // -------------------------------------------------------------------------
    // BODY STYLES - For regular content and paragraphs
    // Best for: Article text, descriptions, multi-line content
    // -------------------------------------------------------------------------
    bodyLarge: TextStyle(
      fontFamily: textFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.5,  // Extra line height for readability
    ),
    bodyMedium: TextStyle(
      fontFamily: textFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: textFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.4,
    ),

    // -------------------------------------------------------------------------
    // LABEL STYLES - For buttons and compact text
    // Best for: Button text, tabs, chips, badges
    // -------------------------------------------------------------------------
    labelLarge: TextStyle(
      fontFamily: textFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontFamily: textFont,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontFamily: textFont,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
    ),
  );

  // ============================================================================
  // CUSTOM TEXT STYLES - For special use cases
  // ============================================================================

  /// Large greeting text (e.g., "Good Morning")
  static const TextStyle greeting = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Color(0xDE000000), // black87
    letterSpacing: 0,
    height: 1.0,
  );

  /// Hero title text (e.g., "Continue Your Joy Journey")
  static const TextStyle heroTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Color(0xDE000000), // black87
    letterSpacing: 0,
    height: 1.0,
  );

  /// Section header text (e.g., "Start Declutter")
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: displayFont,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xDE000000), // black87
    letterSpacing: 0,
    height: 1.0,
  );

  /// Card title text
  static const TextStyle cardTitle = TextStyle(
    fontFamily: textFont,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Color(0xDE000000), // black87
    letterSpacing: 0,
    height: 1.0,
  );

  /// Subtitle text (secondary information)
  static const TextStyle subtitle = TextStyle(
    fontFamily: textFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0x8A000000), // black54
    letterSpacing: 0,
    height: 1.0,
  );

  /// Caption text (smallest text, metadata)
  static const TextStyle caption = TextStyle(
    fontFamily: textFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0x8A000000), // black54
    letterSpacing: 0,
    height: 1.4,
  );

  /// Metric value (large numbers in cards)
  static const TextStyle metricValue = TextStyle(
    fontFamily: displayFont,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  /// Metric label (small text under numbers)
  static const TextStyle metricLabel = TextStyle(
    fontFamily: textFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  /// Button text (on gradient cards)
  static const TextStyle buttonText = TextStyle(
    fontFamily: textFont,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.0,
  );

  /// Quote text (italic body text)
  static const TextStyle quote = TextStyle(
    fontFamily: textFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Quote attribution (author name)
  static const TextStyle quoteAttribution = TextStyle(
    fontFamily: textFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0,
    height: 1.0,
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Apply color to a TextStyle
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to a TextStyle
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Create theme-aware text style (automatically use theme colors)
  static TextStyle primary(BuildContext context) {
    return TextStyle(
      fontFamily: textFont,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  static TextStyle onPrimary(BuildContext context) {
    return TextStyle(
      fontFamily: textFont,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }
}

/// Extension methods for easy text styling
extension TextStyleExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text regular
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// Make text italic
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// Apply primary color
  TextStyle primary(BuildContext context) {
    return copyWith(color: Theme.of(context).colorScheme.primary);
  }

  /// Apply black87 (87% opacity)
  TextStyle get black87 => copyWith(color: const Color(0xDE000000));

  /// Apply black54 (54% opacity)
  TextStyle get black54 => copyWith(color: const Color(0x8A000000));

  /// Apply white
  TextStyle get white => copyWith(color: Colors.white);
}
