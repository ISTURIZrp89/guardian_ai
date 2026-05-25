import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/calculation_result.dart';

class VasopressorInfo {
  final String name;
  final double standardConcentrationMcgPerMl;
  final double usualDoseMin;
  final double usualDoseMax;
  final String unit;

  const VasopressorInfo({
    required this.name,
    required this.standardConcentrationMcgPerMl,
    required this.usualDoseMin,
    required this.usualDoseMax,
    this.unit = 'mcg/kg/min',
  });

  static const Map<String, VasopressorInfo> common = {
    'noradrenalina': VasopressorInfo(
      name: 'Noradrenalina',
      standardConcentrationMcgPerMl: 32,
      usualDoseMin: 0.01,
      usualDoseMax: 0.5,
    ),
    'dobutamina': VasopressorInfo(
      name: 'Dobutamina',
      standardConcentrationMcgPerMl: 2500,
      usualDoseMin: 2,
      usualDoseMax: 20,
    ),
    'dopamina': VasopressorInfo(
      name: 'Dopamina',
      standardConcentrationMcgPerMl: 1600,
      usualDoseMin: 2,
      usualDoseMax: 20,
    ),
    'adrenalina': VasopressorInfo(
      name: 'Adrenalina',
      standardConcentrationMcgPerMl: 32,
      usualDoseMin: 0.01,
      usualDoseMax: 0.3,
    ),
    'vasopresina': VasopressorInfo(
      name: 'Vasopresina',
      standardConcentrationMcgPerMl: 0.4,
      usualDoseMin: 0.01,
      usualDoseMax: 0.04,
      unit: 'U/min',
    ),
  };
}

class CalculateVasopressorUseCase {
  CalculationResult execute({
    required String vasopressorName,
    required double weight,
    required double doseMcgKgMin,
    double? concentrationMcgPerMl,
  }) {
    if (weight < AppConstants.minWeightKg ||
        weight > AppConstants.maxWeightKg) {
      throw ValidationException(
        'El peso debe estar entre ${AppConstants.minWeightKg} y ${AppConstants.maxWeightKg} kg',
        code: 'INVALID_WEIGHT',
      );
    }

    if (doseMcgKgMin <= 0) {
      throw ValidationException(
        'La dosis debe ser mayor a 0 mcg/kg/min',
        code: 'INVALID_DOSE',
      );
    }

    final normalizedName = vasopressorName.toLowerCase().trim();
    final info = VasopressorInfo.common[normalizedName];

    final effectiveConcentration =
        concentrationMcgPerMl ?? info?.standardConcentrationMcgPerMl;
    if (effectiveConcentration == null) {
      throw ValidationException(
        'Vasopresor "$vasopressorName" no reconocido. Use: ${VasopressorInfo.common.keys.join(", ")}',
        code: 'UNKNOWN_VASOPRESSOR',
      );
    }

    final infusionRate = (doseMcgKgMin * weight * 60) / effectiveConcentration;
    final roundedRate = (infusionRate * 10).roundToDouble() / 10;

    bool isWarning = false;
    bool isCritical = false;
    String? description;

    if (info != null) {
      if (doseMcgKgMin > info.usualDoseMax) {
        isCritical = true;
        description =
            '¡ATENCIÓN! La dosis de ${info.name} (${doseMcgKgMin.toStringAsFixed(3)} ${info.unit}) '
            'supera el rango terapéutico máximo (${info.usualDoseMax} ${info.unit}). '
            'Riesgo de efectos adversos graves.';
      } else if (doseMcgKgMin > info.usualDoseMax * 0.8) {
        isWarning = true;
        description =
            'Dosis de ${info.name} en el límite superior del rango terapéutico '
            '(${info.usualDoseMin}-${info.usualDoseMax} ${info.unit}). Monitorear signos vitales.';
      } else if (doseMcgKgMin < info.usualDoseMin) {
        isWarning = true;
        description =
            'Dosis de ${info.name} por debajo del rango terapéutico habitual '
            '(${info.usualDoseMin}-${info.usualDoseMax} ${info.unit}). '
            'Evaluar respuesta clínica.';
      } else {
        description = 'Dosis de ${info.name} dentro del rango terapéutico '
            '(${info.usualDoseMin}-${info.usualDoseMax} ${info.unit}).';
      }
    }

    return CalculationResult(
      result: doseMcgKgMin,
      unit: 'mcg/kg/min',
      label: 'Dosis de ${info?.name ?? vasopressorName}',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Peso (kg)': weight,
        'Dosis (mcg/kg/min)': doseMcgKgMin,
        'Velocidad infusión (mL/h)': roundedRate,
        if (info != null) 'Rango usual (min)': info.usualDoseMin,
        if (info != null) 'Rango usual (max)': info.usualDoseMax,
      },
    );
  }
}
