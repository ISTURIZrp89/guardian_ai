import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class MaxDoseReference {
  final String medication;
  final double maxSingleDoseMg;
  final double maxDailyDoseMg;
  final double? maxDosePerKg;
  final String? notes;

  const MaxDoseReference({
    required this.medication,
    required this.maxSingleDoseMg,
    required this.maxDailyDoseMg,
    this.maxDosePerKg,
    this.notes,
  });

  static const Map<String, MaxDoseReference> common = {
    'paracetamol': MaxDoseReference(
      medication: 'Paracetamol',
      maxSingleDoseMg: 1000,
      maxDailyDoseMg: 4000,
      maxDosePerKg: 15,
      notes: 'Adulto sano. En hepatopatía: máx 2000 mg/día',
    ),
    'ibuprofeno': MaxDoseReference(
      medication: 'Ibuprofeno',
      maxSingleDoseMg: 800,
      maxDailyDoseMg: 2400,
      maxDosePerKg: 10,
      notes: 'Con alimentos. Evitar en IRC',
    ),
    'morfina': MaxDoseReference(
      medication: 'Morfina',
      maxSingleDoseMg: 10,
      maxDailyDoseMg: 30,
      notes: 'Vía oral. Ajustar en IRC',
    ),
    'tramadol': MaxDoseReference(
      medication: 'Tramadol',
      maxSingleDoseMg: 100,
      maxDailyDoseMg: 400,
      notes: 'Máx 300 mg/día en > 75 años',
    ),
    'amoxicilina': MaxDoseReference(
      medication: 'Amoxicilina',
      maxSingleDoseMg: 1000,
      maxDailyDoseMg: 3000,
      maxDosePerKg: 50,
      notes: 'Ajustar en IRC (FG < 30)',
    ),
    'omeprazol': MaxDoseReference(
      medication: 'Omeprazol',
      maxSingleDoseMg: 40,
      maxDailyDoseMg: 80,
      notes: 'Máx 120 mg/día en síndrome Zollinger-Ellison',
    ),
    'enoxaparina': MaxDoseReference(
      medication: 'Enoxaparina',
      maxSingleDoseMg: 100,
      maxDailyDoseMg: 200,
      maxDosePerKg: 1.5,
      notes: 'vía SC. Ajustar en IRC',
    ),
    'metformina': MaxDoseReference(
      medication: 'Metformina',
      maxSingleDoseMg: 1000,
      maxDailyDoseMg: 2550,
      notes: 'Suspender si FG < 30',
    ),
    'furosemida': MaxDoseReference(
      medication: 'Furosemida',
      maxSingleDoseMg: 80,
      maxDailyDoseMg: 240,
      maxDosePerKg: 2,
      notes: 'Vía IV. Monitorizar K+',
    ),
    'haloperidol': MaxDoseReference(
      medication: 'Haloperidol',
      maxSingleDoseMg: 10,
      maxDailyDoseMg: 30,
      notes: 'Monitorizar QTc. Evitar en Parkinson',
    ),
  };
}

class CalculateMaxDoseCheckUseCase {
  CalculationResult execute({
    required String medication,
    required double calculatedDose,
    required String doseType,
    double? weightKg,
  }) {
    if (calculatedDose <= 0) {
      throw ValidationException(
        'La dosis calculada debe ser mayor a 0',
        code: 'INVALID_DOSE',
      );
    }

    final normalizedName = medication.toLowerCase().trim();
    final reference = MaxDoseReference.common[normalizedName];

    if (reference == null) {
      throw ValidationException(
        'Medicamento "$medication" no encontrado en la base de referencia. '
        'Medicamentos disponibles: ${MaxDoseReference.common.keys.join(", ")}',
        code: 'UNKNOWN_MEDICATION',
      );
    }

    bool isWarning = false;
    bool isCritical = false;
    String? description;
    final issues = <String>[];

    double? relevantMax;
    if (doseType == 'single') {
      relevantMax = reference.maxSingleDoseMg;
    } else {
      relevantMax = reference.maxDailyDoseMg;
    }

    if (calculatedDose > relevantMax) {
      isCritical = true;
      issues.add(
        'La dosis calculada (${calculatedDose.toStringAsFixed(2)} mg) '
        'supera la dosis ${doseType == 'single' ? 'única' : 'diaria'} máxima recomendada '
        'de ${relevantMax.toStringAsFixed(2)} mg',
      );
    } else if (calculatedDose > relevantMax * 0.9) {
      isWarning = true;
      issues.add(
        'La dosis calculada está cerca del límite máximo '
        '(${relevantMax.toStringAsFixed(2)} mg)',
      );
    }

    if (reference.maxDosePerKg != null && weightKg != null) {
      final dosePerKg = calculatedDose / weightKg;
      if (dosePerKg > reference.maxDosePerKg!) {
        isCritical = true;
        issues.add(
          'La dosis por kg (${dosePerKg.toStringAsFixed(2)} mg/kg) '
          'supera el máximo recomendado de ${reference.maxDosePerKg} mg/kg',
        );
      }
    }

    if (issues.isEmpty) {
      description = 'Dosis segura. La dosis de ${reference.medication} '
          'está dentro de los límites recomendados.';
    } else {
      description = issues.join('. ');
      if (reference.notes != null) {
        description += '. Nota: ${reference.notes}';
      }
    }

    return CalculationResult(
      result: calculatedDose,
      unit: 'mg',
      label: 'Verificación: ${reference.medication}',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Dosis calculada (mg)': calculatedDose,
        'Dosis máxima $doseType (mg)': relevantMax.toDouble(),
        if (reference.maxDosePerKg != null)
          'Dosis máxima por kg (mg/kg)': reference.maxDosePerKg!.toDouble(),
        if (weightKg != null) 'Peso (kg)': weightKg,
      },
    );
  }
}
