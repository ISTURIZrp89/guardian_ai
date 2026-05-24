import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_infusion.dart';

void main() {
  late CalculateInfusionUseCase useCase;

  setUp(() {
    useCase = CalculateInfusionUseCase();
  });

  group('CalculateInfusionUseCase', () {
    test('calcula velocidad de infusión estándar', () {
      // (dose * weight * 60) / concentration
      // (5 * 70 * 60) / 1000 = 21000 / 1000 = 21.0 mL/h
      final result = useCase.execute(
        dose: 5,
        weight: 70,
        concentration: 1000,
      );

      expect(result.result, 21.0);
      expect(result.unit, 'mL/h');
      expect(result.label, 'Velocidad de Infusión');
    });

    test('lanza ValidationException cuando concentración es 0', () {
      expect(
        () => useCase.execute(
          dose: 5,
          weight: 70,
          concentration: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando concentración es negativa', () {
      expect(
        () => useCase.execute(
          dose: 5,
          weight: 70,
          concentration: -100,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando peso es 0', () {
      expect(
        () => useCase.execute(
          dose: 5,
          weight: 0,
          concentration: 1000,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando peso es negativo', () {
      expect(
        () => useCase.execute(
          dose: 5,
          weight: -50,
          concentration: 1000,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando dosis es 0', () {
      expect(
        () => useCase.execute(
          dose: 0,
          weight: 70,
          concentration: 1000,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('marca isCritical cuando la velocidad supera maxRate', () {
      final result = useCase.execute(
        dose: 10,
        weight: 100,
        concentration: 100,
        maxRate: 300,
      );

      expect(result.isCritical, true);
    });

    test('lanza cuando la velocidad excede el máximo permitido', () {
      expect(
        () => useCase.execute(
          dose: 50,
          weight: 200,
          concentration: 1,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
