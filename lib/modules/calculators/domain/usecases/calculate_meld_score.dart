import 'dart:math';
import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class CalculateMeldScoreUseCase {
  CalculationResult execute({
    required double bilirubin,
    required double inr,
    required double creatinine,
  }) {
    if (bilirubin <= 0 || bilirubin > 100) {
      throw ValidationException(
        'La bilirrubina debe ser mayor a 0 y menor a 100 mg/dL',
        code: 'INVALID_BILIRUBIN',
      );
    }

    if (inr <= 0 || inr > 20) {
      throw ValidationException(
        'El INR debe ser mayor a 0 y menor a 20',
        code: 'INVALID_INR',
      );
    }

    if (creatinine <= 0 || creatinine > 20) {
      throw ValidationException(
        'La creatinina debe ser mayor a 0 y menor a 20 mg/dL',
        code: 'INVALID_CREATININE',
      );
    }

    final lnBilirubin = log(bilirubin);
    final lnInr = log(inr);
    final lnCreatinine = log(creatinine);

    var meld = 3.78 * lnBilirubin + 11.2 * lnInr + 9.57 * lnCreatinine + 6.43;

    if (creatinine > 4.0) {
      meld = 3.78 * lnBilirubin + 11.2 * lnInr + 9.57 * log(4.0) + 6.43;
    }

    final roundedMeld = (meld * 10).roundToDouble() / 10;
    final finalScore = roundedMeld.clamp(6.0, 40.0);

    String description;
    bool isWarning = false;
    bool isCritical = false;

    if (finalScore >= 30) {
      isCritical = true;
      description = 'MELD $finalScore — Riesgo de mortalidad a 3 meses: > 75%. '
          'Prioridad alta para trasplante hepático. '
          'Requiere evaluación urgente por equipo de trasplante.';
    } else if (finalScore >= 20) {
      isCritical = true;
      description = 'MELD $finalScore — Riesgo de mortalidad a 3 meses: 20-50%. '
          'Evaluación para trasplante hepático. '
          'Monitoreo estrecho de función hepática y renal.';
    } else if (finalScore >= 10) {
      isWarning = true;
      description = 'MELD $finalScore — Riesgo de mortalidad a 3 meses: 6-20%. '
          'Enfermedad hepática compensada. '
          'Seguimiento ambulatorio regular.';
    } else {
      description = 'MELD $finalScore — Riesgo de mortalidad a 3 meses: < 6%. '
          'Enfermedad hepática leve. Pronóstico favorable.';
    }

    return CalculationResult(
      result: finalScore,
      unit: 'puntos',
      label: 'MELD Score',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Bilirrubina (mg/dL)': bilirubin,
        'INR': inr,
        'Creatinina (mg/dL)': creatinine,
        'Ln(Bilirrubina)': (lnBilirubin * 100).roundToDouble() / 100,
        'Ln(INR)': (lnInr * 100).roundToDouble() / 100,
        'Ln(Creatinina)': (lnCreatinine * 100).roundToDouble() / 100,
        'MELD Score': finalScore,
      },
    );
  }
}
