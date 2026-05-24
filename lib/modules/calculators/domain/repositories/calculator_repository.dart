import '../entities/calculation_result.dart';
import '../entities/clinical_formula.dart';

abstract class CalculatorRepository {
  CalculationResult calculate(ClinicalFormulaType type, Map<String, double> params);
}
