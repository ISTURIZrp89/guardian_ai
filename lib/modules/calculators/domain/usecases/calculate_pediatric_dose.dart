import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/calculation_result.dart';

class CalculatePediatricDoseUseCase {
  CalculationResult execute({
    required double weightKg,
    required double adultDose,
    double? maxPediatricDose,
  }) {
    if (weightKg < 0.5 || weightKg > 120) {
      throw ValidationException(
        'El peso pediátrico debe estar entre 0.5 y 120 kg',
        code: 'INVALID_PEDIATRIC_WEIGHT',
      );
    }

    if (adultDose <= 0) {
      throw ValidationException(
        'La dosis de adulto debe ser mayor a 0',
        code: 'INVALID_ADULT_DOSE',
      );
    }

    if (adultDose > AppConstants.maxDoseMg) {
      throw ValidationException(
        'La dosis de adulto no puede exceder ${AppConstants.maxDoseMg} mg',
        code: 'ADULT_DOSE_EXCEEDS_MAX',
      );
    }

    final pediatricDose = (weightKg / 70) * adultDose;
    final roundedDose = (pediatricDose * 100).roundToDouble() / 100;

    bool isWarning = false;
    bool isCritical = false;
    String? description;

    if (maxPediatricDose != null && roundedDose > maxPediatricDose) {
      isCritical = true;
      description = '¡ATENCIÓN! La dosis pediátrica calculada (${roundedDose.toStringAsFixed(2)} mg) '
          'supera la dosis máxima pediátrica recomendada de ${maxPediatricDose.toStringAsFixed(2)} mg. '
          'Verificar inmediatamente con el servicio de farmacia.';
    } else if (maxPediatricDose != null && roundedDose > maxPediatricDose * 0.9) {
      isWarning = true;
      description = 'La dosis pediátrica calculada está cerca del límite máximo. '
          'Monitorear posibles efectos adversos.';
    } else {
      description = 'Dosis pediátrica calculada según Regla de Clark dentro de rangos seguros.';
    }

    return CalculationResult(
      result: roundedDose,
      unit: 'mg',
      label: 'Dosis Pediátrica (Clark)',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Peso (kg)': weightKg,
        'Dosis adulto (mg)': adultDose,
        'Factor (peso/70)': (weightKg / 70),
        'Dosis calculada (mg)': roundedDose,
      },
    );
  }
}
