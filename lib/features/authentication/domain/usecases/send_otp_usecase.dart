import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for sending OTP via MSG91
class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  /// Send OTP to phone number
  Future<Either<Failure, void>> call({
    required String phone,
  }) async {
    return await repository.sendOtp(phone: phone);
  }
}
