import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_ai/core/constants/app_colors.dart';
import 'package:guardian_ai/core/constants/app_dimensions.dart';
import 'package:guardian_ai/core/extensions/context_extensions.dart';
import 'package:guardian_ai/modules/calculators/domain/entities/clinical_formula.dart';
import 'package:guardian_ai/modules/calculators/data/models/formula_parameter_model.dart';
import 'package:guardian_ai/modules/calculators/presentation/providers/calculator_provider.dart';
import 'package:guardian_ai/modules/calculators/presentation/widgets/result_card.dart';

class CalculatorDetailPage extends ConsumerWidget {
  final String type;

  const CalculatorDetailPage({super.key, required this.type});

  ClinicalFormulaType? get _formulaType {
    return ClinicalFormulaType.values.where((t) => t.name == type).firstOrNull;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formulaType = _formulaType;

    if (formulaType == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(title: const Text('Calculadora no encontrada')),
        body: const Center(
          child: Text(
            'Tipo de calculadora no válido',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final state = ref.watch(calculatorProvider(formulaType));
    final notifier = ref.read(calculatorProvider(formulaType).notifier);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(formulaType.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.reset,
            tooltip: 'Reiniciar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(formulaType),
            const SizedBox(height: AppDimensions.lg),
            _buildForm(context, state, notifier, formulaType),
            const SizedBox(height: AppDimensions.lg),
            if (state.isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.clinicalBlue,
                  strokeWidth: 3,
                ),
              ),
            if (state.error != null) _buildError(state.error!),
            if (state.result != null) ResultCard(result: state.result!),
            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ClinicalFormulaType type) {
    return Container(
      width: double.infinity,
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.clinicalBlue.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _iconFromString(type.iconData),
              color: AppColors.clinicalBlue,
              size: AppDimensions.iconSizeLarge,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppDimensions.fontSizeMd,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SFPro',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppDimensions.fontSizeXs,
                    fontFamily: 'IBMPlexSans',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.monitorGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.monitorGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SFPro',
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    CalculatorState state,
    CalculatorNotifier notifier,
    ClinicalFormulaType formulaType,
  ) {
    return Container(
      width: double.infinity,
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: AppColors.textDisabled.withAlpha(150), size: 18),
              const SizedBox(width: 8),
              const Text(
                'PARÁMETROS',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SFPro',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ...state.parameters.map((param) {
            return _buildParameterWidget(param, state, notifier, formulaType);
          }),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: notifier.calculate,
              icon: const Icon(Icons.calculate, size: 22),
              label: const Text('CALCULAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.clinicalBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.textDisabled.withAlpha(50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterWidget(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
    ClinicalFormulaType formulaType,
  ) {
    if (_isBooleanField(formulaType, param.name)) {
      return _buildToggleField(param, state, notifier);
    }
    if (_isDropdownField(formulaType, param.name)) {
      return _buildDropdownField(param, state, notifier, formulaType);
    }
    if (param.name == 'vasopressorName' || param.name == 'medication' || param.name == 'doseType') {
      return _buildSelectionField(param, state, notifier);
    }
    return _buildNumericField(param, state, notifier);
  }

  bool _isDropdownField(ClinicalFormulaType type, String paramName) {
    if (type == ClinicalFormulaType.glasgowComa) return true;
    if (type == ClinicalFormulaType.sedationScore && paramName == 'ramsayScore') return true;
    if (type == ClinicalFormulaType.apacheScore && paramName == 'glasgowComaScore') return true;
    return false;
  }

  bool _isBooleanField(ClinicalFormulaType type, String paramName) {
    if (type == ClinicalFormulaType.chadsVasc && paramName != 'age') return true;
    if (type == ClinicalFormulaType.wellsCriteria) return true;
    if (type == ClinicalFormulaType.curb65) return true;
    return false;
  }

  Widget _buildToggleField(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final isOn = (param.value ?? 0) == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isOn ? AppColors.monitorGreen.withAlpha(15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOn ? AppColors.monitorGreen.withAlpha(40) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Text(
                  param.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppDimensions.fontSizeSm,
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Switch(
              value: isOn,
              activeColor: AppColors.monitorGreen,
              onChanged: (value) {
                notifier.updateParameter(param.name, value ? 1.0 : 0.0);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
    ClinicalFormulaType formulaType,
  ) {
    if (formulaType == ClinicalFormulaType.glasgowComa) {
      return _buildGlasgowDropdown(param, state, notifier);
    }
    if (formulaType == ClinicalFormulaType.sedationScore) {
      return _buildRamsayDropdown(param, state, notifier);
    }
    if (formulaType == ClinicalFormulaType.apacheScore && param.name == 'glasgowComaScore') {
      return _buildGcsDropdown(param, state, notifier);
    }
    return _buildNumericField(param, state, notifier);
  }

  Widget _buildGlasgowDropdown(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    List<String> options;
    String label;
    double currentValue;

    switch (param.name) {
      case 'eyeOpening':
        label = 'Apertura ocular';
        options = ['No abre los ojos', 'Al dolor', 'Al llamado', 'Espontánea'];
        currentValue = param.value ?? 4;
        break;
      case 'verbalResponse':
        label = 'Respuesta verbal';
        options = ['No responde', 'Sonidos incomprensibles', 'Palabras inapropiadas', 'Confusa', 'Orientada'];
        currentValue = param.value ?? 5;
        break;
      case 'motorResponse':
        label = 'Respuesta motora';
        options = ['No responde', 'Extensión al dolor', 'Flexión al dolor', 'Retirada al dolor', 'Localiza el dolor', 'Obedece órdenes'];
        currentValue = param.value ?? 6;
        break;
      default:
        return _buildNumericField(param, state, notifier);
    }

    final intValue = currentValue.toInt().clamp(1, options.length);
    final scoreLabel = '${intValue}/${options.length}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppDimensions.fontSizeXs,
                  fontFamily: 'SFPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.clinicalBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  scoreLabel,
                  style: const TextStyle(
                    color: AppColors.clinicalBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SFPro',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          DropdownButtonFormField<int>(
            value: intValue,
            dropdownColor: AppColors.bgCard,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Seleccione...',
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'IBMPlexSans',
              fontSize: AppDimensions.fontSizeSm,
            ),
            items: List.generate(options.length, (i) {
              return DropdownMenuItem(
                value: i + 1,
                child: Text(
                  '${i + 1}: ${options[i]}',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                notifier.updateParameter(param.name, value.toDouble());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRamsayDropdown(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final options = [
      'Ansioso, agitado o inquieto',
      'Cooperador, orientado y tranquilo',
      'Dormido, responde a órdenes verbales',
      'Dormido, respuesta rápida a estímulo',
      'Dormido, respuesta lenta a estímulo',
      'Sin respuesta a estímulo doloroso',
    ];

    final currentValue = (param.value ?? 3).toInt().clamp(1, 6);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escala de Ramsay',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppDimensions.fontSizeXs,
              fontFamily: 'SFPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<int>(
            value: currentValue,
            dropdownColor: AppColors.bgCard,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'IBMPlexSans',
              fontSize: AppDimensions.fontSizeSm,
            ),
            items: List.generate(options.length, (i) {
              return DropdownMenuItem(
                value: i + 1,
                child: Text(
                  '${i + 1}: ${options[i]}',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                notifier.updateParameter(param.name, value.toDouble());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGcsDropdown(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final currentValue = (param.value ?? 15).toInt().clamp(3, 15);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Glasgow (APACHE)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppDimensions.fontSizeXs,
              fontFamily: 'SFPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<int>(
            value: currentValue,
            dropdownColor: AppColors.bgCard,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'IBMPlexSans',
              fontSize: AppDimensions.fontSizeSm,
            ),
            items: List.generate(13, (i) {
              final score = 15 - i;
              return DropdownMenuItem(
                value: score,
                child: Text(
                  '$score/15',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                notifier.updateParameter(param.name, value.toDouble());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumericField(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                param.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppDimensions.fontSizeXs,
                  fontFamily: 'SFPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (param.required)
                const Text(
                  ' *',
                  style: TextStyle(color: AppColors.alertRed, fontSize: 11),
                ),
              if (param.unit.isNotEmpty) ...[
                const Spacer(),
                Text(
                  param.unit,
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 10,
                    fontFamily: 'SFPro',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'IBMPlexSans',
              fontSize: AppDimensions.fontSizeSm,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Ingrese valor${param.unit.isNotEmpty ? ' (${param.unit})' : ''}',
              hintStyle: const TextStyle(color: AppColors.textDisabled),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value.replaceAll(',', '.'));
              if (parsed != null) {
                notifier.updateParameter(param.name, parsed);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionField(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    if (param.name == 'vasopressorName') {
      return _buildVasopressorSelector(param, state, notifier);
    }
    if (param.name == 'medication') {
      return _buildMedicationSelector(param, state, notifier);
    }
    if (param.name == 'doseType') {
      return _buildDoseTypeSelector(param, state, notifier);
    }
    return const SizedBox.shrink();
  }

  Widget _buildVasopressorSelector(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final vasopressors = [
      'noradrenalina',
      'dobutamina',
      'dopamina',
      'adrenalina',
      'vasopresina',
    ];

    final currentValue = state.parameters
        .firstWhere((p) => p.name == 'vasopressorName')
        .value
        ?.toInt()
        .clamp(0, vasopressors.length - 1) ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vasopresor',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppDimensions.fontSizeXs,
              fontFamily: 'SFPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<int>(
            value: currentValue,
            dropdownColor: AppColors.bgCard,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: List.generate(vasopressors.length, (i) {
              return DropdownMenuItem(
                value: i,
                child: Text(
                  vasopressors[i][0].toUpperCase() + vasopressors[i].substring(1),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                notifier.updateParameter('vasopressorName', value.toDouble());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSelector(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final medications = [
      'paracetamol', 'ibuprofeno', 'morfina', 'tramadol',
      'amoxicilina', 'omeprazol', 'enoxaparina', 'metformina',
      'furosemida', 'haloperidol',
    ];

    final currentValue = state.parameters
        .firstWhere((p) => p.name == 'medication')
        .value
        ?.toInt()
        .clamp(0, medications.length - 1) ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medicamento',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppDimensions.fontSizeXs,
              fontFamily: 'SFPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<int>(
            value: currentValue,
            dropdownColor: AppColors.bgCard,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: List.generate(medications.length, (i) {
              return DropdownMenuItem(
                value: i,
                child: Text(
                  medications[i][0].toUpperCase() + medications[i].substring(1),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                notifier.updateParameter('medication', value.toDouble());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDoseTypeSelector(
    FormulaParameterModel param,
    CalculatorState state,
    CalculatorNotifier notifier,
  ) {
    final currentValue = state.parameters
        .firstWhere((p) => p.name == 'doseType')
        .value
        ?.toInt()
        .clamp(0, 1) ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de dosis',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppDimensions.fontSizeXs,
              fontFamily: 'SFPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<int>(
            value: currentValue,
            dropdownColor: AppColors.bgCard,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('Dosis única', style: TextStyle(color: AppColors.textPrimary))),
              DropdownMenuItem(value: 1, child: Text('Dosis diaria', style: TextStyle(color: AppColors.textPrimary))),
            ],
            onChanged: (value) {
              if (value != null) {
                notifier.updateParameter('doseType', value.toDouble());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Container(
        width: double.infinity,
        padding: AppDimensions.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.alertRed.withAlpha(20),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          border: Border.all(color: AppColors.alertRed.withAlpha(60)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: AppColors.alertRed, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.alertRed,
                  fontSize: AppDimensions.fontSizeXs,
                  fontFamily: 'IBMPlexSans',
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFromString(String name) {
    switch (name) {
      case 'calculate':
        return Icons.calculate;
      case 'child_care':
        return Icons.child_care;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'water_drop':
        return Icons.water_drop;
      case 'grain':
        return Icons.grain;
      case 'speed':
        return Icons.speed;
      case 'balance':
        return Icons.balance;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'psychology':
        return Icons.psychology;
      case 'monitor_heart':
        return Icons.monitor_heart;
      case 'warning_amber':
        return Icons.warning_amber;
      case 'ecg':
        return Icons.monitor_heart;
      case 'science':
        return Icons.science;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'healing':
        return Icons.healing;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'checklist':
        return Icons.checklist;
      case 'pneumonia':
        return Icons.air;
      default:
        return Icons.calculate;
    }
  }
}
