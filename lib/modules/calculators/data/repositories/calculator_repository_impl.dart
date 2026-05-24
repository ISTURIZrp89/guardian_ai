import 'package:guardian_ai/core/errors/failures.dart';
import 'package:guardian_ai/core/errors/app_exceptions.dart';
import 'package:guardian_ai/modules/calculators/domain/entities/calculation_result.dart';
import 'package:guardian_ai/modules/calculators/domain/entities/clinical_formula.dart';
import 'package:guardian_ai/modules/calculators/domain/repositories/calculator_repository.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_dose.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_infusion.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_drip_rate.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_body_surface.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_fluid_balance.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_pediatric_dose.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_vasopressor.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_max_dose_check.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_glasgow_coma.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_qtc.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_anion_gap.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_apache_score.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_meld_score.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_chads_vasc.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_wells_criteria.dart';
import 'package:guardian_ai/modules/calculators/domain/usecases/calculate_curb65.dart';

class CalculatorRepositoryImpl implements CalculatorRepository {
  final CalculateDoseUseCase _calculateDose;
  final CalculateInfusionUseCase _calculateInfusion;
  final CalculateDripRateUseCase _calculateDripRate;
  final CalculateBodySurfaceUseCase _calculateBodySurface;
  final CalculateFluidBalanceUseCase _calculateFluidBalance;
  final CalculatePediatricDoseUseCase _calculatePediatricDose;
  final CalculateVasopressorUseCase _calculateVasopressor;
  final CalculateMaxDoseCheckUseCase _calculateMaxDoseCheck;
  final CalculateGlasgowComaUseCase _calculateGlasgowComa;
  final CalculateQtcUseCase _calculateQtc;
  final CalculateAnionGapUseCase _calculateAnionGap;
  final CalculateApacheScoreUseCase _calculateApacheScore;
  final CalculateMeldScoreUseCase _calculateMeldScore;
  final CalculateChadsVascUseCase _calculateChadsVasc;
  final CalculateWellsCriteriaUseCase _calculateWellsCriteria;
  final CalculateCurb65UseCase _calculateCurb65;

  CalculatorRepositoryImpl({
    CalculateDoseUseCase? calculateDose,
    CalculateInfusionUseCase? calculateInfusion,
    CalculateDripRateUseCase? calculateDripRate,
    CalculateBodySurfaceUseCase? calculateBodySurface,
    CalculateFluidBalanceUseCase? calculateFluidBalance,
    CalculatePediatricDoseUseCase? calculatePediatricDose,
    CalculateVasopressorUseCase? calculateVasopressor,
    CalculateMaxDoseCheckUseCase? calculateMaxDoseCheck,
    CalculateGlasgowComaUseCase? calculateGlasgowComa,
    CalculateQtcUseCase? calculateQtc,
    CalculateAnionGapUseCase? calculateAnionGap,
    CalculateApacheScoreUseCase? calculateApacheScore,
    CalculateMeldScoreUseCase? calculateMeldScore,
    CalculateChadsVascUseCase? calculateChadsVasc,
    CalculateWellsCriteriaUseCase? calculateWellsCriteria,
    CalculateCurb65UseCase? calculateCurb65,
  })  : _calculateDose = calculateDose ?? CalculateDoseUseCase(),
        _calculateInfusion = calculateInfusion ?? CalculateInfusionUseCase(),
        _calculateDripRate = calculateDripRate ?? CalculateDripRateUseCase(),
        _calculateBodySurface = calculateBodySurface ?? CalculateBodySurfaceUseCase(),
        _calculateFluidBalance = calculateFluidBalance ?? CalculateFluidBalanceUseCase(),
        _calculatePediatricDose = calculatePediatricDose ?? CalculatePediatricDoseUseCase(),
        _calculateVasopressor = calculateVasopressor ?? CalculateVasopressorUseCase(),
        _calculateMaxDoseCheck = calculateMaxDoseCheck ?? CalculateMaxDoseCheckUseCase(),
        _calculateGlasgowComa = calculateGlasgowComa ?? CalculateGlasgowComaUseCase(),
        _calculateQtc = calculateQtc ?? CalculateQtcUseCase(),
        _calculateAnionGap = calculateAnionGap ?? CalculateAnionGapUseCase(),
        _calculateApacheScore = calculateApacheScore ?? CalculateApacheScoreUseCase(),
        _calculateMeldScore = calculateMeldScore ?? CalculateMeldScoreUseCase(),
        _calculateChadsVasc = calculateChadsVasc ?? CalculateChadsVascUseCase(),
        _calculateWellsCriteria = calculateWellsCriteria ?? CalculateWellsCriteriaUseCase(),
        _calculateCurb65 = calculateCurb65 ?? CalculateCurb65UseCase();

  @override
  CalculationResult calculate(ClinicalFormulaType type, Map<String, double> params) {
    try {
      switch (type) {
        case ClinicalFormulaType.mgKgDose:
          return _calculateDose.execute(
            weight: params['weight']!,
            dosePerKg: params['dosePerKg']!,
            maxDose: params['maxDose'],
            medicationName: '',
          );

        case ClinicalFormulaType.pediatricDose:
          return _calculatePediatricDose.execute(
            weightKg: params['weightKg']!,
            adultDose: params['adultDose']!,
            maxPediatricDose: params['maxPediatricDose'],
          );

        case ClinicalFormulaType.infusionMlPerH:
          return _calculateInfusion.execute(
            dose: params['dose']!,
            weight: params['weight']!,
            concentration: params['concentration']!,
            maxRate: params['maxRate'],
          );

        case ClinicalFormulaType.dropsPerMin:
          return _calculateDripRate.calculateDropsPerMin(
            volumeMl: params['volumeMl']!,
            timeMinutes: params['timeMinutes']!,
            dropFactor: params['dropFactor'] ?? CalculateDripRateUseCase.standardDropFactor,
          );

        case ClinicalFormulaType.microdropsPerMin:
          return _calculateDripRate.calculateMicrodropsPerMin(
            volumeMl: params['volumeMl']!,
            timeMinutes: params['timeMinutes']!,
          );

        case ClinicalFormulaType.bodySurfaceArea:
          return _calculateBodySurface.execute(
            heightCm: params['heightCm']!,
            weightKg: params['weightKg']!,
          );

        case ClinicalFormulaType.fluidBalance:
          return _calculateFluidBalance.execute(
            totalInput: params['totalInput']!,
            totalOutput: params['totalOutput']!,
          );

        case ClinicalFormulaType.vasopressorDose:
          final vasopressors = [
            'noradrenalina', 'dobutamina', 'dopamina',
            'adrenalina', 'vasopresina',
          ];
          final vIndex = params['vasopressorName']?.toInt() ?? 0;
          final vName = vasopressors[vIndex.clamp(0, vasopressors.length - 1)];
          return _calculateVasopressor.execute(
            vasopressorName: vName,
            weight: params['weight']!,
            doseMcgKgMin: params['doseMcgKgMin']!,
            concentrationMcgPerMl: params['concentrationMcgPerMl'],
          );

        case ClinicalFormulaType.maxDoseCheck:
          final medications = [
            'paracetamol', 'ibuprofeno', 'morfina', 'tramadol',
            'amoxicilina', 'omeprazol', 'enoxaparina', 'metformina',
            'furosemida', 'haloperidol',
          ];
          final mIndex = params['medication']?.toInt() ?? 0;
          final medName = medications[mIndex.clamp(0, medications.length - 1)];
          final doseTypes = ['single', 'daily'];
          final dIndex = params['doseType']?.toInt() ?? 0;
          final dType = doseTypes[dIndex.clamp(0, 1)];
          return _calculateMaxDoseCheck.execute(
            medication: medName,
            calculatedDose: params['calculatedDose']!,
            doseType: dType,
            weightKg: params['weightKg'],
          );

        case ClinicalFormulaType.mgToMl:
          return _mgToMl(
            mg: params['mg']!,
            concentrationMgPerMl: params['concentrationMgPerMl']!,
          );

        case ClinicalFormulaType.sedationScore:
          return _sedationScore(
            ramsayScore: params['ramsayScore']?.toInt() ?? 3,
          );

        case ClinicalFormulaType.glasgowComa:
          return _calculateGlasgowComa.execute(
            eyeOpening: params['eyeOpening']?.toInt() ?? 1,
            verbalResponse: params['verbalResponse']?.toInt() ?? 1,
            motorResponse: params['motorResponse']?.toInt() ?? 1,
          );

        case ClinicalFormulaType.qtc:
          return _calculateQtc.execute(
            qtIntervalMs: params['qtIntervalMs']!,
            heartRate: params['heartRate']!,
          );

        case ClinicalFormulaType.anionGap:
          return _calculateAnionGap.execute(
            sodium: params['sodium']!,
            chloride: params['chloride']!,
            bicarbonate: params['bicarbonate']!,
          );

        case ClinicalFormulaType.apacheScore:
          return _calculateApacheScore.execute(
            age: params['age']?.toInt() ?? 44,
            heartRate: params['heartRate']!,
            meanArterialPressure: params['meanArterialPressure']!,
            temperature: params['temperature']!,
            creatinine: params['creatinine']!,
            hematocrit: params['hematocrit']!,
            wbc: params['wbc']!,
            glasgowComaScore: params['glasgowComaScore']?.toInt() ?? 15,
          );

        case ClinicalFormulaType.meldScore:
          return _calculateMeldScore.execute(
            bilirubin: params['bilirubin']!,
            inr: params['inr']!,
            creatinine: params['creatinine']!,
          );

        case ClinicalFormulaType.chadsVasc:
          return _calculateChadsVasc.execute(
            age: params['age']?.toInt() ?? 65,
            hasHeartFailure: (params['hasHeartFailure'] ?? 0) == 1,
            hasHypertension: (params['hasHypertension'] ?? 0) == 1,
            hasDiabetes: (params['hasDiabetes'] ?? 0) == 1,
            hasStroke: (params['hasStroke'] ?? 0) == 1,
            hasVascularDisease: (params['hasVascularDisease'] ?? 0) == 1,
            isFemale: (params['isFemale'] ?? 0) == 1,
          );

        case ClinicalFormulaType.wellsCriteria:
          return _calculateWellsCriteria.execute(
            hasClinicalSignsDvt: (params['hasClinicalSignsDvt'] ?? 0) == 1,
            hasAlternativeDiagnosis: (params['hasAlternativeDiagnosis'] ?? 0) == 1,
            heartRateOver100: (params['heartRateOver100'] ?? 0) == 1,
            hasImmobilizationOrSurgery: (params['hasImmobilizationOrSurgery'] ?? 0) == 1,
            hasPreviousDvtOrPe: (params['hasPreviousDvtOrPe'] ?? 0) == 1,
            hasHemoptysis: (params['hasHemoptysis'] ?? 0) == 1,
            hasMalignancy: (params['hasMalignancy'] ?? 0) == 1,
          );

        case ClinicalFormulaType.curb65:
          return _calculateCurb65.execute(
            confusion: (params['confusion'] ?? 0) == 1,
            bunOver7: (params['bunOver7'] ?? 0) == 1,
            respiratoryRateOver30: (params['respiratoryRateOver30'] ?? 0) == 1,
            lowBloodPressure: (params['lowBloodPressure'] ?? 0) == 1,
            ageOver65: (params['ageOver65'] ?? 0) == 1,
          );
      }
    } on ValidationException catch (e) {
      throw CalculationFailure(e.message, code: e.code);
    } on CalculationFailure {
      rethrow;
    } catch (e) {
      throw CalculationFailure(
        'Error inesperado al realizar el cálculo: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  CalculationResult _mgToMl({
    required double mg,
    required double concentrationMgPerMl,
  }) {
    if (mg <= 0) {
      throw CalculationFailure('Los mg deben ser mayor a 0', code: 'INVALID_MG');
    }
    if (concentrationMgPerMl <= 0) {
      throw CalculationFailure(
        'La concentración debe ser mayor a 0',
        code: 'INVALID_CONCENTRATION',
      );
    }

    final ml = mg / concentrationMgPerMl;
    final rounded = (ml * 100).roundToDouble() / 100;

    return CalculationResult(
      result: rounded,
      unit: 'mL',
      label: 'Conversión mg a mL',
      description: '${mg.toStringAsFixed(1)} mg equivalen a '
          '${rounded.toStringAsFixed(2)} mL a una concentración de '
          '${concentrationMgPerMl.toStringAsFixed(1)} mg/mL',
      details: {
        'mg': mg,
        'Concentración (mg/mL)': concentrationMgPerMl,
        'mL resultantes': rounded,
      },
    );
  }

  CalculationResult _sedationScore({required int ramsayScore}) {
    if (ramsayScore < 1 || ramsayScore > 6) {
      throw CalculationFailure(
        'El puntaje de Ramsay debe estar entre 1 y 6',
        code: 'INVALID_SCORE',
      );
    }

    final labels = {
      1: 'Paciente ansioso, agitado o inquieto',
      2: 'Paciente cooperador, orientado y tranquilo',
      3: 'Paciente dormido, responde a órdenes verbales',
      4: 'Paciente dormido, respuesta rápida a estímulo',
      5: 'Paciente dormido, respuesta lenta a estímulo',
      6: 'Paciente sin respuesta a estímulo doloroso',
    };

    final label = labels[ramsayScore] ?? 'Puntaje no reconocido';
    final isDeepSedation = ramsayScore >= 5;

    return CalculationResult(
      result: ramsayScore.toDouble(),
      unit: 'Ramsay',
      label: 'Escala de Sedación de Ramsay',
      description: 'Nivel $ramsayScore: $label',
      isWarning: isDeepSedation,
      isCritical: ramsayScore == 6,
      details: {
        'Puntaje': ramsayScore.toDouble(),
        'Sedación profunda': isDeepSedation ? 1.0 : 0.0,
      },
    );
  }
}
