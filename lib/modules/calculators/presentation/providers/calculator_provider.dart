import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_ai/core/errors/failures.dart';
import 'package:guardian_ai/modules/calculators/data/models/formula_parameter_model.dart';
import 'package:guardian_ai/modules/calculators/data/repositories/calculator_repository_impl.dart';
import 'package:guardian_ai/modules/calculators/domain/entities/calculation_result.dart';
import 'package:guardian_ai/modules/calculators/domain/entities/clinical_formula.dart';
import 'package:guardian_ai/modules/calculators/domain/repositories/calculator_repository.dart';

final calculatorRepositoryProvider = Provider<CalculatorRepository>((ref) {
  return CalculatorRepositoryImpl();
});

final calculatorProvider = StateNotifierProvider.family<CalculatorNotifier,
    CalculatorState, ClinicalFormulaType>(
  (ref, formulaType) {
    final repository = ref.watch(calculatorRepositoryProvider);
    return CalculatorNotifier(repository, formulaType);
  },
);

class CalculatorState {
  final ClinicalFormulaType formulaType;
  final List<FormulaParameterModel> parameters;
  final CalculationResult? result;
  final bool isLoading;
  final String? error;

  const CalculatorState({
    required this.formulaType,
    required this.parameters,
    this.result,
    this.isLoading = false,
    this.error,
  });

  CalculatorState copyWith({
    ClinicalFormulaType? formulaType,
    List<FormulaParameterModel>? parameters,
    CalculationResult? result,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return CalculatorState(
      formulaType: formulaType ?? this.formulaType,
      parameters: parameters ?? this.parameters,
      result: clearResult ? null : (result ?? this.result),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final CalculatorRepository _repository;

  CalculatorNotifier(this._repository, ClinicalFormulaType formulaType)
      : super(CalculatorState(
          formulaType: formulaType,
          parameters: _getDefaultParameters(formulaType),
        ));

  static List<FormulaParameterModel> _getDefaultParameters(
      ClinicalFormulaType type) {
    switch (type) {
      case ClinicalFormulaType.mgKgDose:
        return [
          const FormulaParameterModel(
            name: 'weight',
            label: 'Peso del paciente',
            unit: 'kg',
            min: 0.5,
            max: 300,
          ),
          const FormulaParameterModel(
            name: 'dosePerKg',
            label: 'Dosis por kg',
            unit: 'mg/kg',
            min: 0.01,
          ),
          const FormulaParameterModel(
            name: 'maxDose',
            label: 'Dosis máxima (opcional)',
            unit: 'mg',
            required: false,
            min: 0,
          ),
        ];
      case ClinicalFormulaType.pediatricDose:
        return [
          const FormulaParameterModel(
            name: 'weightKg',
            label: 'Peso del paciente',
            unit: 'kg',
            min: 0.5,
            max: 120,
          ),
          const FormulaParameterModel(
            name: 'adultDose',
            label: 'Dosis de adulto',
            unit: 'mg',
            min: 0.01,
          ),
          const FormulaParameterModel(
            name: 'maxPediatricDose',
            label: 'Dosis máxima pediátrica (opcional)',
            unit: 'mg',
            required: false,
            min: 0,
          ),
        ];
      case ClinicalFormulaType.mgToMl:
        return [
          const FormulaParameterModel(
            name: 'mg',
            label: 'Miligramos',
            unit: 'mg',
            min: 0.01,
          ),
          const FormulaParameterModel(
            name: 'concentrationMgPerMl',
            label: 'Concentración',
            unit: 'mg/mL',
            min: 0.01,
          ),
        ];
      case ClinicalFormulaType.dropsPerMin:
        return [
          const FormulaParameterModel(
            name: 'volumeMl',
            label: 'Volumen a infundir',
            unit: 'mL',
            min: 1,
            max: 5000,
          ),
          const FormulaParameterModel(
            name: 'timeMinutes',
            label: 'Tiempo total',
            unit: 'min',
            min: 1,
            max: 1440,
          ),
          const FormulaParameterModel(
            name: 'dropFactor',
            label: 'Factor de goteo',
            unit: 'gotas/mL',
            value: 20,
            min: 1,
            max: 60,
            required: false,
          ),
        ];
      case ClinicalFormulaType.microdropsPerMin:
        return [
          const FormulaParameterModel(
            name: 'volumeMl',
            label: 'Volumen a infundir',
            unit: 'mL',
            min: 1,
            max: 5000,
          ),
          const FormulaParameterModel(
            name: 'timeMinutes',
            label: 'Tiempo total',
            unit: 'min',
            min: 1,
            max: 1440,
          ),
        ];
      case ClinicalFormulaType.infusionMlPerH:
        return [
          const FormulaParameterModel(
            name: 'dose',
            label: 'Dosis deseada',
            unit: 'mcg/kg/min',
            min: 0.01,
          ),
          const FormulaParameterModel(
            name: 'weight',
            label: 'Peso del paciente',
            unit: 'kg',
            min: 0.5,
            max: 300,
          ),
          const FormulaParameterModel(
            name: 'concentration',
            label: 'Concentración del fármaco',
            unit: 'mcg/mL',
            min: 0.01,
          ),
          const FormulaParameterModel(
            name: 'maxRate',
            label: 'Velocidad máxima (opcional)',
            unit: 'mL/h',
            required: false,
            min: 0,
          ),
        ];
      case ClinicalFormulaType.fluidBalance:
        return [
          const FormulaParameterModel(
            name: 'totalInput',
            label: 'Total ingresos',
            unit: 'mL',
            min: 0,
            max: 20000,
          ),
          const FormulaParameterModel(
            name: 'totalOutput',
            label: 'Total egresos',
            unit: 'mL',
            min: 0,
            max: 20000,
          ),
        ];
      case ClinicalFormulaType.bodySurfaceArea:
        return [
          const FormulaParameterModel(
            name: 'heightCm',
            label: 'Altura',
            unit: 'cm',
            min: 10,
            max: 250,
          ),
          const FormulaParameterModel(
            name: 'weightKg',
            label: 'Peso',
            unit: 'kg',
            min: 0.5,
            max: 300,
          ),
        ];
      case ClinicalFormulaType.sedationScore:
        return [
          const FormulaParameterModel(
            name: 'ramsayScore',
            label: 'Puntaje Ramsay',
            unit: '1-6',
            value: 3,
            min: 1,
            max: 6,
          ),
        ];
      case ClinicalFormulaType.vasopressorDose:
        return [
          const FormulaParameterModel(
            name: 'vasopressorName',
            label: 'Vasopresor',
            unit: '',
            min: 0,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'weight',
            label: 'Peso del paciente',
            unit: 'kg',
            min: 0.5,
            max: 300,
          ),
          const FormulaParameterModel(
            name: 'doseMcgKgMin',
            label: 'Dosis',
            unit: 'mcg/kg/min',
            min: 0.001,
          ),
          const FormulaParameterModel(
            name: 'concentrationMcgPerMl',
            label: 'Concentración (opcional)',
            unit: 'mcg/mL',
            required: false,
            min: 0.01,
          ),
        ];
      case ClinicalFormulaType.maxDoseCheck:
        return [
          const FormulaParameterModel(
            name: 'medication',
            label: 'Medicamento',
            unit: '',
            required: false,
          ),
          const FormulaParameterModel(
            name: 'calculatedDose',
            label: 'Dosis calculada',
            unit: 'mg',
            min: 0.01,
          ),
          const FormulaParameterModel(
            name: 'doseType',
            label: 'Tipo de dosis',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'weightKg',
            label: 'Peso (opcional)',
            unit: 'kg',
            required: false,
            min: 0.5,
            max: 300,
          ),
        ];
      case ClinicalFormulaType.glasgowComa:
        return [
          const FormulaParameterModel(
            name: 'eyeOpening',
            label: 'Apertura ocular',
            unit: '1-4',
            value: 4,
            min: 1,
            max: 4,
          ),
          const FormulaParameterModel(
            name: 'verbalResponse',
            label: 'Respuesta verbal',
            unit: '1-5',
            value: 5,
            min: 1,
            max: 5,
          ),
          const FormulaParameterModel(
            name: 'motorResponse',
            label: 'Respuesta motora',
            unit: '1-6',
            value: 6,
            min: 1,
            max: 6,
          ),
        ];
      case ClinicalFormulaType.qtc:
        return [
          const FormulaParameterModel(
            name: 'qtIntervalMs',
            label: 'Intervalo QT',
            unit: 'ms',
            min: 100,
            max: 800,
          ),
          const FormulaParameterModel(
            name: 'heartRate',
            label: 'Frecuencia cardíaca',
            unit: 'lpm',
            min: 20,
            max: 300,
          ),
        ];
      case ClinicalFormulaType.anionGap:
        return [
          const FormulaParameterModel(
            name: 'sodium',
            label: 'Sodio (Na⁺)',
            unit: 'mEq/L',
            min: 100,
            max: 200,
          ),
          const FormulaParameterModel(
            name: 'chloride',
            label: 'Cloro (Cl⁻)',
            unit: 'mEq/L',
            min: 60,
            max: 140,
          ),
          const FormulaParameterModel(
            name: 'bicarbonate',
            label: 'Bicarbonato (HCO₃⁻)',
            unit: 'mEq/L',
            min: 5,
            max: 50,
          ),
        ];
      case ClinicalFormulaType.apacheScore:
        return [
          const FormulaParameterModel(
            name: 'age',
            label: 'Edad',
            unit: 'años',
            min: 16,
            max: 110,
          ),
          const FormulaParameterModel(
            name: 'heartRate',
            label: 'Frecuencia cardíaca',
            unit: 'lpm',
            min: 0,
            max: 300,
          ),
          const FormulaParameterModel(
            name: 'meanArterialPressure',
            label: 'Presión arterial media',
            unit: 'mmHg',
            min: 20,
            max: 250,
          ),
          const FormulaParameterModel(
            name: 'temperature',
            label: 'Temperatura',
            unit: '°C',
            min: 30,
            max: 45,
          ),
          const FormulaParameterModel(
            name: 'creatinine',
            label: 'Creatinina',
            unit: 'mg/dL',
            min: 0,
            max: 20,
          ),
          const FormulaParameterModel(
            name: 'hematocrit',
            label: 'Hematocrito',
            unit: '%',
            min: 10,
            max: 70,
          ),
          const FormulaParameterModel(
            name: 'wbc',
            label: 'Leucocitos (x10³/mm³)',
            unit: '',
            min: 0,
            max: 200,
          ),
          const FormulaParameterModel(
            name: 'glasgowComaScore',
            label: 'Glasgow (3-15)',
            unit: '',
            value: 15,
            min: 3,
            max: 15,
          ),
        ];
      case ClinicalFormulaType.meldScore:
        return [
          const FormulaParameterModel(
            name: 'bilirubin',
            label: 'Bilirrubina',
            unit: 'mg/dL',
            min: 0.1,
            max: 100,
          ),
          const FormulaParameterModel(
            name: 'inr',
            label: 'INR',
            unit: '',
            min: 0.1,
            max: 20,
          ),
          const FormulaParameterModel(
            name: 'creatinine',
            label: 'Creatinina',
            unit: 'mg/dL',
            min: 0.1,
            max: 20,
          ),
        ];
      case ClinicalFormulaType.chadsVasc:
        return [
          const FormulaParameterModel(
            name: 'age',
            label: 'Edad',
            unit: 'años',
            value: 65,
            min: 18,
            max: 130,
          ),
          const FormulaParameterModel(
            name: 'hasHeartFailure',
            label: 'Insuficiencia cardíaca',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasHypertension',
            label: 'Hipertensión',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasDiabetes',
            label: 'Diabetes',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasStroke',
            label: 'ACV/AIT/TE previo',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasVascularDisease',
            label: 'Enfermedad vascular',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'isFemale',
            label: 'Sexo femenino',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
        ];
      case ClinicalFormulaType.wellsCriteria:
        return [
          const FormulaParameterModel(
            name: 'hasClinicalSignsDvt',
            label: 'Signos clínicos de TVP',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasAlternativeDiagnosis',
            label: 'Diagnóstico alternativo más probable',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'heartRateOver100',
            label: 'FC > 100 lpm',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasImmobilizationOrSurgery',
            label: 'Inmovilización/cirugía < 4 sem',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasPreviousDvtOrPe',
            label: 'TVP/TEP previo',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasHemoptysis',
            label: 'Hemoptisis',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'hasMalignancy',
            label: 'Neoplasia activa',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
        ];
      case ClinicalFormulaType.curb65:
        return [
          const FormulaParameterModel(
            name: 'confusion',
            label: 'Confusión mental',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'bunOver7',
            label: 'BUN > 7 mmol/L',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'respiratoryRateOver30',
            label: 'FR ≥ 30 resp/min',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'lowBloodPressure',
            label: 'PAS < 90 o PAD ≤ 60 mmHg',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
          const FormulaParameterModel(
            name: 'ageOver65',
            label: 'Edad ≥ 65 años',
            unit: '',
            value: 0,
            min: 0,
            max: 1,
            required: false,
          ),
        ];
    }
  }

  void updateParameter(String name, double value) {
    final updated = <FormulaParameterModel>[];
    for (final param in state.parameters) {
      if (param.name == name) {
        updated.add(param.copyWith(value: value));
      } else {
        updated.add(param);
      }
    }
    state = state.copyWith(
        parameters: updated, clearResult: true, clearError: true);
  }

  void calculate() {
    final missingRequired = state.parameters.where(
      (p) => p.required && p.value == null,
    );

    if (missingRequired.isNotEmpty) {
      final names = missingRequired.map((p) => p.label).join(', ');
      state = state.copyWith(
        error: 'Complete los campos requeridos: $names',
        isLoading: false,
      );
      return;
    }

    state =
        state.copyWith(isLoading: true, clearError: true, clearResult: true);

    try {
      final params = <String, double>{};
      for (final param in state.parameters) {
        if (param.value != null) {
          params[param.name] = param.value!;
        }
      }

      final result = _repository.calculate(state.formulaType, params);
      state = state.copyWith(result: result, isLoading: false);
    } on Failure catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Error inesperado: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  void reset() {
    state = CalculatorState(
      formulaType: state.formulaType,
      parameters: _getDefaultParameters(state.formulaType),
    );
  }
}
