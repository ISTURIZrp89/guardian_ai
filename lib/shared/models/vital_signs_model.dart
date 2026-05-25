import 'package:uuid/uuid.dart';

class VitalSignsModel {
  final String id;
  final String patientId;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final int heartRate;
  final int respiratoryRate;
  final double temperature;
  final int oxygenSaturation;
  final int painLevel;
  final DateTime recordedAt;
  final String? notes;

  VitalSignsModel({
    String? id,
    required this.patientId,
    this.bloodPressureSystolic = 120,
    this.bloodPressureDiastolic = 80,
    this.heartRate = 72,
    this.respiratoryRate = 16,
    this.temperature = 36.5,
    this.oxygenSaturation = 98,
    this.painLevel = 0,
    DateTime? recordedAt,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        recordedAt = recordedAt ?? DateTime.now();

  bool get isNormal {
    return bloodPressureSystolic >= 90 &&
        bloodPressureSystolic <= 120 &&
        bloodPressureDiastolic >= 60 &&
        bloodPressureDiastolic <= 80 &&
        heartRate >= 60 &&
        heartRate <= 100 &&
        respiratoryRate >= 12 &&
        respiratoryRate <= 20 &&
        temperature >= 36.0 &&
        temperature <= 37.5 &&
        oxygenSaturation >= 95 &&
        painLevel >= 0 &&
        painLevel <= 3;
  }

  bool get isBpNormal =>
      bloodPressureSystolic >= 90 &&
      bloodPressureSystolic <= 120 &&
      bloodPressureDiastolic >= 60 &&
      bloodPressureDiastolic <= 80;

  bool get isHrNormal => heartRate >= 60 && heartRate <= 100;

  bool get isRrNormal => respiratoryRate >= 12 && respiratoryRate <= 20;

  bool get isTempNormal => temperature >= 36.0 && temperature <= 37.5;

  bool get isSpO2Normal => oxygenSaturation >= 95;

  bool get isPainNormal => painLevel >= 0 && painLevel <= 3;

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'bp_systolic': bloodPressureSystolic,
        'bp_diastolic': bloodPressureDiastolic,
        'heart_rate': heartRate,
        'respiratory_rate': respiratoryRate,
        'temperature': temperature,
        'oxygen_saturation': oxygenSaturation,
        'pain_level': painLevel,
        'recorded_at': recordedAt.toIso8601String(),
        'notes': notes,
      };

  factory VitalSignsModel.fromJson(Map<String, dynamic> json) {
    return VitalSignsModel(
      id: json['id'] as String?,
      patientId: json['patient_id'] as String,
      bloodPressureSystolic: json['bp_systolic'] as int? ?? 120,
      bloodPressureDiastolic: json['bp_diastolic'] as int? ?? 80,
      heartRate: json['heart_rate'] as int? ?? 72,
      respiratoryRate: json['respiratory_rate'] as int? ?? 16,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 36.5,
      oxygenSaturation: json['oxygen_saturation'] as int? ?? 98,
      painLevel: json['pain_level'] as int? ?? 0,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  VitalSignsModel copyWith({
    String? id,
    String? patientId,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRate,
    int? respiratoryRate,
    double? temperature,
    int? oxygenSaturation,
    int? painLevel,
    DateTime? recordedAt,
    String? notes,
  }) {
    return VitalSignsModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      heartRate: heartRate ?? this.heartRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      temperature: temperature ?? this.temperature,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      painLevel: painLevel ?? this.painLevel,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VitalSignsModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
