import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/utils/responsive_helper.dart';

/// Extension on BuildContext for responsive helpers
extension ResponsiveContext on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get responsive padding
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);

  /// Get responsive spacing
  double get responsiveSpacing => ResponsiveHelper.getResponsiveSpacing(this);

  /// Check if tablet
  bool get isTablet => ResponsiveHelper.isTablet(this);

  /// Check if phone
  bool get isPhone => ResponsiveHelper.isPhone(this);

  /// Check if landscape
  bool get isLandscape => ResponsiveHelper.isLandscape(this);

  /// Check if portrait
  bool get isPortrait => ResponsiveHelper.isPortrait(this);

  /// Get grid cross axis count
  int get gridCrossAxisCount => ResponsiveHelper.getGridCrossAxisCount(this);

  /// Get responsive height percentage
  double height(double percentage) => ResponsiveHelper.getResponsiveHeight(this, percentage);

  /// Get responsive width percentage
  double width(double percentage) => ResponsiveHelper.getResponsiveWidth(this, percentage);

  /// Get responsive font size
  double fontSize(double baseSize, {double minSize = 10, double maxSize = 40}) =>
      ResponsiveHelper.getResponsiveFontSize(this,
          baseSize: baseSize, minSize: minSize, maxSize: maxSize);
}
