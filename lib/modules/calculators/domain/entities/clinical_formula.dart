enum ClinicalFormulaType {
  mgKgDose,
  pediatricDose,
  mgToMl,
  dropsPerMin,
  microdropsPerMin,
  infusionMlPerH,
  fluidBalance,
  bodySurfaceArea,
  sedationScore,
  vasopressorDose,
  maxDoseCheck,
  glasgowComa,
  qtc,
  anionGap,
  apacheScore,
  meldScore,
  chadsVasc,
  wellsCriteria,
  curb65,
}

extension ClinicalFormulaTypeExtension on ClinicalFormulaType {
  String get displayName {
    switch (this) {
      case ClinicalFormulaType.mgKgDose:
        return 'Dosis mg/kg';
      case ClinicalFormulaType.pediatricDose:
        return 'Dosis Pediátrica';
      case ClinicalFormulaType.mgToMl:
        return 'Conversión mg a mL';
      case ClinicalFormulaType.dropsPerMin:
        return 'Gotas por Minuto';
      case ClinicalFormulaType.microdropsPerMin:
        return 'Microgotas por Minuto';
      case ClinicalFormulaType.infusionMlPerH:
        return 'Infusión mL/h';
      case ClinicalFormulaType.fluidBalance:
        return 'Balance Hídrico';
      case ClinicalFormulaType.bodySurfaceArea:
        return 'Superficie Corporal';
      case ClinicalFormulaType.sedationScore:
        return 'Escala de Sedación';
      case ClinicalFormulaType.vasopressorDose:
        return 'Dosis de Vasopresor';
      case ClinicalFormulaType.maxDoseCheck:
        return 'Verificación Dosis Máxima';
      case ClinicalFormulaType.glasgowComa:
        return 'Escala de Glasgow';
      case ClinicalFormulaType.qtc:
        return 'QT Corregido (Bazett)';
      case ClinicalFormulaType.anionGap:
        return 'Anión GAP';
      case ClinicalFormulaType.apacheScore:
        return 'APACHE II (simplificado)';
      case ClinicalFormulaType.meldScore:
        return 'MELD Score';
      case ClinicalFormulaType.chadsVasc:
        return 'CHA₂DS₂-VASc';
      case ClinicalFormulaType.wellsCriteria:
        return 'Criterios de Wells';
      case ClinicalFormulaType.curb65:
        return 'CURB-65';
    }
  }

  String get description {
    switch (this) {
      case ClinicalFormulaType.mgKgDose:
        return 'Calcula dosis basada en peso corporal';
      case ClinicalFormulaType.pediatricDose:
        return 'Dosis pediátrica ajustada por peso (Regla de Clark)';
      case ClinicalFormulaType.mgToMl:
        return 'Convierte miligramos a mililitros según concentración';
      case ClinicalFormulaType.dropsPerMin:
        return 'Calcula velocidad de goteo en gotas/minuto';
      case ClinicalFormulaType.microdropsPerMin:
        return 'Calcula velocidad en microgotas/minuto';
      case ClinicalFormulaType.infusionMlPerH:
        return 'Calcula velocidad de infusión en mL/hora';
      case ClinicalFormulaType.fluidBalance:
        return 'Calcula balance entre ingresos y egresos';
      case ClinicalFormulaType.bodySurfaceArea:
        return 'Calcula superficie corporal (Mosteller)';
      case ClinicalFormulaType.sedationScore:
        return 'Evalúa nivel de sedación (Ramsay)';
      case ClinicalFormulaType.vasopressorDose:
        return 'Calcula dosis de vasopresores en mcg/kg/min';
      case ClinicalFormulaType.maxDoseCheck:
        return 'Verifica si la dosis supera el máximo seguro';
      case ClinicalFormulaType.glasgowComa:
        return 'Evalúa nivel de conciencia (3-15)';
      case ClinicalFormulaType.qtc:
        return 'Intervalo QT corregido por frecuencia cardíaca';
      case ClinicalFormulaType.anionGap:
        return 'Brecha aniónica para diagnóstico metabólico';
      case ClinicalFormulaType.apacheScore:
        return 'Gravedad en UCI (simplificado)';
      case ClinicalFormulaType.meldScore:
        return 'Riesgo de mortalidad en hepatopatía';
      case ClinicalFormulaType.chadsVasc:
        return 'Riesgo de ACV en fibrilación auricular';
      case ClinicalFormulaType.wellsCriteria:
        return 'Probabilidad de TEP/TVP';
      case ClinicalFormulaType.curb65:
        return 'Gravedad de neumonía adquirida';
    }
  }

  String get iconData {
    switch (this) {
      case ClinicalFormulaType.mgKgDose:
        return 'calculate';
      case ClinicalFormulaType.pediatricDose:
        return 'child_care';
      case ClinicalFormulaType.mgToMl:
        return 'swap_horiz';
      case ClinicalFormulaType.dropsPerMin:
        return 'water_drop';
      case ClinicalFormulaType.microdropsPerMin:
        return 'grain';
      case ClinicalFormulaType.infusionMlPerH:
        return 'speed';
      case ClinicalFormulaType.fluidBalance:
        return 'balance';
      case ClinicalFormulaType.bodySurfaceArea:
        return 'accessibility_new';
      case ClinicalFormulaType.sedationScore:
        return 'psychology';
      case ClinicalFormulaType.vasopressorDose:
        return 'monitor_heart';
      case ClinicalFormulaType.maxDoseCheck:
        return 'warning_amber';
      case ClinicalFormulaType.glasgowComa:
        return 'psychology';
      case ClinicalFormulaType.qtc:
        return 'ecg';
      case ClinicalFormulaType.anionGap:
        return 'science';
      case ClinicalFormulaType.apacheScore:
        return 'local_hospital';
      case ClinicalFormulaType.meldScore:
        return 'healing';
      case ClinicalFormulaType.chadsVasc:
        return 'favorite_border';
      case ClinicalFormulaType.wellsCriteria:
        return 'checklist';
      case ClinicalFormulaType.curb65:
        return 'pneumonia';
    }
  }

  String get category {
    switch (this) {
      case ClinicalFormulaType.mgKgDose:
      case ClinicalFormulaType.mgToMl:
      case ClinicalFormulaType.maxDoseCheck:
        return 'Dosis';
      case ClinicalFormulaType.infusionMlPerH:
      case ClinicalFormulaType.dropsPerMin:
      case ClinicalFormulaType.microdropsPerMin:
        return 'Infusión';
      case ClinicalFormulaType.pediatricDose:
        return 'Pediátrico';
      case ClinicalFormulaType.fluidBalance:
        return 'Balance Hídrico';
      case ClinicalFormulaType.bodySurfaceArea:
        return 'Superficie Corporal';
      case ClinicalFormulaType.sedationScore:
        return 'Sedación';
      case ClinicalFormulaType.vasopressorDose:
        return 'Vasopresor';
      case ClinicalFormulaType.glasgowComa:
      case ClinicalFormulaType.qtc:
      case ClinicalFormulaType.anionGap:
      case ClinicalFormulaType.apacheScore:
      case ClinicalFormulaType.meldScore:
      case ClinicalFormulaType.chadsVasc:
      case ClinicalFormulaType.wellsCriteria:
      case ClinicalFormulaType.curb65:
        return 'Escalas Clínicas';
    }
  }

  bool get hasIntInputs {
    switch (this) {
      case ClinicalFormulaType.glasgowComa:
      case ClinicalFormulaType.chadsVasc:
      case ClinicalFormulaType.wellsCriteria:
      case ClinicalFormulaType.curb65:
        return true;
      default:
        return false;
    }
  }
}
