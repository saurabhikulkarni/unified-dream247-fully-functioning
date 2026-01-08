import 'package:flutter_test/flutter_test.dart';
import 'package:unified_dream247/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@domain.co.in'), null);
      });

      test('should return error message for invalid email', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
      });

      test('should return error message for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });
    });

    group('validatePhone', () {
      test('should return null for valid phone number', () {
        expect(Validators.validatePhone('9876543210'), null);
        expect(Validators.validatePhone('8765432109'), null);
      });

      test('should return error message for invalid phone number', () {
        expect(Validators.validatePhone('1234567890'), isNotNull);
        expect(Validators.validatePhone('12345'), isNotNull);
        expect(Validators.validatePhone('abcdefghij'), isNotNull);
      });

      test('should return error message for empty phone', () {
        expect(Validators.validatePhone(''), isNotNull);
        expect(Validators.validatePhone(null), isNotNull);
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('password123'), null);
        expect(Validators.validatePassword('securePass'), null);
      });

      test('should return error message for short password', () {
        expect(Validators.validatePassword('12345'), isNotNull);
        expect(Validators.validatePassword('abc'), isNotNull);
      });

      test('should return error message for empty password', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });
    });

    group('validateOtp', () {
      test('should return null for valid OTP', () {
        expect(Validators.validateOtp('123456'), null);
        expect(Validators.validateOtp('000000'), null);
      });

      test('should return error message for invalid OTP length', () {
        expect(Validators.validateOtp('12345'), isNotNull);
        expect(Validators.validateOtp('1234567'), isNotNull);
      });

      test('should return error message for non-numeric OTP', () {
        expect(Validators.validateOtp('12345a'), isNotNull);
        expect(Validators.validateOtp('abcdef'), isNotNull);
      });

      test('should return error message for empty OTP', () {
        expect(Validators.validateOtp(''), isNotNull);
        expect(Validators.validateOtp(null), isNotNull);
      });
    });
  });
}
