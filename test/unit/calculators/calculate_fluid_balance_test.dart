import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_fluid_balance.dart';

void main() {
  late CalculateFluidBalanceUseCase useCase;

  setUp(() {
    useCase = CalculateFluidBalanceUseCase();
  });

  group('CalculateFluidBalanceUseCase', () {
    test('calcula balance hídrico positivo (input > output)', () {
      final result = useCase.execute(
        totalInput: 2500,
        totalOutput: 1800,
      );

      expect(result.result, 700.0);
      expect(result.unit, 'mL');
      expect(result.label, 'Balance Hídrico');
    });

    test('calcula balance hídrico negativo (input < output)', () {
      final result = useCase.execute(
        totalInput: 1500,
        totalOutput: 2000,
      );

      expect(result.result, -500.0);
    });

    test('calcula balance hídrico cero (input == output)', () {
      final result = useCase.execute(
        totalInput: 2000,
        totalOutput: 2000,
      );

      expect(result.result, 0.0);
    });

    test('lanza ValidationException cuando input es negativo', () {
      expect(
        () => useCase.execute(
          totalInput: -100,
          totalOutput: 500,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando output es negativo', () {
      expect(
        () => useCase.execute(
          totalInput: 500,
          totalOutput: -100,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando input excede 20000 mL', () {
      expect(
        () => useCase.execute(
          totalInput: 25000,
          totalOutput: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lanza ValidationException cuando output excede 20000 mL', () {
      expect(
        () => useCase.execute(
          totalInput: 0,
          totalOutput: 25000,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('marca isWarning para balance positivo significativo (> 1500 mL)', () {
      final result = useCase.execute(
        totalInput: 4000,
        totalOutput: 2000,
      );

      expect(result.result, 2000.0);
      expect(result.isWarning, true);
      expect(result.isCritical, false);
    });

    test('marca isCritical para balance positivo severo (> 3000 mL)', () {
      final result = useCase.execute(
        totalInput: 6000,
        totalOutput: 2000,
      );

      expect(result.result, 4000.0);
      expect(result.isCritical, true);
    });

    test('marca isWarning para balance negativo significativo (< -1500 mL)', () {
      final result = useCase.execute(
        totalInput: 500,
        totalOutput: 2500,
      );

      expect(result.result, -2000.0);
      expect(result.isWarning, true);
    });

    test('marca isCritical para balance negativo severo (< -3000 mL)', () {
      final result = useCase.execute(
        totalInput: 500,
        totalOutput: 4000,
      );

      expect(result.result, -3500.0);
      expect(result.isCritical, true);
    });
  });
}
