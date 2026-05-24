import 'package:uuid/uuid.dart';

enum NoteCategory {
  assessment,
  medication,
  observation,
  procedure,
  other;

  String get label {
    switch (this) {
      case NoteCategory.assessment:
        return 'Evaluación';
      case NoteCategory.medication:
        return 'Medicación';
      case NoteCategory.observation:
        return 'Observación';
      case NoteCategory.procedure:
        return 'Procedimiento';
      case NoteCategory.other:
        return 'Otro';
    }
  }

  String toJson() => name;

  static NoteCategory fromJson(String json) {
    return NoteCategory.values.firstWhere(
      (e) => e.name == json,
      orElse: () => NoteCategory.other,
    );
  }
}

class ClinicalNotesModel {
  final String id;
  final String patientId;
  final String content;
  final NoteCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClinicalNotesModel({
    String? id,
    required this.patientId,
    required this.content,
    this.category = NoteCategory.observation,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'content': content,
        'category': category.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ClinicalNotesModel.fromJson(Map<String, dynamic> json) {
    return ClinicalNotesModel(
      id: json['id'] as String?,
      patientId: json['patient_id'] as String,
      content: json['content'] as String,
      category: NoteCategory.fromJson(json['category'] as String? ?? 'other'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  ClinicalNotesModel copyWith({
    String? id,
    String? patientId,
    String? content,
    NoteCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClinicalNotesModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicalNotesModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
