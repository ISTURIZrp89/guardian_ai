import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_drip_rate.dart';

void main() {
  late CalculateDripRateUseCase useCase;

  setUp(() {
    useCase = CalculateDripRateUseCase();
  });

  group('CalculateDripRateUseCase', () {
    test('calcula gotas por minuto estándar', () {
      // (500 * 20) / 480 = 10000 / 480 = 20.8
      final result = useCase.calculateDropsPerMin(
        volumeMl: 500,
        timeMinutes: 480,
      );

      expect(result.result, 20.8);
      expect(result.unit, 'gotas/min');
    });

    test('microgotas es siempre 3x las gotas estándar', () {
      final drops = useCase.calculateDropsPerMin(
        volumeMl: 500,
        timeMinutes: 480,
      );

      final microdrops = useCase.calculateMicrodropsPerMin(
        volumeMl: 500,
        timeMinutes: 480,
      );

      // microdrops: (500 * 60) / 480 = 62.5
      // drops: (500 * 20) / 480 = 20.8
      // 62.5 / 20.8 ≈ 3.0
      expect(microdrops.result, 62.5);
      expect(microdrops.result / drops.result, closeTo(3.0, 0.01));
    });

    test('lanza ValidationException cuando tiempo es 0', () {
      expect(
        () => useCase.calculateDropsPerMin(
          volumeMl: 500,
          timeMinutes: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando tiempo es negativo', () {
      expect(
        () => useCase.calculateDropsPerMin(
          volumeMl: 500,
          timeMinutes: -60,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando volumen es 0', () {
      expect(
        () => useCase.calculateDropsPerMin(
          volumeMl: 0,
          timeMinutes: 480,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando volumen excede 5000 mL', () {
      expect(
        () => useCase.calculateDropsPerMin(
          volumeMl: 6000,
          timeMinutes: 480,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando tiempo excede 1440 min', () {
      expect(
        () => useCase.calculateDropsPerMin(
          volumeMl: 500,
          timeMinutes: 1500,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('marca isWarning para goteo rápido (> 60 gotas/min)', () {
      final result = useCase.calculateDropsPerMin(
        volumeMl: 1000,
        timeMinutes: 120,
      );

      expect(result.isWarning, true);
    });
  });
}
