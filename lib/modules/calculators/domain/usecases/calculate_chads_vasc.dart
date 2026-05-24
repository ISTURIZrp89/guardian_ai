import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class CalculateChadsVascUseCase {
  CalculationResult execute({
    required int age,
    required bool hasHeartFailure,
    required bool hasHypertension,
    required bool hasDiabetes,
    required bool hasStroke,
    required bool hasVascularDisease,
    required bool isFemale,
  }) {
    if (age < 0 || age > 130) {
      throw ValidationException(
        'La edad debe estar entre 0 y 130 años',
        code: 'INVALID_AGE',
      );
    }

    var score = 0;

    if (age >= 75) {
      score += 2;
    } else if (age >= 65) {
      score += 1;
    }

    if (hasHeartFailure) score += 1;
    if (hasHypertension) score += 1;
    if (hasDiabetes) score += 1;
    if (hasStroke) score += 2;
    if (hasVascularDisease) score += 1;
    if (isFemale) score += 1;

    String description;
    bool isWarning = false;
    bool isCritical = false;

    if (score >= 6) {
      isCritical = true;
      description = 'CHA₂DS₂-VASc: $score — Riesgo alto de ACV (≥ 9% anual). '
          'Requiere anticoagulación oral (NOAC o warfarina). '
          'Evaluar riesgo de sangrado (HAS-BLED).';
    } else if (score >= 3) {
      isCritical = true;
      description = 'CHA₂DS₂-VASc: $score — Riesgo moderado a alto de ACV. '
          'Recomendación: anticoagulación oral. '
          'Considerar HAS-BLED para evaluar riesgo de sangrado.';
    } else if (score >= 2) {
      isWarning = true;
      description = 'CHA₂DS₂-VASc: $score — Riesgo moderado de ACV. '
          'Recomendación: anticoagulación oral en mayoría de pacientes. '
          'Valorar riesgo/beneficio individualmente.';
    } else if (score == 1) {
      isWarning = true;
      description = 'CHA₂DS₂-VASc: $score — Riesgo bajo a moderado de ACV. '
          'Considerar anticoagulación según factores de riesgo adicionales. '
          'Opcional: AAS si no hay indicación de anticoagulación.';
    } else {
      description = 'CHA₂DS₂-VASc: $score — Riesgo bajo de ACV. '
          'No requiere anticoagulación ni antiagregación.';
    }

    return CalculationResult(
      result: score.toDouble(),
      unit: 'puntos',
      label: 'CHA₂DS₂-VASc Score',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Edad ≥ 75 (2 pts)': age >= 75 ? 2.0 : 0.0,
        'Edad 65-74 (1 pt)': age >= 65 && age < 75 ? 1.0 : 0.0,
        'Insuficiencia cardíaca': hasHeartFailure ? 1.0 : 0.0,
        'Hipertensión': hasHypertension ? 1.0 : 0.0,
        'Diabetes': hasDiabetes ? 1.0 : 0.0,
        'ACV/AIT/TE (2 pts)': hasStroke ? 2.0 : 0.0,
        'Enfermedad vascular': hasVascularDisease ? 1.0 : 0.0,
        'Sexo femenino': isFemale ? 1.0 : 0.0,
        'Puntaje total': score.toDouble(),
      },
    );
  }
}
