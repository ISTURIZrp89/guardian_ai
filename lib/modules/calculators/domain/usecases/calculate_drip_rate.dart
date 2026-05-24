import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class CalculateDripRateUseCase {
  static const double standardDropFactor = 20.0;

  CalculationResult calculateDropsPerMin({
    required double volumeMl,
    required double timeMinutes,
    double dropFactor = standardDropFactor,
  }) {
    _validateVolumeAndTime(volumeMl, timeMinutes);

    final dropsPerMin = (volumeMl * dropFactor) / timeMinutes;
    final rounded = (dropsPerMin * 10).roundToDouble() / 10;

    String description;
    bool isWarning = false;

    if (rounded > 60) {
      isWarning = true;
      description = 'Goteo rápido (> 60 gotas/min). Verificar tolerancia del paciente '
          'y considerar usar bomba de infusión.';
    } else if (rounded < 5) {
      isWarning = true;
      description = 'Goteo muy lento (< 5 gotas/min). Riesgo de obstrucción del acceso venoso.';
    } else {
      description = 'Velocidad de goteo dentro de rangos normales.';
    }

    return CalculationResult(
      result: rounded,
      unit: 'gotas/min',
      label: 'Gotas por Minuto',
      description: description,
      isWarning: isWarning,
      details: {
        'Volumen (mL)': volumeMl,
        'Tiempo (min)': timeMinutes,
        'Factor de goteo': dropFactor,
      },
    );
  }

  CalculationResult calculateMicrodropsPerMin({
    required double volumeMl,
    required double timeMinutes,
  }) {
    _validateVolumeAndTime(volumeMl, timeMinutes);

    final microdropsPerMin = (volumeMl * 60) / timeMinutes;
    final rounded = (microdropsPerMin * 10).roundToDouble() / 10;

    String description;
    bool isWarning = false;

    if (rounded > 200) {
      isWarning = true;
      description = 'Microgoteo muy rápido (> 200 microgotas/min). '
          'Considerar usar bomba de infusión.';
    } else {
      description = 'Velocidad de microgoteo dentro de rangos normales.';
    }

    return CalculationResult(
      result: rounded,
      unit: 'microgotas/min',
      label: 'Microgotas por Minuto',
      description: description,
      isWarning: isWarning,
      details: {
        'Volumen (mL)': volumeMl,
        'Tiempo (min)': timeMinutes,
      },
    );
  }

  void _validateVolumeAndTime(double volumeMl, double timeMinutes) {
    if (volumeMl <= 0) {
      throw ValidationException(
        'El volumen debe ser mayor a 0 mL',
        code: 'INVALID_VOLUME',
      );
    }

    if (volumeMl > 5000) {
      throw ValidationException(
        'El volumen no puede exceder 5000 mL',
        code: 'VOLUME_EXCEEDS_MAX',
      );
    }

    if (timeMinutes <= 0) {
      throw ValidationException(
        'El tiempo debe ser mayor a 0 minutos',
        code: 'INVALID_TIME',
      );
    }

    if (timeMinutes > 1440) {
      throw ValidationException(
        'El tiempo no puede exceder 1440 minutos (24 horas)',
        code: 'TIME_EXCEEDS_MAX',
      );
    }
  }
}
