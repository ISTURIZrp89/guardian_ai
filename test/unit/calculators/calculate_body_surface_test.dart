import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_body_surface.dart';

void main() {
  late CalculateBodySurfaceUseCase useCase;

  setUp(() {
    useCase = CalculateBodySurfaceUseCase();
  });

  group('CalculateBodySurfaceUseCase', () {
    test('calcula BSA con fórmula de Mosteller', () {
      // sqrt((170 * 70) / 3600) = sqrt(11900 / 3600) = sqrt(3.306) ≈ 1.82
      final result = useCase.execute(
        heightCm: 170,
        weightKg: 70,
      );

      final expected = sqrt((170 * 70) / 3600);
      expect(result.result, closeTo(1.82, 0.01));
      expect(result.result, closeTo(expected, 0.01));
      expect(result.unit, 'm²');
      expect(result.label, 'Superficie Corporal (Mosteller)');
    });

    test('lanza ValidationException cuando altura es 0', () {
      expect(
        () => useCase.execute(
          heightCm: 0,
          weightKg: 70,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando peso es 0', () {
      expect(
        () => useCase.execute(
          heightCm: 170,
          weightKg: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException con peso negativo', () {
      expect(
        () => useCase.execute(
          heightCm: 170,
          weightKg: -10,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException con altura negativa', () {
      expect(
        () => useCase.execute(
          heightCm: -170,
          weightKg: 70,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando altura supera 250 cm', () {
      expect(
        () => useCase.execute(
          heightCm: 260,
          weightKg: 70,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('calcula BSA para valores normales sin warning', () {
      final result = useCase.execute(
        heightCm: 50,
        weightKg: 10,
      );

      expect(result.result, greaterThan(0));
      expect(result.isWarning, isNot(true));
    });

    test('marca isWarning para BSA < 0.3 m²', () {
      final result = useCase.execute(
        heightCm: 10,
        weightKg: 0.5,
      );

      expect(result.isWarning, true);
    });

    test('marca isWarning para BSA > 2.5 m²', () {
      final result = useCase.execute(
        heightCm: 200,
        weightKg: 150,
      );

      expect(result.isWarning, true);
    });
  });
}
