import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Verify OTP use case
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String phone,
    required String otp,
  }) async {
    return await repository.verifyOtp(
      phone: phone,
      otp: otp,
    );
  }
}
