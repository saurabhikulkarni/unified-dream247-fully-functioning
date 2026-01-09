import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/config/msg91_config.dart';

/// Service for MSG91 OTP verification via backend API
/// 
/// This service communicates with your backend server which handles
/// the actual MSG91 API calls (API key is stored securely on backend).
class Msg91Service {
  static final Msg91Service _instance = Msg91Service._internal();
  
  factory Msg91Service() {
    return _instance;
  }
  
  Msg91Service._internal();

  /// Send OTP to the given mobile number
  /// 
  /// [mobileNumber] - Mobile number in format: 10 digits (e.g., "9876543210")
  /// Returns Map with 'success' boolean and optional 'message' and 'sessionId'
  /// 
  /// Example response on success:
  /// {
  ///   'success': true,
  ///   'message': 'OTP sent successfully',
  ///   'sessionId': 'abc123...'
  /// }
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      // Clean mobile number (remove any non-digits)
      final cleanMobile = mobileNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      // Validate Indian mobile number format
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanMobile)) {
        return {
          'success': false,
          'message': 'Invalid mobile number format. Please enter a valid Indian mobile number.',
        };
      }

      if (kDebugMode) {
        print('📱 [MSG91] Sending OTP to: $cleanMobile');
      }
      
      final response = await http.post(
        Uri.parse(Msg91Config.sendOtpEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': cleanMobile,
        }),
      ).timeout(const Duration(seconds: Msg91Config.requestTimeoutSeconds));

      if (kDebugMode) {
        print('📱 [MSG91] Response status: ${response.statusCode}');
        print('📱 [MSG91] Response body: ${response.body}');
      }
      
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (kDebugMode) {
          print('✅ [MSG91] OTP sent successfully - SessionId: ${responseData['sessionId']}');
        }
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent successfully. Check your SMS inbox.',
          'sessionId': responseData['sessionId'],
        };
      } else {
        if (kDebugMode) {
          print('❌ [MSG91] Failed to send OTP: ${responseData['message']}');
        }
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send OTP. Please try again.',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MSG91] Error sending OTP: $e');
      }
      return {
        'success': false,
        'message': 'Network error. Please check your internet connection and try again.',
      };
    }
  }

  /// Verify OTP for the given mobile number
  /// 
  /// [mobileNumber] - Mobile number in format: 10 digits (e.g., "9876543210")
  /// [otp] - OTP code entered by user
  /// [sessionId] - Optional session ID returned from sendOtp (if backend uses it)
  /// 
  /// Returns Map with 'success' boolean and optional 'message'
  /// 
  /// Example response on success:
  /// {
  ///   'success': true,
  ///   'message': 'OTP verified successfully',
  ///   'token': 'auth_token_here' // Optional: if backend returns auth token
  /// }
  Future<Map<String, dynamic>> verifyOtp({
    required String mobileNumber,
    required String otp,
    String? sessionId,
  }) async {
    try {
      // Clean mobile number
      final cleanMobile = mobileNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      // Validate mobile number format
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanMobile)) {
        return {
          'success': false,
          'message': 'Invalid mobile number format.',
        };
      }

      // Validate OTP format (should be numeric, 4-6 digits)
      if (!RegExp(r'^\d{4,6}$').hasMatch(otp)) {
        return {
          'success': false,
          'message': 'Invalid OTP format. Please enter a valid OTP.',
        };
      }

      final requestBody = <String, dynamic>{
        'mobileNumber': cleanMobile,
        'otp': otp,
      };
      
      if (sessionId != null && sessionId.isNotEmpty) {
        requestBody['sessionId'] = sessionId;
      }

      final response = await http.post(
        Uri.parse(Msg91Config.verifyOtpEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: Msg91Config.requestTimeoutSeconds));

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP verified successfully',
          'token': responseData['token'], // Optional auth token from backend
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid OTP. Please try again.',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying OTP: $e');
      }
      return {
        'success': false,
        'message': 'Network error. Please check your internet connection and try again.',
      };
    }
  }
}

// Global instance
final msg91Service = Msg91Service();
