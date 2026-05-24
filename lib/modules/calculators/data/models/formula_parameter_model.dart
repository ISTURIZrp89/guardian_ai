class FormulaParameterModel {
  final String name;
  final String label;
  final double? value;
  final String unit;
  final double? min;
  final double? max;
  final bool required;

  const FormulaParameterModel({
    required this.name,
    required this.label,
    this.value,
    this.unit = '',
    this.min,
    this.max,
    this.required = true,
  });

  FormulaParameterModel copyWith({
    String? name,
    String? label,
    double? value,
    String? unit,
    double? min,
    double? max,
    bool? required,
  }) {
    return FormulaParameterModel(
      name: name ?? this.name,
      label: label ?? this.label,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      min: min ?? this.min,
      max: max ?? this.max,
      required: required ?? this.required,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'label': label,
      'value': value,
      'unit': unit,
      'min': min,
      'max': max,
      'required': required,
    };
  }

  factory FormulaParameterModel.fromMap(Map<String, dynamic> map) {
    return FormulaParameterModel(
      name: map['name'] as String,
      label: map['label'] as String,
      value: (map['value'] as num?)?.toDouble(),
      unit: map['unit'] as String? ?? '',
      min: (map['min'] as num?)?.toDouble(),
      max: (map['max'] as num?)?.toDouble(),
      required: map['required'] as bool? ?? true,
    );
  }
}
