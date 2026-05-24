import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_dose.dart';

void main() {
  late CalculateDoseUseCase useCase;

  setUp(() {
    useCase = CalculateDoseUseCase();
  });

  group('CalculateDoseUseCase', () {
    test('calcula dosis correcta para mg/kg (70kg * 5mg/kg = 350mg)', () {
      final result = useCase.execute(
        weight: 70,
        dosePerKg: 5,
      );

      expect(result.result, 350.0);
      expect(result.unit, 'mg');
      expect(result.label, 'Dosis Total');
    });

    test('lanza ValidationException cuando el peso es 0', () {
      expect(
        () => useCase.execute(weight: 0, dosePerKg: 5),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando el peso es negativo', () {
      expect(
        () => useCase.execute(weight: -10, dosePerKg: 5),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
        'no lanza excepción con dosis/kg alta (100mg/kg * 80kg = 8000mg) '
        'porque el límite es por kg, no total', () {
      final result = useCase.execute(
        weight: 80,
        dosePerKg: 100,
      );

      expect(result.result, 8000.0);
      expect(result.isCritical, false);
    });

    test('lanza ValidationException cuando dosis por kg es 0', () {
      expect(
        () => useCase.execute(weight: 70, dosePerKg: 0),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando dosis por kg supera el máximo', () {
      expect(
        () => useCase.execute(weight: 70, dosePerKg: 15000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('marca isCritical cuando la dosis supera maxDose proporcionado', () {
      final result = useCase.execute(
        weight: 70,
        dosePerKg: 10,
        maxDose: 500,
      );

      expect(result.result, 700.0);
      expect(result.isCritical, true);
    });

    test('marca isWarning cuando la dosis está cerca del maxDose', () {
      final result = useCase.execute(
        weight: 70,
        dosePerKg: 7,
        maxDose: 500,
      );

      expect(result.result, 490.0);
      expect(result.isWarning, true);
      expect(result.isCritical, false);
    });
  });
}
