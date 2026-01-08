/// Application-wide constants
class AppConstants {
  // App info
  static const String appName = 'Unified Dream247';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Animation durations
  static const int defaultAnimationDuration = 300;
  static const int shortAnimationDuration = 150;
  static const int longAnimationDuration = 500;
  
  // Image sizes
  static const int thumbnailSize = 100;
  static const int mediumImageSize = 300;
  static const int largeImageSize = 600;
  
  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  
  // Date formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  
  // Payment
  static const String razorpayKey = 'YOUR_RAZORPAY_KEY';
  
  // Phone validation
  static const String phonePattern = r'^[6-9]\d{9}$';
  static const int phoneLength = 10;
  static const int otpLength = 6;
  
  // Min/Max values
  static const double minAmount = 10.0;
  static const double maxAmount = 100000.0;
}
