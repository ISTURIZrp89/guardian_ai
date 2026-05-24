import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class CalculateAnionGapUseCase {
  CalculationResult execute({
    required double sodium,
    required double chloride,
    required double bicarbonate,
  }) {
    if (sodium < 100 || sodium > 200) {
      throw ValidationException(
        'El sodio debe estar entre 100 y 200 mEq/L',
        code: 'INVALID_SODIUM',
      );
    }

    if (chloride < 60 || chloride > 140) {
      throw ValidationException(
        'El cloro debe estar entre 60 y 140 mEq/L',
        code: 'INVALID_CHLORIDE',
      );
    }

    if (bicarbonate < 5 || bicarbonate > 50) {
      throw ValidationException(
        'El bicarbonato debe estar entre 5 y 50 mEq/L',
        code: 'INVALID_BICARBONATE',
      );
    }

    final anionGap = sodium - (chloride + bicarbonate);
    final roundedGap = (anionGap * 10).roundToDouble() / 10;

    String description;
    bool isWarning = false;
    bool isCritical = false;

    if (anionGap > 20) {
      isCritical = true;
      description = 'Brecha aniónica muy elevada ($roundedGap mEq/L). '
          'Sugiere acidosis metabólica grave. '
          'Causas: CAD, acidosis láctica, insuficiencia renal, tóxicos. '
          'Calcular osmolar gap y evaluar estado ácido-base.';
    } else if (anionGap > 12) {
      isWarning = true;
      description = 'Brecha aniónica elevada ($roundedGap mEq/L). '
          'Posible acidosis metabólica. '
          'Evaluar causas: cetoacidosis, acidosis láctica, IRC, tóxicos. '
          'Rango normal: 8-12 mEq/L.';
    } else if (anionGap < 8) {
      isWarning = true;
      description = 'Brecha aniónica baja ($roundedGap mEq/L). '
          'Posibles causas: hipoalbuminemia, mieloma múltiple, '
          'hipernatremia, intoxicación por litio. '
          'Rango normal: 8-12 mEq/L.';
    } else {
      description = 'Brecha aniónica dentro de rango normal ($roundedGap mEq/L). '
          'Valor de referencia: 8-12 mEq/L.';
    }

    return CalculationResult(
      result: roundedGap,
      unit: 'mEq/L',
      label: 'Brecha Aniónica (Anion Gap)',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Na⁺ (mEq/L)': sodium,
        'Cl⁻ (mEq/L)': chloride,
        'HCO₃⁻ (mEq/L)': bicarbonate,
        'Anion Gap (mEq/L)': roundedGap,
      },
    );
  }
}
