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
  /// Using system fonts for better web compatibility
  static const String primaryFont = 'Roboto';

  /// Display-specific font for large titles
  /// Using Roboto for cross-platform consistency
  static const String displayFont = 'Roboto';

  /// Text-specific font for body content
  /// Using Roboto for cross-platform consistency
  static const String textFont = 'Roboto';

  /// Fallback fonts for Chinese characters
  /// Ordered by preference and availability
  static const List<String> chineseFallbacks = [
    'NotoSansSC', // Bundled fallback for Simplified Chinese
    'PingFang SC', // Apple's modern Chinese font (best for iOS/macOS)
    'Source Han Sans CN', // Adobe's open-source Chinese font
    'Noto Sans SC', // System-installed Pan-CJK font name
    'Roboto', // Android fallback
    'Inter', // Web fallback
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
      letterSpacing: -1.0, // Tighter for English, ignored for Chinese
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
      height: 1.5, // Extra line height for readability
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
  // COMPATIBILITY ALIASES
  // ============================================================================
  // Keep old call sites working:
  // - AppTypography.titleMedium.copyWith(...)
  // - AppTypography.titleMedium('text', context: ...)
  static final displayLarge = _TypographyToken(() => textTheme.displayLarge!);
  static final displayMedium = _TypographyToken(() => textTheme.displayMedium!);
  static final displaySmall = _TypographyToken(() => textTheme.displaySmall!);
  static final headlineLarge = _TypographyToken(() => textTheme.headlineLarge!);
  static final headlineMedium = _TypographyToken(
    () => textTheme.headlineMedium!,
  );
  static final headlineSmall = _TypographyToken(() => textTheme.headlineSmall!);
  static final titleLarge = _TypographyToken(() => textTheme.titleLarge!);
  static final titleMedium = _TypographyToken(() => textTheme.titleMedium!);
  static final titleSmall = _TypographyToken(() => textTheme.titleSmall!);
  static final bodyLarge = _TypographyToken(() => textTheme.bodyLarge!);
  static final bodyMedium = _TypographyToken(() => textTheme.bodyMedium!);
  static final bodySmall = _TypographyToken(() => textTheme.bodySmall!);
  static final labelLarge = _TypographyToken(() => textTheme.labelLarge!);
  static final labelMedium = _TypographyToken(() => textTheme.labelMedium!);
  static final labelSmall = _TypographyToken(() => textTheme.labelSmall!);

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

class _TypographyToken {
  final TextStyle Function() _styleBuilder;

  _TypographyToken(this._styleBuilder);

  TextStyle get style => _styleBuilder();

  TextStyle copyWith({
    bool? inherit,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    List<FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
  }) {
    return style.copyWith(
      inherit: inherit,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      debugLabel: debugLabel,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
  }

  Widget call(
    String text, {
    required BuildContext context,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: style.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
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
