import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/utils/utils.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('retorna null para email válido', () {
        expect(Validators.validateEmail('user@example.com'), isNull);
        expect(Validators.validateEmail('test@domain.co'), isNull);
      });

      test('retorna error para email inválido', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
        expect(Validators.validateEmail('invalido'), isNotNull);
        expect(Validators.validateEmail('@domain.com'), isNotNull);
      });
    });

    group('validateWeight', () {
      test('retorna null para peso válido', () {
        expect(Validators.validateWeight('70'), isNull);
        expect(Validators.validateWeight('0.5'), isNull);
        expect(Validators.validateWeight('300'), isNull);
      });

      test('retorna error para peso inválido', () {
        expect(Validators.validateWeight(null), isNotNull);
        expect(Validators.validateWeight(''), isNotNull);
        expect(Validators.validateWeight('0'), isNotNull);
        expect(Validators.validateWeight('0.4'), isNotNull);
        expect(Validators.validateWeight('301'), isNotNull);
        expect(Validators.validateWeight('abc'), isNotNull);
      });
    });

    group('validateDose', () {
      test('retorna null para dosis válida', () {
        expect(Validators.validateDose('500'), isNull);
        expect(Validators.validateDose('1'), isNull);
        expect(Validators.validateDose('10000'), isNull);
      });

      test('retorna error para dosis inválida', () {
        expect(Validators.validateDose(null), isNotNull);
        expect(Validators.validateDose(''), isNotNull);
        expect(Validators.validateDose('0'), isNotNull);
        expect(Validators.validateDose('-5'), isNotNull);
        expect(Validators.validateDose('10001'), isNotNull);
        expect(Validators.validateDose('abc'), isNotNull);
      });
    });

    group('validatePin', () {
      test('retorna null para PIN válido', () {
        expect(Validators.validatePin('123456'), isNull);
      });

      test('retorna error para PIN inválido', () {
        expect(Validators.validatePin(null), isNotNull);
        expect(Validators.validatePin(''), isNotNull);
        expect(Validators.validatePin('12345'), isNotNull);
        expect(Validators.validatePin('1234567'), isNotNull);
        expect(Validators.validatePin('abcdef'), isNotNull);
        expect(Validators.validatePin('12a456'), isNotNull);
      });
    });

    group('validateBloodPressure', () {
      test('retorna null para presión válida', () {
        expect(
          Validators.validateBloodPressure('120', '80'),
          isNull,
        );
      });

      test('retorna error para presión inválida', () {
        expect(
          Validators.validateBloodPressure(null, '80'),
          isNotNull,
        );
        expect(
          Validators.validateBloodPressure('120', null),
          isNotNull,
        );
        expect(
          Validators.validateBloodPressure('40', '80'),
          isNotNull,
        );
        expect(
          Validators.validateBloodPressure('120', '200'),
          isNotNull,
        );
        expect(
          Validators.validateBloodPressure('80', '120'),
          isNotNull,
        );
      });
    });

    group('validateHeartRate', () {
      test('retorna null para frecuencia cardíaca válida', () {
        expect(Validators.validateHeartRate('72'), isNull);
        expect(Validators.validateHeartRate('20'), isNull);
        expect(Validators.validateHeartRate('250'), isNull);
      });

      test('retorna error para frecuencia cardíaca inválida', () {
        expect(Validators.validateHeartRate(null), isNotNull);
        expect(Validators.validateHeartRate(''), isNotNull);
        expect(Validators.validateHeartRate('19'), isNotNull);
        expect(Validators.validateHeartRate('251'), isNotNull);
        expect(Validators.validateHeartRate('abc'), isNotNull);
      });
    });

    group('validateTemperature', () {
      test('retorna null para temperatura válida', () {
        expect(Validators.validateTemperature('36.5'), isNull);
        expect(Validators.validateTemperature('34.0'), isNull);
        expect(Validators.validateTemperature('42.0'), isNull);
      });

      test('retorna error para temperatura inválida', () {
        expect(Validators.validateTemperature(null), isNotNull);
        expect(Validators.validateTemperature(''), isNotNull);
        expect(Validators.validateTemperature('33.9'), isNotNull);
        expect(Validators.validateTemperature('42.1'), isNotNull);
        expect(Validators.validateTemperature('abc'), isNotNull);
      });
    });

    group('validateRequired', () {
      test('retorna null para valor requerido presente', () {
        expect(Validators.validateRequired('texto'), isNull);
      });

      test('retorna error para valor requerido ausente', () {
        expect(Validators.validateRequired(null), isNotNull);
        expect(Validators.validateRequired(''), isNotNull);
        expect(Validators.validateRequired('  '), isNotNull);
      });
    });
  });
}
