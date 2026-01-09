/// Stub file for non-web platforms
/// This file is never used - the conditional import will select mobile.dart or web.dart
library;

class RazorpayPlatform {
  void init({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
    required Function() onDismiss,
  }) {
    throw UnsupportedError('Razorpay not supported on this platform');
  }

  void open(Map<String, dynamic> options) {
    throw UnsupportedError('Razorpay not supported on this platform');
  }

  void dispose() {
    // No-op
  }
}
