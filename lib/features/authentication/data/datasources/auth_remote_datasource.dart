import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/rest_client.dart';
import '../models/auth_response_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
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
      final response = await restClient.post(
        ApiConstants.verifyOtpEndpoint,
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'OTP verification failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
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
