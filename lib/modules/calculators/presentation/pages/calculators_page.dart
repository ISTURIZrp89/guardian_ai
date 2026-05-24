import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_ai/core/constants/app_colors.dart';
import 'package:guardian_ai/core/constants/app_dimensions.dart';
import 'package:guardian_ai/core/extensions/context_extensions.dart';
import 'package:guardian_ai/modules/calculators/domain/entities/clinical_formula.dart';
import 'package:guardian_ai/modules/calculators/presentation/widgets/calculator_card.dart';

class CalculatorsPage extends StatefulWidget {
  const CalculatorsPage({super.key});

  @override
  State<CalculatorsPage> createState() => _CalculatorsPageState();
}

class _CalculatorsPageState extends State<CalculatorsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClinicalFormulaType> get _filteredFormulas {
    if (_searchQuery.isEmpty) return ClinicalFormulaType.values;

    final query = _searchQuery.toLowerCase();
    return ClinicalFormulaType.values.where((type) {
      return type.displayName.toLowerCase().contains(query) ||
          type.description.toLowerCase().contains(query) ||
          type.category.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<ClinicalFormulaType>> get _groupedFormulas {
    final grouped = <String, List<ClinicalFormulaType>>{};
    for (final type in _filteredFormulas) {
      grouped.putIfAbsent(type.category, () => []).add(type);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedFormulas;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Calculadoras Clínicas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Configuración',
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.showAppDialog(
              title: 'Calculadoras Guardian',
              content: const Text(
                'Herramientas de cálculo clínico para apoyo en la toma de decisiones. '
                'Los resultados son referenciales y no reemplazan el criterio médico.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'IBMPlexSans',
                  height: 1.5,
                ),
              ),
              confirmText: 'Entendido',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: grouped.isEmpty
                ? _buildEmptyState()
                : _buildFormulasList(grouped),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'IBMPlexSans',
            fontSize: 12,
          ),
          decoration: const InputDecoration(
            hintText: 'Buscar calculadora...',
            prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textDisabled),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textDisabled.withAlpha(100)),
          const SizedBox(height: AppDimensions.md),
          const Text(
            'Sin resultados',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppDimensions.fontSizeLg,
              fontFamily: 'SFPro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          const Text(
            'Intente con otros términos de búsqueda',
            style: TextStyle(
              color: AppColors.textDisabled,
              fontSize: AppDimensions.fontSizeSm,
              fontFamily: 'IBMPlexSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulasList(Map<String, List<ClinicalFormulaType>> grouped) {
    return ListView(
      padding: AppDimensions.screenPadding.copyWith(top: 0),
      children: grouped.entries.map((entry) {
        return _buildCategorySection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCategorySection(String category, List<ClinicalFormulaType> formulas) {
    final categoryIcons = {
      'Dosis': Icons.medication,
      'Infusión': Icons.phishing,
      'Pediátrico': Icons.child_care,
      'Balance Hídrico': Icons.water_drop,
      'Superficie Corporal': Icons.accessibility_new,
      'Sedación': Icons.psychology,
      'Vasopresor': Icons.monitor_heart,
      'Escalas Clínicas': Icons.assignment,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              children: [
                Icon(
                  categoryIcons[category] ?? Icons.category,
                  color: AppColors.clinicalBlue,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.clinicalBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SFPro',
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.95,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: formulas.length,
            itemBuilder: (context, index) {
              final type = formulas[index];
              return CalculatorCard(
                type: type,
                onTap: () => context.push('/calculators/${type.name}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
