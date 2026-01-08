import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Send OTP to phone number via MSG91
  Future<Either<Failure, void>> sendOtp({
    required String phone,
  });

  /// Login with phone and password
  Future<Either<Failure, User>> login({
    required String phone,
    required String password,
  });

  /// Register a new user
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  /// Verify OTP
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}
