import 'package:flutter/material.dart';

/// Helper class for responsive design across all devices
class ResponsiveHelper {
  /// Get responsive padding based on screen width
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 400) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    } else if (width < 600) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    required double baseSize,
    double minSize = 10,
    double maxSize = 40,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scaleFactor = width / 375; // Base design width
    final size = baseSize * scaleFactor;
    
    return size.clamp(minSize, maxSize);
  }

  /// Get responsive height based on screen height
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  /// Get responsive width based on screen width
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device is a tablet (width >= 600)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Check if device is a phone (width < 600)
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 400) {
      return 2;
    } else if (width < 600) {
      return 2;
    } else if (width < 900) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 400) {
      return 8;
    } else if (width < 600) {
      return 12;
    } else if (width < 900) {
      return 16;
    } else {
      return 20;
    }
  }

  /// Get device pixel ratio for image scaling
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }
}
