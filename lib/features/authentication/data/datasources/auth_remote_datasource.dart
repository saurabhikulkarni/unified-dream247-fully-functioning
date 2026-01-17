import 'dart:async';
import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/rest_client.dart';
import '../../../../config/msg91_config.dart';
import '../models/auth_response_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  /// Send OTP via MSG91
  Future<void> sendOtp({
    required String phone,
  });

  /// Login with phone and password
  Future<AuthResponseModel> login({
    required String phone,
    required String password,
  });

  /// Register a new user
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  /// Verify OTP
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Logout
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final RestClient restClient;

  AuthRemoteDataSourceImpl({required this.restClient});

  @override
  Future<void> sendOtp({
    required String phone,
  }) async {
    try {
      print('🔐 [AUTH] Sending OTP to phone: $phone');
      print('🔐 [AUTH] Endpoint: ${Msg91Config.sendOtpEndpoint}');
      
      final response = await restClient.post(
        Msg91Config.sendOtpEndpoint,
        data: {
          'mobileNumber': phone,
        },
      );

      print('🔐 [AUTH] Send OTP Response status: ${response.statusCode}');
      print('🔐 [AUTH] Send OTP Response data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMessage = response.data is Map 
            ? response.data['message'] ?? 'Failed to send OTP'
            : 'Failed to send OTP';
        
        print('🔐 [AUTH] Send OTP Error: $errorMessage (Status: ${response.statusCode})');
        
        throw ServerException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
      
      print('🔐 [AUTH] OTP sent successfully');
    } catch (e) {
      print('🔐 [AUTH] Send OTP Exception: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await restClient.post(
        ApiConstants.loginEndpoint,
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await restClient.post(
        ApiConstants.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      print('🔐 [AUTH] Verifying OTP for phone: $phone');
      print('🔐 [AUTH] Endpoint: ${Msg91Config.verifyOtpEndpoint}');
      
      final response = await restClient.post(
        Msg91Config.verifyOtpEndpoint,
        data: {
          'mobileNumber': phone,
          'otp': otp,
        },
      );

      print('🔐 [AUTH] Response status: ${response.statusCode}');
      print('🔐 [AUTH] Response data: ${response.data}');

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 500 || response.statusCode == 502 || response.statusCode == 503) {
        final errorMessage = 'Server error (${response.statusCode}). The server is temporarily unavailable. Please try again later.';
        print('🔐 [AUTH] Server Error: $errorMessage');
        throw ServerException(
          errorMessage,
          statusCode: response.statusCode,
        );
      } else {
        final errorMessage = response.data is Map 
            ? response.data['message'] ?? 'OTP verification failed'
            : 'OTP verification failed';
        
        print('🔐 [AUTH] Error: $errorMessage (Status: ${response.statusCode})');
        
        throw ServerException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('🔐 [AUTH] Network Exception: $e');
      throw ServerException('Network connection failed. Please check your internet and try again.');
    } on TimeoutException catch (e) {
      print('🔐 [AUTH] Timeout Exception: $e');
      throw ServerException('Request timed out. The server took too long to respond. Please try again.');
    } catch (e) {
      print('🔐 [AUTH] Exception: $e');
      if (e is ServerException) rethrow;
      throw ServerException('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await restClient.post(ApiConstants.logoutEndpoint);
    } catch (e) {
      throw ServerException('Logout failed: ${e.toString()}');
    }
  }
}
