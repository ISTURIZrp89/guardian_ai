class DrugReference {
  final String name;
  final String genericName;
  final double maxSingleDoseMg;
  final double maxDailyDoseMg;
  final String unit;
  final List<String> contraindications;
  final List<String> warnings;
  final String nursingConsiderations;

  const DrugReference({
    required this.name,
    required this.genericName,
    required this.maxSingleDoseMg,
    required this.maxDailyDoseMg,
    required this.unit,
    this.contraindications = const [],
    this.warnings = const [],
    this.nursingConsiderations = '',
  });
}

class DrugDatabase {
  static const List<DrugReference> drugs = [
    DrugReference(
      name: 'Paracetamol',
      genericName: 'Acetaminofén',
      maxSingleDoseMg: 1000,
      maxDailyDoseMg: 4000,
      unit: 'mg',
      contraindications: ['Insuficiencia hepática grave'],
      warnings: ['No exceder 4g/día', 'Riesgo de hepatotoxicidad'],
      nursingConsiderations:
          'Monitorizar función hepática en tratamientos prolongados',
    ),
    DrugReference(
      name: 'Ibuprofeno',
      genericName: 'Ibuprofeno',
      maxSingleDoseMg: 800,
      maxDailyDoseMg: 2400,
      unit: 'mg',
      contraindications: [
        'Insuficiencia renal grave',
        'Úlcera péptica activa',
      ],
      warnings: ['Riesgo cardiovascular', 'Interacción con anticoagulantes'],
      nursingConsiderations:
          'Administrar con alimentos para reducir irritación gástrica',
    ),
    DrugReference(
      name: 'Morfina',
      genericName: 'Morfina',
      maxSingleDoseMg: 10,
      maxDailyDoseMg: 30,
      unit: 'mg',
      contraindications: [
        'Depresión respiratoria',
        'Obstrucción intestinal',
      ],
      warnings: [
        'Riesgo de dependencia',
        'Monitorizar frecuencia respiratoria',
      ],
      nursingConsiderations:
          'Valorar escala de dolor antes y después de administración',
    ),
    DrugReference(
      name: 'Amoxicilina',
      genericName: 'Amoxicilina',
      maxSingleDoseMg: 1000,
      maxDailyDoseMg: 3000,
      unit: 'mg',
      contraindications: ['Alergia a penicilinas'],
      warnings: ['Reacciones alérgicas graves posibles'],
      nursingConsiderations: 'Preguntar por alergias antes de administrar',
    ),
    DrugReference(
      name: 'Heparina',
      genericName: 'Heparina sódica',
      maxSingleDoseMg: 5000,
      maxDailyDoseMg: 40000,
      unit: 'UI',
      contraindications: [
        'Hemorragia activa',
        'Trombocitopenia inducida por heparina',
      ],
      warnings: ['Riesgo de sangrado', 'Monitorizar tiempo de coagulación'],
      nursingConsiderations:
          'Administrar vía SC o IV, no IM. Rotar sitios de inyección',
    ),
    DrugReference(
      name: 'Dobutamina',
      genericName: 'Dobutamina',
      maxSingleDoseMg: 40,
      maxDailyDoseMg: 960,
      unit: 'mg',
      contraindications: [
        'Estenosis aórtica idiopática hipertrófica',
      ],
      warnings: ['Aumenta frecuencia cardíaca', 'Arritmias'],
      nursingConsiderations: 'Monitorizar ECG y presión arterial continuamente',
    ),
  ];

  static DrugReference? findDrug(String name) {
    final query = name.toLowerCase();
    try {
      return drugs.firstWhere(
        (d) =>
            d.name.toLowerCase() == query ||
            d.genericName.toLowerCase() == query,
      );
    } catch (_) {
      return null;
    }
  }

  static List<DrugReference> searchDrugs(String query) {
    final q = query.toLowerCase();
    return drugs
        .where(
          (d) =>
              d.name.toLowerCase().contains(q) ||
              d.genericName.toLowerCase().contains(q),
        )
        .toList();
  }
}
