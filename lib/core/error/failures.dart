import 'package:equatable/equatable.dart';

/// Base class for failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Authentication-related failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
}

/// Validation-related failures
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure(super.message, {super.code, this.errors});

  @override
  List<Object?> get props => [message, code, errors];
}

/// Payment-related failures
class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {super.code});
}

/// General/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
