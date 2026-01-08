import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Login event
class LoginEvent extends AuthEvent {
  final String phone;
  final String password;

  const LoginEvent({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

/// Register event
class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, password];
}

/// Verify OTP event
class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyOtpEvent({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, otp];
}

/// Logout event
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Check authentication status event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
