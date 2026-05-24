import '../entities/calculation_result.dart';

class CalculateCurb65UseCase {
  CalculationResult execute({
    required bool confusion,
    required bool bunOver7,
    required bool respiratoryRateOver30,
    required bool lowBloodPressure,
    required bool ageOver65,
  }) {
    var score = 0;

    if (confusion) score += 1;
    if (bunOver7) score += 1;
    if (respiratoryRateOver30) score += 1;
    if (lowBloodPressure) score += 1;
    if (ageOver65) score += 1;

    String description;
    bool isWarning = false;
    bool isCritical = false;

    switch (score) {
      case 0:
      case 1:
        description = 'CURB-65: $score — Neumonía leve. '
            'Mortalidad estimada: < 2%. '
            'Tratamiento: manejo ambulatorio con antibióticos orales.';
        break;
      case 2:
        isWarning = true;
        description = 'CURB-65: $score — Neumonía moderada. '
            'Mortalidad estimada: 9-15%. '
            'Tratamiento: hospitalización en sala general. '
            'Antibióticos intravenosos.';
        break;
      case 3:
        isCritical = true;
        description = 'CURB-65: $score — Neumonía severa. '
            'Mortalidad estimada: 15-22%. '
            'Tratamiento: hospitalización, considerar UCI. '
            'Antibióticos IV y monitoreo estrecho.';
        break;
      case 4:
      case 5:
        isCritical = true;
        description = 'CURB-65: $score — Neumonía muy severa. '
            'Mortalidad estimada: > 30%. '
            'Tratamiento: ingreso a UCI. '
            'Antibióticos IV de amplio espectro, soporte ventilatorio.';
        break;
      default:
        isWarning = true;
        description = 'CURB-65: $score. Evaluar condición clínica completa.';
    }

    return CalculationResult(
      result: score.toDouble(),
      unit: 'puntos',
      label: 'CURB-65',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Confusión (1 pt)': confusion ? 1.0 : 0.0,
        'BUN > 7 mmol/L (1 pt)': bunOver7 ? 1.0 : 0.0,
        'FR ≥ 30/min (1 pt)': respiratoryRateOver30 ? 1.0 : 0.0,
        'PA baja (1 pt)': lowBloodPressure ? 1.0 : 0.0,
        'Edad ≥ 65 (1 pt)': ageOver65 ? 1.0 : 0.0,
        'Puntaje total': score.toDouble(),
      },
    );
  }
}
