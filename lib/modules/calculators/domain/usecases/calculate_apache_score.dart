import '../../../../core/errors/app_exceptions.dart';
import '../entities/calculation_result.dart';

class CalculateApacheScoreUseCase {
  CalculationResult execute({
    required int age,
    required double heartRate,
    required double meanArterialPressure,
    required double temperature,
    required double creatinine,
    required double hematocrit,
    required double wbc,
    required int glasgowComaScore,
  }) {
    if (age < 16 || age > 110) {
      throw ValidationException(
        'La edad debe estar entre 16 y 110 años',
        code: 'INVALID_AGE',
      );
    }

    if (heartRate < 0 || heartRate > 300) {
      throw ValidationException(
        'La frecuencia cardíaca debe estar entre 0 y 300 lpm',
        code: 'INVALID_HEART_RATE',
      );
    }

    if (meanArterialPressure < 20 || meanArterialPressure > 250) {
      throw ValidationException(
        'La presión arterial media debe estar entre 20 y 250 mmHg',
        code: 'INVALID_MAP',
      );
    }

    if (temperature < 30 || temperature > 45) {
      throw ValidationException(
        'La temperatura debe estar entre 30 y 45 °C',
        code: 'INVALID_TEMPERATURE',
      );
    }

    if (creatinine < 0 || creatinine > 20) {
      throw ValidationException(
        'La creatinina debe estar entre 0 y 20 mg/dL',
        code: 'INVALID_CREATININE',
      );
    }

    if (hematocrit < 10 || hematocrit > 70) {
      throw ValidationException(
        'El hematocrito debe estar entre 10% y 70%',
        code: 'INVALID_HEMATOCRIT',
      );
    }

    if (wbc < 0 || wbc > 200) {
      throw ValidationException(
        'Los leucocitos deben estar entre 0 y 200 x10³/mm³',
        code: 'INVALID_WBC',
      );
    }

    if (glasgowComaScore < 3 || glasgowComaScore > 15) {
      throw ValidationException(
        'El Glasgow debe estar entre 3 y 15',
        code: 'INVALID_GCS',
      );
    }

    final ageScore = _scoreAge(age);
    final hrScore = _scoreHeartRate(heartRate);
    final mapScore = _scoreMap(meanArterialPressure);
    final tempScore = _scoreTemperature(temperature);
    final creatScore = _scoreCreatinine(creatinine);
    final hctScore = _scoreHematocrit(hematocrit);
    final wbcScore = _scoreWbc(wbc);
    final gcsScore = _scoreGcs(glasgowComaScore);

    final totalScore = ageScore + hrScore + mapScore + tempScore +
        creatScore + hctScore + wbcScore + gcsScore;

    String description;
    bool isWarning = false;
    bool isCritical = false;

    if (totalScore >= 25) {
      isCritical = true;
      description = 'APACHE II: $totalScore puntos. '
          'Riesgo de mortalidad muy alto (> 80%). '
          'Requiere manejo intensivo multidisciplinario urgente.';
    } else if (totalScore >= 20) {
      isCritical = true;
      description = 'APACHE II: $totalScore puntos. '
          'Riesgo de mortalidad alto (40-80%). '
          'Monitoreo estricto en UCI.';
    } else if (totalScore >= 15) {
      isWarning = true;
      description = 'APACHE II: $totalScore puntos. '
          'Riesgo de mortalidad moderado (20-40%). '
          'Requiere vigilancia continua.';
    } else if (totalScore >= 10) {
      isWarning = true;
      description = 'APACHE II: $totalScore puntos. '
          'Riesgo de mortalidad bajo (10-20%). '
          'Continuar monitoreo.';
    } else {
      description = 'APACHE II: $totalScore puntos. '
          'Riesgo de mortalidad mínimo (< 10%).';
    }

    return CalculationResult(
      result: totalScore.toDouble(),
      unit: 'puntos',
      label: 'APACHE II Score',
      description: description,
      isWarning: isWarning,
      isCritical: isCritical,
      details: {
        'Edad (puntos)': ageScore.toDouble(),
        'FC (puntos)': hrScore.toDouble(),
        'PAM (puntos)': mapScore.toDouble(),
        'Temperatura (puntos)': tempScore.toDouble(),
        'Creatinina (puntos)': creatScore.toDouble(),
        'Hematocrito (puntos)': hctScore.toDouble(),
        'Leucocitos (puntos)': wbcScore.toDouble(),
        'GCS (puntos)': gcsScore.toDouble(),
        'Total': totalScore.toDouble(),
      },
    );
  }

  int _scoreAge(int age) {
    if (age <= 44) return 0;
    if (age <= 54) return 2;
    if (age <= 64) return 3;
    if (age <= 74) return 5;
    return 6;
  }

  int _scoreHeartRate(double hr) {
    if (hr >= 180 || hr <= 39) return 4;
    if (hr >= 140 || hr <= 54) return 3;
    if (hr >= 110 || hr <= 69) return 2;
    if (hr >= 100 || hr <= 59) return 1;
    return 0;
  }

  int _scoreMap(double map) {
    if (map >= 160 || map <= 49) return 4;
    if (map >= 130 || map <= 59) return 3;
    if (map >= 110 || map <= 69) return 2;
    if (map >= 100 || map <= 79) return 1;
    return 0;
  }

  int _scoreTemperature(double temp) {
    if (temp >= 41 || temp <= 29.9) return 4;
    if (temp >= 39 || temp <= 31.9) return 3;
    if (temp >= 38.5 || temp <= 33.9) return 2;
    if (temp >= 36 || temp <= 35.9) return 1;
    return 0;
  }

  int _scoreCreatinine(double creat) {
    if (creat >= 3.5) return 4;
    if (creat >= 2.0) return 3;
    if (creat >= 1.5) return 2;
    if (creat >= 0.6) return 1;
    return 0;
  }

  int _scoreHematocrit(double hct) {
    if (hct >= 60 || hct <= 19.9) return 4;
    if (hct >= 50 || hct <= 29.9) return 2;
    if (hct >= 46 || hct <= 39.9) return 1;
    return 0;
  }

  int _scoreWbc(double wbc) {
    if (wbc >= 40 || wbc <= 1) return 4;
    if (wbc >= 20 || wbc <= 2.9) return 2;
    if (wbc >= 15 || wbc <= 3.9) return 1;
    return 0;
  }

  int _scoreGcs(int gcs) {
    return 15 - gcs;
  }
}
