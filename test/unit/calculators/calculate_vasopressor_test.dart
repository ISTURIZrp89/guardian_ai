import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_vasopressor.dart';

void main() {
  late CalculateVasopressorUseCase useCase;

  setUp(() {
    useCase = CalculateVasopressorUseCase();
  });

  group('CalculateVasopressorUseCase', () {
    test('calcula dosis de noradrenalina dentro del rango terapéutico', () {
      final result = useCase.execute(
        vasopressorName: 'noradrenalina',
        weight: 70,
        doseMcgKgMin: 0.1,
      );

      expect(result.result, 0.1);
      expect(result.unit, 'mcg/kg/min');
      expect(result.isWarning, false);
      expect(result.isCritical, false);
    });

    test('calcula infusión de noradrenalina con concentración personalizada',
        () {
      final result = useCase.execute(
        vasopressorName: 'noradrenalina',
        weight: 70,
        doseMcgKgMin: 0.1,
        concentrationMcgPerMl: 40,
      );

      // (0.1 * 70 * 60) / 40 = 420 / 40 = 10.5 mL/h
      expect(result.details!['Velocidad infusión (mL/h)'], 10.5);
    });

    test('lanza ValidationException para vasopresor desconocido', () {
      expect(
        () => useCase.execute(
          vasopressorName: 'isoproterenol',
          weight: 70,
          doseMcgKgMin: 0.1,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException con peso 0', () {
      expect(
        () => useCase.execute(
          vasopressorName: 'noradrenalina',
          weight: 0,
          doseMcgKgMin: 0.1,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException con dosis 0', () {
      expect(
        () => useCase.execute(
          vasopressorName: 'noradrenalina',
          weight: 70,
          doseMcgKgMin: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('marca isCritical cuando dosis supera el rango terapéutico máximo',
        () {
      final result = useCase.execute(
        vasopressorName: 'noradrenalina',
        weight: 70,
        doseMcgKgMin: 1.0,
      );

      expect(result.isCritical, true);
    });

    test('marca isWarning cuando dosis está por debajo del rango terapéutico',
        () {
      final result = useCase.execute(
        vasopressorName: 'noradrenalina',
        weight: 70,
        doseMcgKgMin: 0.001,
      );

      expect(result.isWarning, true);
    });

    test('calcula dosis de dobutamina correctamente', () {
      final result = useCase.execute(
        vasopressorName: 'dobutamina',
        weight: 80,
        doseMcgKgMin: 10,
      );

      expect(result.result, 10.0);
      expect(result.label, 'Dosis de Dobutamina');
    });

    test('case insensitive para nombre de vasopresor', () {
      final result = useCase.execute(
        vasopressorName: 'NORADRENALINA',
        weight: 70,
        doseMcgKgMin: 0.1,
      );

      expect(result.isWarning, false);
    });

    test('proporciona detalles con rangos usuales', () {
      final result = useCase.execute(
        vasopressorName: 'dopamina',
        weight: 70,
        doseMcgKgMin: 10,
      );

      expect(result.details!['Rango usual (min)'], 2);
      expect(result.details!['Rango usual (max)'], 20);
    });
  });
}
