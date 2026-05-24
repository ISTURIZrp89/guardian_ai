import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/calculation_result.dart';

class CalculateInfusionUseCase {
  CalculationResult execute({
    required double dose,
    required double weight,
    required double concentration,
    double? maxRate,
  }) {
    if (weight < AppConstants.minWeightKg || weight > AppConstants.maxWeightKg) {
      throw ValidationException(
        'El peso debe estar entre ${AppConstants.minWeightKg} y ${AppConstants.maxWeightKg} kg',
        code: 'INVALID_WEIGHT',
      );
    }

    if (dose <= 0) {
      throw ValidationException(
        'La dosis debe ser mayor a 0',
        code: 'INVALID_DOSE',
      );
    }

    if (concentration <= 0) {
      throw ValidationException(
        'La concentración debe ser mayor a 0',
        code: 'INVALID_CONCENTRATION',
      );
    }

    final rateMlPerH = (dose * weight * 60) / concentration;

    if (rateMlPerH > AppConstants.maxInfusionRate) {
      throw ValidationException(
        'La velocidad de infusión calculada (${rateMlPerH.toStringAsFixed(1)} mL/h) '
        'excede el máximo permitido de ${AppConstants.maxInfusionRate} mL/h',
        code: 'RATE_EXCEEDS_MAX',
      );
    }

    final roundedRate = (rateMlPerH * 10).roundToDouble() / 10;

    bool isWarning = false;
    bool isCritical = false;
    String? description;

    if (maxRate != null && roundedRate > maxRate) {
      isCritical = true;
      description = '¡ATENCIÓN! La velocidad de infusión (${roundedRate.toStringAsFixed(1)} mL/h) '
          'supera la velocidad máxima recomendada de ${maxRate.toStringAsFixed(1)} mL/h.';
    } else if (roundedRate > 500) {
      isWarning = true;
      description = 'Velocidad de infusión elevada (${roundedRate.toStringAsFixed(1)} mL/h). '
          'Verificar acceso venoso y tolerancia del paciente.';
    } else {
      description = 'Velocidad de infusión dentro de rangos clínicos aceptables.';
    }

    return CalculationResult(
      result: roundedRate,
      unit: 'mL/h',
      label: 'Velocidad de Infusión',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Dosis (mcg/kg/min)': dose,
        'Peso (kg)': weight,
        'Concentración (mcg/mL)': concentration,
        'Velocidad (mL/h)': roundedRate,
      },
    );
  }
}
