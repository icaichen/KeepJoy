import 'package:flutter/material.dart';

/// Utility class for responsive sizing across different device sizes
class ResponsiveUtils {
  final BuildContext context;
  late final Size screenSize;
  late final double screenWidth;
  late final double screenHeight;
  late final EdgeInsets safeAreaPadding;

  ResponsiveUtils(this.context) {
    screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    safeAreaPadding = MediaQuery.of(context).padding;
  }

  /// Returns true if the device is considered small (iPhone SE, etc.)
  bool get isSmallDevice => screenWidth < 375;

  /// Returns true if the device is considered medium (iPhone 14, etc.)
  bool get isMediumDevice => screenWidth >= 375 && screenWidth < 430;

  /// Returns true if the device is considered large (iPhone Pro Max, etc.)
  bool get isLargeDevice => screenWidth >= 430;

  /// Scale font size based on screen width
  /// Base width is 390 (iPhone 14 Pro)
  double scaledFontSize(double baseSize) {
    const baseWidth = 390.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.85, 1.15);
    return baseSize * scaleFactor;
  }

  /// Scale spacing based on screen width
  double scaledSpacing(double baseSpacing) {
    const baseWidth = 390.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.9, 1.1);
    return baseSpacing * scaleFactor;
  }

  /// Get responsive horizontal padding
  double get horizontalPadding {
    if (isSmallDevice) return 16.0;
    if (isMediumDevice) return 20.0;
    return 24.0;
  }

  /// Get responsive large title font size
  double get largeTitleFontSize {
    if (isSmallDevice) return 28.0;
    if (isMediumDevice) return 32.0;
    return 34.0;
  }

  /// Get responsive title font size
  double get titleFontSize {
    if (isSmallDevice) return 18.0;
    if (isMediumDevice) return 20.0;
    return 22.0;
  }

  /// Get responsive body font size
  double get bodyFontSize {
    if (isSmallDevice) return 13.0;
    if (isMediumDevice) return 15.0;
    return 16.0;
  }

  /// Get responsive caption font size
  double get captionFontSize {
    if (isSmallDevice) return 11.0;
    if (isMediumDevice) return 12.0;
    return 13.0;
  }

  /// Get responsive header height
  /// This is the content area height (not including safe area padding)
  double get headerHeight {
    // Fixed height for header content area
    // This doesn't include safe area - that's added separately
    return 100.0;
  }

  /// Get responsive collapsed header height
  double get collapsedHeaderHeight {
    return safeAreaPadding.top + kToolbarHeight;
  }
}

/// Extension on BuildContext for easy access to responsive utils
extension ResponsiveContext on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}
