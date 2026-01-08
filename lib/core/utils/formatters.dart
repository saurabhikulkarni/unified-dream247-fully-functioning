import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for formatting various data types
class Formatters {
  /// Formats currency amount
  static String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    final formatted = formatter.format(amount);
    return showSymbol ? '${AppConstants.currencySymbol}$formatted' : formatted;
  }

  /// Formats date
  static String formatDate(DateTime date, {String? pattern}) {
    final formatter = DateFormat(pattern ?? AppConstants.dateFormat);
    return formatter.format(date);
  }

  /// Formats time
  static String formatTime(DateTime time) {
    final formatter = DateFormat(AppConstants.timeFormat);
    return formatter.format(time);
  }

  /// Formats date and time
  static String formatDateTime(DateTime dateTime, {String? pattern}) {
    final formatter = DateFormat(pattern ?? AppConstants.dateTimeFormat);
    return formatter.format(dateTime);
  }

  /// Formats phone number with country code
  static String formatPhoneNumber(String phone) {
    if (phone.length == AppConstants.phoneLength) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  /// Formats large numbers (e.g., 1000 -> 1K, 1000000 -> 1M)
  static String formatCompactNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// Formats duration (e.g., 90 minutes -> 1h 30m)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Truncates text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalizes first letter of each word
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
