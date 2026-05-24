import '../entities/calculation_result.dart';

class CalculateWellsCriteriaUseCase {
  CalculationResult execute({
    required bool hasClinicalSignsDvt,
    required bool hasAlternativeDiagnosis,
    required bool heartRateOver100,
    required bool hasImmobilizationOrSurgery,
    required bool hasPreviousDvtOrPe,
    required bool hasHemoptysis,
    required bool hasMalignancy,
  }) {
    double score = 0;

    if (hasClinicalSignsDvt) score += 3;
    if (hasAlternativeDiagnosis) score -= 3;
    if (heartRateOver100) score += 1.5;
    if (hasImmobilizationOrSurgery) score += 1.5;
    if (hasPreviousDvtOrPe) score += 1.5;
    if (hasHemoptysis) score += 1;
    if (hasMalignancy) score += 1;

    final roundedScore = (score * 10).roundToDouble() / 10;

    String classification;
    String description;
    bool isWarning = false;
    bool isCritical = false;

    if (roundedScore > 6) {
      isCritical = true;
      classification = 'Alta probabilidad';
      description = 'Criterios de Wells: $roundedScore — Alta probabilidad de TEP. '
          'Solicitar angio-TC de tórax o gammagrafía V/Q. '
          'Iniciar anticoagulación si hay sospecha clínica alta.';
    } else if (roundedScore >= 2) {
      isWarning = true;
      classification = 'Probabilidad moderada';
      description = 'Criterios de Wells: $roundedScore — Probabilidad moderada de TEP. '
          'Solicitar dímero D. Si es positivo, angio-TC de tórax. '
          'Considerar anticoagulación según riesgo.';
    } else {
      classification = 'Baja probabilidad';
      description = 'Criterios de Wells: $roundedScore — Baja probabilidad de TEP. '
          'Solicitar dímero D. Si es negativo (> 95% VPN), descartar TEP. '
          'Evaluar diagnósticos alternativos.';
    }

    return CalculationResult(
      result: roundedScore,
      unit: 'puntos',
      label: 'Criterios de Wells para TEP',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Signos clínicos de TVP (3 pts)': hasClinicalSignsDvt ? 3.0 : 0.0,
        'Diagnóstico alternativo (-3 pts)': hasAlternativeDiagnosis ? -3.0 : 0.0,
        'FC > 100 lpm (1.5 pts)': heartRateOver100 ? 1.5 : 0.0,
        'Inmovilización/cirugía (1.5 pts)': hasImmobilizationOrSurgery ? 1.5 : 0.0,
        'TVP/TEP previo (1.5 pts)': hasPreviousDvtOrPe ? 1.5 : 0.0,
        'Hemoptisis (1 pt)': hasHemoptysis ? 1.0 : 0.0,
        'Neoplasia activa (1 pt)': hasMalignancy ? 1.0 : 0.0,
        'Puntaje total': roundedScore,
      },
    );
  }
}
