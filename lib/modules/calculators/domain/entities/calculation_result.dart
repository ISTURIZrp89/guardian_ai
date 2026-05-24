class CalculationResult {
  final double result;
  final String unit;
  final String label;
  final String? description;
  final bool isWarning;
  final bool isCritical;
  final Map<String, double>? details;

  const CalculationResult({
    required this.result,
    required this.unit,
    required this.label,
    this.description,
    this.isWarning = false,
    this.isCritical = false,
    this.details,
  });

  CalculationResult copyWith({
    double? result,
    String? unit,
    String? label,
    String? description,
    bool? isWarning,
    bool? isCritical,
    Map<String, double>? details,
  }) {
    return CalculationResult(
      result: result ?? this.result,
      unit: unit ?? this.unit,
      label: label ?? this.label,
      description: description ?? this.description,
      isWarning: isWarning ?? this.isWarning,
      isCritical: isCritical ?? this.isCritical,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'result': result,
      'unit': unit,
      'label': label,
      'description': description,
      'isWarning': isWarning,
      'isCritical': isCritical,
      'details': details,
    };
  }

  factory CalculationResult.fromMap(Map<String, dynamic> map) {
    return CalculationResult(
      result: (map['result'] as num).toDouble(),
      unit: map['unit'] as String,
      label: map['label'] as String,
      description: map['description'] as String?,
      isWarning: map['isWarning'] as bool? ?? false,
      isCritical: map['isCritical'] as bool? ?? false,
      details: (map['details'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }
}
