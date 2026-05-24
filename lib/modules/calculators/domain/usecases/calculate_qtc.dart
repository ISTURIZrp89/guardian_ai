import 'dart:math';
import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class CalculateQtcUseCase {
  CalculationResult execute({
    required double qtIntervalMs,
    required double heartRate,
  }) {
    if (qtIntervalMs < 100 || qtIntervalMs > 800) {
      throw ValidationException(
        'El intervalo QT debe estar entre 100 y 800 ms',
        code: 'INVALID_QT_INTERVAL',
      );
    }

    if (heartRate < 20 || heartRate > 300) {
      throw ValidationException(
        'La frecuencia cardíaca debe estar entre 20 y 300 lpm',
        code: 'INVALID_HEART_RATE',
      );
    }

    final rrInterval = 60.0 / heartRate;
    final qtc = qtIntervalMs / sqrt(rrInterval);
    final roundedQtc = (qtc * 10).roundToDouble() / 10;

    String description;
    bool isWarning = false;
    bool isCritical = false;

    if (roundedQtc > 500) {
      isCritical = true;
      description = '¡ALERTA! QTc muy prolongado ($roundedQtc ms). '
          'Riesgo elevado de torsade de pointes. Suspender fármacos que prolongan QTc. '
          'Corregir electrolitos (K+, Mg2+).';
    } else if (roundedQtc > 460) {
      isWarning = true;
      description = 'QTc prolongado en mujer ($roundedQtc ms). '
          'Monitorear electrolitos y ECG seriado. '
          'Valor normal: < 460 ms en mujeres.';
    } else if (roundedQtc > 450) {
      isWarning = true;
      description = 'QTc prolongado en hombre ($roundedQtc ms). '
          'Monitorear electrolitos y ECG seriado. '
          'Valor normal: < 450 ms en hombres.';
    } else {
      description = 'QTc dentro de límites normales ($roundedQtc ms).';
    }

    return CalculationResult(
      result: roundedQtc,
      unit: 'ms',
      label: 'QT Corregido (Bazett)',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'QT (ms)': qtIntervalMs,
        'FC (lpm)': heartRate,
        'RR (s)': (rrInterval * 100).roundToDouble() / 100,
        'QTc (ms)': roundedQtc,
      },
    );
  }
}
