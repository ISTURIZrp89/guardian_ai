import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/calculation_result.dart';

class CalculateDoseUseCase {
  CalculationResult execute({
    required double weight,
    required double dosePerKg,
    double? maxDose,
    String medicationName = 'medicamento',
  }) {
    if (weight < AppConstants.minWeightKg || weight > AppConstants.maxWeightKg) {
      throw ValidationException(
        'El peso debe estar entre ${AppConstants.minWeightKg} y ${AppConstants.maxWeightKg} kg',
        code: 'INVALID_WEIGHT',
      );
    }

    if (dosePerKg <= 0) {
      throw ValidationException(
        'La dosis por kg debe ser mayor a 0',
        code: 'INVALID_DOSE',
      );
    }

    if (dosePerKg > AppConstants.maxDoseMg) {
      throw ValidationException(
        'La dosis por kg no puede exceder ${AppConstants.maxDoseMg} mg',
        code: 'DOSE_EXCEEDS_MAX',
      );
    }

    final calculatedDose = weight * dosePerKg;
    final roundedDose = (calculatedDose * 100).roundToDouble() / 100;

    bool isWarning = false;
    bool isCritical = false;
    String? description;

    if (maxDose != null && roundedDose > maxDose) {
      isCritical = true;
      description = '¡ATENCIÓN! La dosis calculada (${roundedDose.toStringAsFixed(2)} mg) '
          'supera la dosis máxima recomendada de ${maxDose.toStringAsFixed(2)} mg. '
          'Verificar indicación médica.';
    } else if (maxDose != null && roundedDose > maxDose * 0.9) {
      isWarning = true;
      description = 'La dosis calculada está cerca del límite máximo recomendado '
          '(${maxDose.toStringAsFixed(2)} mg). Monitorear al paciente.';
    } else {
      description = 'Dosis calculada dentro de rangos seguros para $medicationName.';
    }

    return CalculationResult(
      result: roundedDose,
      unit: 'mg',
      label: 'Dosis Total',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Peso (kg)': weight,
        'Dosis/kg (mg/kg)': dosePerKg,
        'Dosis calculada (mg)': roundedDose,
        if (maxDose != null) 'Dosis máxima (mg)': maxDose,
      },
    );
  }
}
