enum AiResponseCategory {
  pharmacologic,
  interaction,
  recommendation,
  clinicalSummary,
  vitalInterpretation,
  general;

  String get displayName {
    switch (this) {
      case AiResponseCategory.pharmacologic:
        return 'Farmacológico';
      case AiResponseCategory.interaction:
        return 'Interacción';
      case AiResponseCategory.recommendation:
        return 'Recomendación';
      case AiResponseCategory.clinicalSummary:
        return 'Resumen Clínico';
      case AiResponseCategory.vitalInterpretation:
        return 'Signos Vitales';
      case AiResponseCategory.general:
        return 'General';
    }
  }
}

class AiResponse {
  final String content;
  final double confidence;
  final int processingTimeMs;
  final int tokensUsed;
  final bool isComplete;
  final String? error;
  final AiResponseCategory category;

  const AiResponse({
    required this.content,
    this.confidence = 0.0,
    this.processingTimeMs = 0,
    this.tokensUsed = 0,
    this.isComplete = true,
    this.error,
    this.category = AiResponseCategory.general,
  });

  AiResponse copyWith({
    String? content,
    double? confidence,
    int? processingTimeMs,
    int? tokensUsed,
    bool? isComplete,
    String? error,
    AiResponseCategory? category,
    bool clearError = false,
  }) {
    return AiResponse(
      content: content ?? this.content,
      confidence: confidence ?? this.confidence,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      isComplete: isComplete ?? this.isComplete,
      error: clearError ? null : (error ?? this.error),
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'confidence': confidence,
      'processingTimeMs': processingTimeMs,
      'tokensUsed': tokensUsed,
      'isComplete': isComplete ? 1 : 0,
      'error': error,
      'category': category.name,
    };
  }

  factory AiResponse.fromMap(Map<String, dynamic> map) {
    return AiResponse(
      content: map['content'] as String,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      processingTimeMs: map['processingTimeMs'] as int? ?? 0,
      tokensUsed: map['tokensUsed'] as int? ?? 0,
      isComplete: (map['isComplete'] as int? ?? 1) == 1,
      error: map['error'] as String?,
      category: AiResponseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AiResponseCategory.general,
      ),
    );
  }
}
