import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unified_dream247/config/msg91_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        print('📱 [MSG91] Request URL: ${Msg91Config.sendOtpEndpoint}');
      }
      
      final response = await http.post(
        Uri.parse(Msg91Config.sendOtpEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': cleanMobile,  // Backend expects 10 digits without country code
        }),
      ).timeout(Duration(seconds: Msg91Config.requestTimeoutSeconds));

      if (kDebugMode) {
        print('📱 [MSG91] Response status: ${response.statusCode}');
        print('📱 [MSG91] Response body: ${response.body}');
      }
      
      // Handle rate limiting and other error responses
      if (response.statusCode == 429) {
        if (kDebugMode) {
          print('⏱️ [MSG91] Rate limited - too many OTP requests');
        }
        return {
          'success': false,
          'message': 'Too many OTP requests. Please wait a few minutes before trying again.',
        };
      }

      // Try to parse as JSON, handle plain text error responses
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, treat response body as error message
        if (kDebugMode) {
          print('⚠️ [MSG91] Response is not JSON, treating as plain text error');
        }
        return {
          'success': false,
          'message': response.body,
        };
      }

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
      
      // Better error messages for common issues
      String errorMessage = 'Failed to send OTP. Please try again.';
      
      if (e.toString().contains('CORS') || e.toString().contains('Failed to fetch')) {
        errorMessage = 'Network error: Please check your internet connection or try again later.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Backend service unavailable. Please try again later.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// Verify OTP for the given mobile number
  /// 
  /// [mobileNumber] - Mobile number in format: 10 digits (e.g., "9876543210")
  /// [otp] - OTP code entered by user
  /// [sessionId] - Optional session ID returned from sendOtp (if backend uses it)
  /// [firstName] - Optional first name for new user signup (backend creates user in Hygraph)
  /// [lastName] - Optional last name for new user signup (backend creates user in Hygraph)
  /// [referrerCode] - Optional referrer code if user has one
  /// 
  /// Returns Map with 'success' boolean and optional 'message'
  /// 
  /// Example response on success:
  /// {
  ///   'success': true,
  ///   'message': 'OTP verified successfully',
  ///   'token': 'auth_token_here', // Optional: if backend returns auth token
  ///   'userId': 'hygraph_user_id', // Returned when backend creates user
  ///   'isNewUser': true/false      // Whether this is a new signup
  /// }
  Future<Map<String, dynamic>> verifyOtp({
    required String mobileNumber,
    required String otp,
    String? sessionId,
    String? firstName,
    String? lastName,
    String? referrerCode,
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
        'mobileNumber': cleanMobile,  // Backend expects 10 digits without country code
        'otp': otp,
      };
      
      if (sessionId != null && sessionId.isNotEmpty) {
        requestBody['sessionId'] = sessionId;
      }
      
      // Include firstName/lastName for new user signup
      // Backend will create user in Hygraph & Fantasy MongoDB
      if (firstName != null && firstName.isNotEmpty) {
        requestBody['firstName'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        requestBody['lastName'] = lastName;
      }
      
      // Include referrer code if provided (optional)
      if (referrerCode != null && referrerCode.isNotEmpty) {
        requestBody['referrerCode'] = referrerCode;
      }

      if (kDebugMode) {
        print('📱 [MSG91] Verifying OTP...');
        print('📱 [MSG91] Request URL: ${Msg91Config.verifyOtpEndpoint}');
        print('📱 [MSG91] Request Body: $requestBody');
      }

      final response = await http.post(
        Uri.parse(Msg91Config.verifyOtpEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: Msg91Config.requestTimeoutSeconds));

      if (kDebugMode) {
        print('📱 [MSG91] Response StatusCode: ${response.statusCode}');
        print('📱 [MSG91] Full Response Body: ${response.body}');
      }

      // Handle rate limiting
      if (response.statusCode == 429) {
        if (kDebugMode) {
          print('⏱️ [MSG91] Rate limited - too many verification requests');
        }
        return {
          'success': false,
          'message': 'Too many verification requests. Please wait a few minutes before trying again.',
        };
      }

      // Try to parse as JSON, handle plain text error responses
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, treat response body as error message
        if (kDebugMode) {
          print('⚠️ [MSG91] Response is not JSON, treating as plain text error');
        }
        return {
          'success': false,
          'message': response.body,
        };
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final token = responseData['token'];
        if (token != null && token is String && token.isNotEmpty) {
           try {
             final prefs = await SharedPreferences.getInstance();
             await prefs.setString('temp_otp_token', token);
             await prefs.setString('auth_token', token); // Also try to set directly
             await prefs.setString('token', token);
             if (kDebugMode) {
               print('✅ [MSG91] Intercepted and saved Auth Token: ${token.substring(0, 5)}...');
             }
           } catch (e) {
             print('⚠️ [MSG91] Failed to save intercepted token: $e');
           }
        }
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP verified successfully',
          'token': responseData['token'], // Optional auth token from backend
          'userId': responseData['userId'], // User ID from Hygraph (created by backend)
          'isNewUser': responseData['isNewUser'] ?? false, // Whether this is a new signup
        };
      } else {
        // ... (existing failure code)
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
