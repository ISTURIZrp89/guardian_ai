class NandaDiagnosis {
  final String code;
  final String label;
  final String definition;
  final List<String> relatedFactors;
  final List<String> definingCharacteristics;
  final List<String> nicInterventions;
  final List<String> nocOutcomes;

  const NandaDiagnosis({
    required this.code,
    required this.label,
    required this.definition,
    this.relatedFactors = const [],
    this.definingCharacteristics = const [],
    this.nicInterventions = const [],
    this.nocOutcomes = const [],
  });
}

class NandaDatabase {
  static const List<NandaDiagnosis> diagnoses = [
    NandaDiagnosis(
      code: '00001',
      label: 'Deterioro del intercambio gaseoso',
      definition:
          'Exceso o déficit en la oxigenación y/o eliminación de dióxido de carbono en la membrana alveolocapilar',
      relatedFactors: ['Alteración de la membrana alveolocapilar'],
      definingCharacteristics: [
        'Disnea',
        'SatO2 disminuida',
        'Gasometría alterada',
      ],
      nicInterventions: ['Oxigenoterapia', 'Monitorización respiratoria'],
      nocOutcomes: ['Estado respiratorio', 'Intercambio gaseoso'],
    ),
    NandaDiagnosis(
      code: '00002',
      label: 'Dolor agudo',
      definition:
          'Experiencia sensitiva y emocional desagradable asociada a daño tisular real o potencial',
      relatedFactors: ['Agentes lesivos biológicos, químicos, físicos'],
      definingCharacteristics: [
        'Expresión verbal de dolor',
        'Cambios en signos vitales',
        'Expresión facial de dolor',
      ],
      nicInterventions: ['Manejo del dolor', 'Administración de analgesia'],
      nocOutcomes: ['Control del dolor', 'Nivel de dolor'],
    ),
    NandaDiagnosis(
      code: '00003',
      label: 'Riesgo de infección',
      definition:
          'Vulnerabilidad a ser invadido por organismos patógenos',
      relatedFactors: [
        'Procedimientos invasivos',
        'Defensas primarias inadecuadas',
      ],
      definingCharacteristics: [],
      nicInterventions: [
        'Control de infecciones',
        'Cuidados del sitio de incisión',
      ],
      nocOutcomes: ['Control de riesgo', 'Estado infeccioso'],
    ),
    NandaDiagnosis(
      code: '00004',
      label: 'Deterioro de la integridad cutánea',
      definition:
          'Alteración de la epidermis y/o dermis',
      relatedFactors: [
        'Inmovilización física',
        'Humedad',
        'Presión mecánica',
      ],
      definingCharacteristics: [
        'Destrucción de capas cutáneas',
        'Invasión de estructuras corporales',
      ],
      nicInterventions: ['Cuidados de la piel', 'Manejo de presiones'],
      nocOutcomes: ['Integridad tisular', 'Curación de heridas'],
    ),
    NandaDiagnosis(
      code: '00005',
      label: 'Déficit de volumen de líquidos',
      definition:
          'Disminución del líquido intravascular, intersticial y/o intracelular',
      relatedFactors: ['Pérdida activa de líquidos', 'Ingesta insuficiente'],
      definingCharacteristics: [
        'Disminución de la presión arterial',
        'Aumento de la frecuencia cardíaca',
        'Piel seca',
        'Sed',
      ],
      nicInterventions: ['Manejo de líquidos', 'Monitorización de signos vitales'],
      nocOutcomes: ['Equilibrio hídrico', 'Estado de hidratación'],
    ),
    NandaDiagnosis(
      code: '00006',
      label: 'Patrón respiratorio ineficaz',
      definition:
          'Inspiración y/o espiración que no proporciona una ventilación adecuada',
      relatedFactors: [
        'Fatiga de los músculos respiratorios',
        'Dolor',
        'Ansiedad',
      ],
      definingCharacteristics: [
        'Disnea',
        'Taquipnea',
        'Uso de músculos accesorios',
        'Tos ineficaz',
      ],
      nicInterventions: [
        'Fisioterapia respiratoria',
        'Manejo de la vía aérea',
      ],
      nocOutcomes: ['Estado respiratorio', 'Ventilación'],
    ),
    NandaDiagnosis(
      code: '00007',
      label: 'Deterioro de la movilidad física',
      definition:
          'Limitación del movimiento independiente e intencionado del cuerpo o de una o más extremidades',
      relatedFactors: [
        'Deterioro musculoesquelético',
        'Dolor',
        'Deterioro neuromuscular',
      ],
      definingCharacteristics: [
        'Limitación de la amplitud de movimiento',
        'Enlentecimiento del movimiento',
      ],
      nicInterventions: ['Terapia de ejercicios', 'Manejo de la movilidad'],
      nocOutcomes: ['Movilidad', 'Función muscular'],
    ),
    NandaDiagnosis(
      code: '00008',
      label: 'Ansiedad',
      definition:
          'Sensación vaga e intranquila de malestar o amenaza acompañada de una respuesta autonómica',
      relatedFactors: [
        'Cambio en el estado de salud',
        'Amenaza de muerte',
        'Crisis situacional',
      ],
      definingCharacteristics: [
        'Inquietud',
        'Preocupación',
        'Tensión facial',
        'Aumento de la frecuencia cardíaca',
      ],
      nicInterventions: [
        'Disminución de la ansiedad',
        'Apoyo emocional',
      ],
      nocOutcomes: ['Autocontrol de la ansiedad', 'Bienestar'],
    ),
  ];

  static List<NandaDiagnosis> searchDiagnoses(String query) {
    final q = query.toLowerCase();
    return diagnoses
        .where(
          (d) =>
              d.label.toLowerCase().contains(q) ||
              d.code.contains(q) ||
              d.definition.toLowerCase().contains(q),
        )
        .toList();
  }

  static NandaDiagnosis? findByCode(String code) {
    try {
      return diagnoses.firstWhere((d) => d.code == code);
    } catch (_) {
      return null;
    }
  }
}
