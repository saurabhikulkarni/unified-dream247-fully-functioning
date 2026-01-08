import 'package:flutter_test/flutter_test.dart';
import 'package:unified_dream247/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('formatCurrency', () {
      test('should format currency with symbol', () {
        expect(Formatters.formatCurrency(1000), '₹1,000.00');
        expect(Formatters.formatCurrency(10000), '₹10,000.00');
        expect(Formatters.formatCurrency(100000), '₹1,00,000.00');
      });

      test('should format currency without symbol', () {
        expect(
          Formatters.formatCurrency(1000, showSymbol: false),
          '1,000.00',
        );
      });
    });

    group('formatPhoneNumber', () {
      test('should format phone number with spaces', () {
        expect(
          Formatters.formatPhoneNumber('9876543210'),
          '+91 98765 43210',
        );
      });

      test('should return original if not 10 digits', () {
        expect(Formatters.formatPhoneNumber('12345'), '12345');
      });
    });

    group('formatCompactNumber', () {
      test('should format numbers compactly', () {
        expect(Formatters.formatCompactNumber(500), '500');
        expect(Formatters.formatCompactNumber(1000), '1.0K');
        expect(Formatters.formatCompactNumber(1500), '1.5K');
        expect(Formatters.formatCompactNumber(1000000), '1.0M');
      });
    });

    group('truncateText', () {
      test('should truncate long text', () {
        expect(
          Formatters.truncateText('This is a long text', 10),
          'This is a ...',
        );
      });

      test('should not truncate short text', () {
        expect(
          Formatters.truncateText('Short', 10),
          'Short',
        );
      });
    });

    group('capitalizeWords', () {
      test('should capitalize all words', () {
        expect(
          Formatters.capitalizeWords('hello world'),
          'Hello World',
        );
        expect(
          Formatters.capitalizeWords('test case example'),
          'Test Case Example',
        );
      });
    });
  });
}
