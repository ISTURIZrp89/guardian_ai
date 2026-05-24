import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_max_dose_check.dart';

void main() {
  late CalculateMaxDoseCheckUseCase useCase;

  setUp(() {
    useCase = CalculateMaxDoseCheckUseCase();
  });

  group('CalculateMaxDoseCheckUseCase', () {
    test('dosis única de paracetamol segura (500mg < 1000mg)', () {
      final result = useCase.execute(
        medication: 'paracetamol',
        calculatedDose: 500,
        doseType: 'single',
      );

      expect(result.isCritical, false);
      expect(result.isWarning, false);
    });

    test('dosis única de paracetamol supera el máximo (1500mg > 1000mg)', () {
      final result = useCase.execute(
        medication: 'paracetamol',
        calculatedDose: 1500,
        doseType: 'single',
      );

      expect(result.isCritical, true);
    });

    test('dosis diaria de paracetamol supera el máximo (5000mg > 4000mg)', () {
      final result = useCase.execute(
        medication: 'paracetamol',
        calculatedDose: 5000,
        doseType: 'daily',
      );

      expect(result.isCritical, true);
    });

    test('dosis única cerca del límite (> 90% del máximo)', () {
      final result = useCase.execute(
        medication: 'ibuprofeno',
        calculatedDose: 750,
        doseType: 'single',
      );

      // 750 > 720 (800 * 0.9)
      expect(result.isWarning, true);
      expect(result.isCritical, false);
    });

    test('lanza ValidationException para medicamento desconocido', () {
      expect(
        () => useCase.execute(
          medication: 'medicamento_inventado',
          calculatedDose: 500,
          doseType: 'single',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando dosis calculada es 0', () {
      expect(
        () => useCase.execute(
          medication: 'paracetamol',
          calculatedDose: 0,
          doseType: 'single',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('verifica dosis por kg cuando weightKg es proporcionado', () {
      final result = useCase.execute(
        medication: 'paracetamol',
        calculatedDose: 2000,
        doseType: 'single',
        weightKg: 70,
      );

      // 2000/70 = 28.57 mg/kg > 15 mg/kg (maxDosePerKg)
      expect(result.isCritical, true);
    });

    test('dosis segura de morfina (5mg < 10mg)', () {
      final result = useCase.execute(
        medication: 'morfina',
        calculatedDose: 5,
        doseType: 'single',
      );

      expect(result.isCritical, false);
      expect(result.isWarning, false);
    });

    test('case insensitive para nombre de medicamento', () {
      final result = useCase.execute(
        medication: 'IBUPROFENO',
        calculatedDose: 400,
        doseType: 'single',
      );

      expect(result.isCritical, false);
    });
  });
}
