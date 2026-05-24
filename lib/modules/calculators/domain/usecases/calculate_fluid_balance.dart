import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class CalculateFluidBalanceUseCase {
  CalculationResult execute({
    required double totalInput,
    required double totalOutput,
  }) {
    if (totalInput < 0) {
      throw ValidationException(
        'El ingreso total no puede ser negativo',
        code: 'NEGATIVE_INPUT',
      );
    }

    if (totalOutput < 0) {
      throw ValidationException(
        'El egreso total no puede ser negativo',
        code: 'NEGATIVE_OUTPUT',
      );
    }

    if (totalInput > 20000) {
      throw ValidationException(
        'El ingreso total no puede exceder 20000 mL',
        code: 'INPUT_EXCEEDS_MAX',
      );
    }

    if (totalOutput > 20000) {
      throw ValidationException(
        'El egreso total no puede exceder 20000 mL',
        code: 'OUTPUT_EXCEEDS_MAX',
      );
    }

    final balance = totalInput - totalOutput;
    final roundedBalance = (balance * 10).roundToDouble() / 10;

    String description;
    bool isWarning = false;
    bool isCritical = false;

    if (roundedBalance > 3000) {
      isCritical = true;
      description = '¡ALERTA! Balance hídrico positivo severo (> 3000 mL). '
          'Riesgo de edema pulmonar. Evaluar uso de diuréticos.';
    } else if (roundedBalance > 1500) {
      isWarning = true;
      description = 'Balance hídrico positivo significativo (> 1500 mL). '
          'Evaluar riesgo de sobrecarga de volumen.';
    } else if (roundedBalance < -3000) {
      isCritical = true;
      description = '¡ALERTA! Balance hídrico negativo severo (< -3000 mL). '
          'Riesgo de shock hipovolémico. Reponer volumen urgentemente.';
    } else if (roundedBalance < -1500) {
      isWarning = true;
      description = 'Balance hídrico negativo significativo (< -1500 mL). '
          'Evaluar riesgo de hipovolemia.';
    } else {
      description = 'Balance hídrico dentro de rangos aceptables.';
    }

    return CalculationResult(
      result: roundedBalance,
      unit: 'mL',
      label: 'Balance Hídrico',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Total Ingresos (mL)': totalInput,
        'Total Egresos (mL)': totalOutput,
        'Balance (mL)': roundedBalance,
      },
    );
  }
}
