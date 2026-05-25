class PromptTemplates {
  PromptTemplates._();

  static const String _safetyGuardrail =
      '\n\n[SEGURIDAD] Esta información es solo '
      'para referencia clínica. No reemplaza el juicio profesional. '
      'En emergencias, active el código de emergencia correspondiente.\n';

  static String medicationAnalysis({
    required String medication,
    String? patientContext,
    String? allergies,
  }) {
    return '''
[SISTEMA] Eres un farmacólogo clínico especializado. Proporciona información precisa y actualizada.

[INSTRUCCIÓN] Analiza el siguiente medicamento: $medication

$patientContext

${allergies != null ? '[ALERTA DE ALERGIAS] $allergies' : ''}

Proporciona en orden:
1. Mecanismo de acción
2. Indicaciones y dosis habitual
3. Efectos adversos más comunes
4. Contraindicaciones absolutas y relativas
5. Interacciones medicamentosas significativas
6. Consideraciones de enfermería (administración, monitoreo)
7. Cuidados especiales en poblaciones específicas$_safetyGuardrail''';
  }

  static String clinicalSummary({
    required String patientData,
    required String recentNotes,
    required String format,
  }) {
    return '''
[SISTEMA] Eres un enfermero clínico especializado en documentación. Genera resúmenes estructurados.

[DATOS DEL PACIENTE]
$patientData

[NOTAS CLÍNICAS]
$recentNotes

[FORMATO REQUERIDO]
$format$_safetyGuardrail''';
  }

  static String vitalSignsInterpretation({
    required String vitalSignsData,
    String? patientContext,
  }) {
    return '''
[SISTEMA] Eres un especialista en monitoreo de signos vitales. Proporciona interpretación clínica precisa.

[SIGNOS VITALES]
$vitalSignsData

$patientContext

Analiza:
1. Resumen del estado hemodinámico
2. Valores fuera de rango y su significado
3. Posibles causas de alteraciones
4. Intervenciones de enfermería inmediatas
5. Parámetros a monitorear
6. Criterios para notificar al médico$_safetyGuardrail''';
  }

  static String nursingRecommendation({
    required String clinicalScenario,
    String? patientData,
  }) {
    return '''
[SISTEMA] Eres un enfermero especialista en planes de cuidado NANDA-NIC-NOC. Genera recomendaciones basadas en taxonomía estandarizada.

[ESCENARIO CLÍNICO]
$clinicalScenario

$patientData

Genera:
1. Diagnóstico NANDA principal (etiqueta diagnóstica + factores relacionados + características definitorias)
2. Resultados NOC esperados (con indicadores)
3. Intervenciones NIC prioritarias (con actividades específicas)
4. Fundamentos científicos de las intervenciones
5. Criterios de evaluación$_safetyGuardrail''';
  }

  static String pharmacologicInteraction({
    required String medications,
    String? patientData,
  }) {
    return '''
[SISTEMA] Eres un farmacólogo clínico especializado en interacciones medicamentosas. Analiza posibles interacciones.

[MEDICAMENTOS]
$medications

$patientData

Analiza:
1. Interacciones farmacocinéticas y farmacodinámicas
2. Severidad de cada interacción (leve/moderada/grave)
3. Mecanismo de cada interacción
4. Recomendaciones clínicas
5. Signos de alerta para monitoreo
6. Alternativas terapéuticas si están indicadas$_safetyGuardrail''';
  }

  static String generalClinicalAssistant() {
    return '''
[SISTEMA] Eres un asistente clínico de enfermería. Responde consultas con información precisa y basada en evidencia.

[DIRECTRICES]
- Proporciona información clara y útil
- Indica cuando no estés seguro
- Prioriza la seguridad del paciente
- Recomienda consultar con el médico cuando corresponda
- Usa vocabulario técnico apropiado pero comprensible
- Basa tus respuestas en guías clínicas y evidencia actualizada$_safetyGuardrail''';
  }
}
