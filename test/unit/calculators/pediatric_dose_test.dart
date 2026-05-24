import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_pediatric_dose.dart';

void main() {
  late CalculatePediatricDoseUseCase useCase;

  setUp(() {
    useCase = CalculatePediatricDoseUseCase();
  });

  group('CalculatePediatricDoseUseCase', () {
    test('calcula dosis pediátrica con Regla de Clark', () {
      // (20 / 70) * 500 = 0.2857 * 500 = 142.86
      final result = useCase.execute(
        weightKg: 20,
        adultDose: 500,
      );

      expect(result.result, 142.86);
      expect(result.unit, 'mg');
      expect(result.label, 'Dosis Pediátrica (Clark)');
    });

    test('calcula dosis para recién nacido (3.5kg)', () {
      // (3.5 / 70) * 100 = 0.05 * 100 = 5.0
      final result = useCase.execute(
        weightKg: 3.5,
        adultDose: 100,
      );

      expect(result.result, 5.0);
    });

    test('calcula dosis para adulto (70kg debe dar la dosis adulta)', () {
      // (70 / 70) * 500 = 1.0 * 500 = 500
      final result = useCase.execute(
        weightKg: 70,
        adultDose: 500,
      );

      expect(result.result, 500.0);
    });

    test('lanza ValidationException cuando peso pediátrico es menor a 0.5', () {
      expect(
        () => useCase.execute(
          weightKg: 0.1,
          adultDose: 500,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando dosis adulto es 0', () {
      expect(
        () => useCase.execute(
          weightKg: 20,
          adultDose: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando peso pediátrico supera 120 kg', () {
      expect(
        () => useCase.execute(
          weightKg: 150,
          adultDose: 500,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('marca isCritical cuando dosis supera maxPediatricDose', () {
      final result = useCase.execute(
        weightKg: 60,
        adultDose: 1000,
        maxPediatricDose: 500,
      );

      // (60/70) * 1000 = 857.14
      expect(result.isCritical, true);
    });

    test('marca isWarning cuando dosis está cerca de maxPediatricDose', () {
      final result = useCase.execute(
        weightKg: 50,
        adultDose: 650,
        maxPediatricDose: 500,
      );

      // (50/70) * 650 = 464.29, 464.29 > 450 (500 * 0.9)
      expect(result.isWarning, true);
    });
  });
}
