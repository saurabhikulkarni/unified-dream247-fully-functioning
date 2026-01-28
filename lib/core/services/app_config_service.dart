import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:unified_dream247/config/api_config.dart';

/// Unified App Configuration Service
///
/// This service provides access to the getVersion API data across
/// both Shop and Fantasy modules. It ensures configuration data
/// (payment gateways, app version, settings, etc.) is available
/// throughout the entire app lifecycle.
class AppConfigService {
  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  SharedPreferences? _prefs;
  Map<String, dynamic>? _versionData;
  bool _isInitialized = false;

  /// Initialize the service with SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();

    // Try to load cached version data
    final cached = _prefs?.getString('fantasy_version_data');
    if (cached != null && cached.isNotEmpty) {
      try {
        _versionData = jsonDecode(cached);
        debugPrint('✅ [APP_CONFIG] Loaded cached version data');
      } catch (e) {
        debugPrint('⚠️ [APP_CONFIG] Failed to parse cached version data: $e');
      }
    }
    _isInitialized = true;
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get the full version data response
  Map<String, dynamic>? get versionData => _versionData;

  /// Get the data object from version response
  Map<String, dynamic>? get data {
    if (_versionData == null) return null;
    return _versionData!['data'] as Map<String, dynamic>?;
  }

  /// Check if data is loaded
  bool get hasData => _versionData != null && _versionData!['success'] == true;

  /// Fetch and store version data from API
  ///
  /// This should be called early in the app lifecycle to ensure
  /// configuration data is available when needed.
  Future<Map<String, dynamic>?> fetchVersionData({String? authToken}) async {
    try {
      debugPrint('🔄 [APP_CONFIG] Fetching version data...');

      // Get token from prefs if not provided
      final token = authToken ?? _prefs?.getString('token');

      final response = await http.get(
        Uri.parse(ApiConfig.fantasyVersionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));

      debugPrint(
          '🔄 [APP_CONFIG] Version API Response: ${response.statusCode}',);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store in memory
        _versionData = data;

        // Cache to SharedPreferences
        await _prefs?.setString('fantasy_version_data', response.body);

        debugPrint('✅ [APP_CONFIG] Version data fetched and cached');
        return data;
      } else {
        debugPrint('❌ [APP_CONFIG] Version API failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [APP_CONFIG] Error fetching version data: $e');
      return null;
    }
  }

  /// Get payment gateway configuration for Android
  Map<String, dynamic>? get androidPaymentGateway {
    return data?['androidpaymentgateway'] as Map<String, dynamic>?;
  }

  /// Get payment gateway configuration for iOS
  Map<String, dynamic>? get iosPaymentGateway {
    return data?['iospaymentgateway'] as Map<String, dynamic>?;
  }

  /// Check if Razorpay is enabled
  bool get isRazorpayEnabled {
    final gateway = androidPaymentGateway;
    if (gateway == null) return false;
    return gateway['isRazorPay']?['status'] == true;
  }

  /// Get Razorpay min/max amounts
  Map<String, int>? get razorpayLimits {
    final gateway = androidPaymentGateway;
    if (gateway == null) return null;
    final razorpay = gateway['isRazorPay'];
    if (razorpay == null) return null;
    return {
      'min': razorpay['min'] ?? 0,
      'max': razorpay['max'] ?? 0,
    };
  }

  /// Get app version from server
  int? get serverVersion => data?['version'] as int?;

  /// Get Android version requirement
  int? get androidVersion => data?['androidversion'] as int?;

  /// Get iOS version requirement
  int? get iosVersion => data?['iOSversion'] as int?;

  /// Check if app is under maintenance
  bool get isUnderMaintenance => (data?['maintenance'] ?? 0) != 0;

  /// Check if iOS is under maintenance
  bool get isIosUnderMaintenance => (data?['iOSmaintenance'] ?? 0) != 0;

  /// Get minimum withdrawal amount
  int? get minWithdraw => data?['minwithdraw'] as int?;

  /// Get maximum withdrawal amount
  int? get maxWithdraw => data?['maxwithdraw'] as int?;

  /// Get minimum add amount
  int? get minAdd => data?['minadd'] as int?;

  /// Get referral bonus amount
  int? get referBonus => data?['refer_bonus'] as int?;

  /// Get signup bonus amount
  int? get signupBonus => data?['signup_bonus'] as int?;

  /// Get support mobile number
  String? get supportMobile => data?['supportmobile'] as String?;

  /// Get support email
  String? get supportEmail => data?['supportemail'] as String?;

  /// Check if withdrawal is disabled
  bool get isWithdrawDisabled => (data?['disableWithdraw'] ?? 0) != 0;

  /// Get refer URL template
  String? get referUrl => data?['referurl'] as String?;

  /// Get refer message template
  String? get referMessage => data?['refermessage'] as String?;

  /// Get contest share message template
  String? get contestShareMessage => data?['contestsharemessage'] as String?;

  /// Clear cached data (e.g., on logout)
  Future<void> clearCache() async {
    _versionData = null;
    await _prefs?.remove('fantasy_version_data');
    debugPrint('🗑️ [APP_CONFIG] Cache cleared');
  }

  /// Force refresh data from server
  Future<Map<String, dynamic>?> refresh({String? authToken}) async {
    return fetchVersionData(authToken: authToken);
  }
}
