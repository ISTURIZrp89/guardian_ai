import 'dart:math';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/calculation_result.dart';

class CalculateBodySurfaceUseCase {
  CalculationResult execute({
    required double heightCm,
    required double weightKg,
  }) {
    if (weightKg < AppConstants.minWeightKg || weightKg > AppConstants.maxWeightKg) {
      throw ValidationException(
        'El peso debe estar entre ${AppConstants.minWeightKg} y ${AppConstants.maxWeightKg} kg',
        code: 'INVALID_WEIGHT',
      );
    }

    if (heightCm < 10 || heightCm > 250) {
      throw ValidationException(
        'La altura debe estar entre 10 y 250 cm',
        code: 'INVALID_HEIGHT',
      );
    }

    final bsa = sqrt((heightCm * weightKg) / 3600);
    final roundedBsa = (bsa * 100).roundToDouble() / 100;

    String description;
    bool isWarning = false;

    if (roundedBsa > 2.5) {
      isWarning = true;
      description = 'Superficie corporal elevada (> 2.5 m²). '
          'Verificar dosis de quimioterapia y parámetros hemodinámicos.';
    } else if (roundedBsa < 0.3) {
      isWarning = true;
      description = 'Superficie corporal baja (< 0.3 m²). '
          'Verificar medidas del paciente.';
    } else {
      description = 'Superficie corporal dentro del rango esperado.';
    }

    return CalculationResult(
      result: roundedBsa,
      unit: 'm²',
      label: 'Superficie Corporal (Mosteller)',
      description: description,
      isWarning: isWarning,
      details: {
        'Peso (kg)': weightKg,
        'Altura (cm)': heightCm,
      },
    );
  }
}
