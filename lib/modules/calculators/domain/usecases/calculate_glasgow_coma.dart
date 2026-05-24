import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class CalculateGlasgowComaUseCase {
  CalculationResult execute({
    required int eyeOpening,
    required int verbalResponse,
    required int motorResponse,
  }) {
    if (eyeOpening < 1 || eyeOpening > 4) {
      throw ValidationException(
        'La apertura ocular debe estar entre 1 y 4',
        code: 'INVALID_EYE_OPENING',
      );
    }

    if (verbalResponse < 1 || verbalResponse > 5) {
      throw ValidationException(
        'La respuesta verbal debe estar entre 1 y 5',
        code: 'INVALID_VERBAL_RESPONSE',
      );
    }

    if (motorResponse < 1 || motorResponse > 6) {
      throw ValidationException(
        'La respuesta motora debe estar entre 1 y 6',
        code: 'INVALID_MOTOR_RESPONSE',
      );
    }

    final totalScore = eyeOpening + verbalResponse + motorResponse;

    String description;
    bool isWarning = false;
    bool isCritical = false;

    if (totalScore <= 8) {
      isCritical = true;
      description = 'Lesión cerebral severa (GCS $totalScore). '
          'Requiere intubación y manejo en UCI. Glasgow = $totalScore/15';
    } else if (totalScore <= 12) {
      isWarning = true;
      description = 'Lesión cerebral moderada (GCS $totalScore). '
          'Requiere monitoreo neurológico estricto. Glasgow = $totalScore/15';
    } else {
      description = 'Lesión cerebral leve (GCS $totalScore). '
          'Paciente consciente y orientado. Glasgow = $totalScore/15';
    }

    return CalculationResult(
      result: totalScore.toDouble(),
      unit: 'puntos',
      label: 'Escala de Coma de Glasgow',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Apertura ocular': eyeOpening.toDouble(),
        'Respuesta verbal': verbalResponse.toDouble(),
        'Respuesta motora': motorResponse.toDouble(),
        'Puntaje total': totalScore.toDouble(),
      },
    );
  }
}
