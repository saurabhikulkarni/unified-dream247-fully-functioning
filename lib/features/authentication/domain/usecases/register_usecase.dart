import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Register use case
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
