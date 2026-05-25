class ClinicalContext {
  final int patientAge;
  final double patientWeight;
  final String patientGender;
  final Map<String, dynamic> vitalSigns;
  final List<Map<String, dynamic>> activeMedications;
  final List<String> diagnoses;
  final String recentNotes;
  final List<String> allergies;

  const ClinicalContext({
    this.patientAge = 0,
    this.patientWeight = 0.0,
    this.patientGender = 'No especificado',
    this.vitalSigns = const {},
    this.activeMedications = const [],
    this.diagnoses = const [],
    this.recentNotes = '',
    this.allergies = const [],
  });

  ClinicalContext copyWith({
    int? patientAge,
    double? patientWeight,
    String? patientGender,
    Map<String, dynamic>? vitalSigns,
    List<Map<String, dynamic>>? activeMedications,
    List<String>? diagnoses,
    String? recentNotes,
    List<String>? allergies,
  }) {
    return ClinicalContext(
      patientAge: patientAge ?? this.patientAge,
      patientWeight: patientWeight ?? this.patientWeight,
      patientGender: patientGender ?? this.patientGender,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      activeMedications: activeMedications ?? this.activeMedications,
      diagnoses: diagnoses ?? this.diagnoses,
      recentNotes: recentNotes ?? this.recentNotes,
      allergies: allergies ?? this.allergies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientAge': patientAge,
      'patientWeight': patientWeight,
      'patientGender': patientGender,
      'vitalSigns': vitalSigns,
      'activeMedications': activeMedications,
      'diagnoses': diagnoses,
      'recentNotes': recentNotes,
      'allergies': allergies,
    };
  }

  bool get hasPatientData =>
      patientAge > 0 ||
      patientWeight > 0 ||
      vitalSigns.isNotEmpty ||
      activeMedications.isNotEmpty ||
      diagnoses.isNotEmpty;

  String get summary {
    final parts = <String>[];
    if (patientAge > 0) {
      parts.add('Edad: $patientAge años');
    }
    if (patientWeight > 0) {
      parts.add('Peso: ${patientWeight}kg');
    }
    if (patientGender != 'No especificado') {
      parts.add('Sexo: $patientGender');
    }
    if (vitalSigns.isNotEmpty) {
      parts.add(
          'Signos vitales: ${vitalSigns.entries.map((e) => '${e.key}: ${e.value}').join(', ')}');
    }
    if (diagnoses.isNotEmpty) {
      parts.add('Dx: ${diagnoses.join(', ')}');
    }
    if (allergies.isNotEmpty) {
      parts.add('Alergias: ${allergies.join(', ')}');
    }
    return parts.join(' | ');
  }
}
