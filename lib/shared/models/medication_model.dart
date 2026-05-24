import 'package:uuid/uuid.dart';

enum MedicationRoute {
  oral,
  iv,
  im,
  sc,
  topical,
  other;

  String get label {
    switch (this) {
      case MedicationRoute.oral:
        return 'Oral';
      case MedicationRoute.iv:
        return 'IV';
      case MedicationRoute.im:
        return 'IM';
      case MedicationRoute.sc:
        return 'SC';
      case MedicationRoute.topical:
        return 'Tópico';
      case MedicationRoute.other:
        return 'Otro';
    }
  }

  String toJson() => name;

  static MedicationRoute fromJson(String json) {
    return MedicationRoute.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MedicationRoute.other,
    );
  }
}

enum MedicationStatus {
  active,
  paused,
  completed,
  discontinued;

  String get label {
    switch (this) {
      case MedicationStatus.active:
        return 'Activo';
      case MedicationStatus.paused:
        return 'Pausado';
      case MedicationStatus.completed:
        return 'Completado';
      case MedicationStatus.discontinued:
        return 'Discontinuado';
    }
  }

  String toJson() => name;

  static MedicationStatus fromJson(String json) {
    return MedicationStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MedicationStatus.active,
    );
  }
}

class MedicationModel {
  final String id;
  final String patientId;
  final String name;
  final double dosage;
  final String unit;
  final MedicationRoute route;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String prescribedBy;
  final String? notes;
  final MedicationStatus status;

  MedicationModel({
    String? id,
    required this.patientId,
    required this.name,
    required this.dosage,
    this.unit = 'mg',
    this.route = MedicationRoute.oral,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.prescribedBy,
    this.notes,
    this.status = MedicationStatus.active,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'name': name,
        'dosage': dosage,
        'unit': unit,
        'route': route.toJson(),
        'frequency': frequency,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'prescribed_by': prescribedBy,
        'notes': notes,
        'status': status.toJson(),
      };

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as String?,
      patientId: json['patient_id'] as String,
      name: json['name'] as String,
      dosage: (json['dosage'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'mg',
      route: MedicationRoute.fromJson(json['route'] as String? ?? 'oral'),
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      prescribedBy: json['prescribed_by'] as String,
      notes: json['notes'] as String?,
      status:
          MedicationStatus.fromJson(json['status'] as String? ?? 'active'),
    );
  }

  MedicationModel copyWith({
    String? id,
    String? patientId,
    String? name,
    double? dosage,
    String? unit,
    MedicationRoute? route,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? notes,
    MedicationStatus? status,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      route: route ?? this.route,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
