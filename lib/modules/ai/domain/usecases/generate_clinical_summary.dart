import 'package:guardian_ai/core/errors/failures.dart';
import '../entities/ai_response.dart';
import '../entities/clinical_context.dart';
import '../repositories/ai_repository.dart';

enum SummaryFormat { soap, nanda }

class GenerateClinicalSummary {
  final AiRepository _repository;

  GenerateClinicalSummary(this._repository);

  Future<AiResponse> execute({
    required ClinicalContext context,
    SummaryFormat format = SummaryFormat.soap,
  }) async {
    try {
      if (!context.hasPatientData) {
        throw AiFailure(
          'Se requieren datos del paciente para generar el resumen clínico',
          code: 'INSUFFICIENT_PATIENT_DATA',
        );
      }

      final prompt = _buildSummaryPrompt(context, format);
      return await _repository.generateResponse(prompt, context: context);
    } on AiFailure {
      rethrow;
    } catch (e) {
      throw AiFailure(
        'Error al generar resumen clínico: $e',
        code: 'SUMMARY_ERROR',
      );
    }
  }

  String _buildSummaryPrompt(ClinicalContext context, SummaryFormat format) {
    final buffer = StringBuffer();

    buffer.writeln('[SISTEMA] Eres un enfermero clínico especializado en '
        'documentación clínica estructurada. Genera resúmenes clínicos '
        'precisos y organizados siguiendo formatos estandarizados.');

    buffer.writeln('');
    buffer.writeln('[DATOS DEL PACIENTE]');
    buffer.writeln(context.summary);

    if (context.recentNotes.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('[NOTAS RECIENTES]');
      buffer.writeln(context.recentNotes);
    }

    buffer.writeln('');
    switch (format) {
      case SummaryFormat.soap:
        buffer.writeln(
          'Genera un resumen clínico en formato SOAP:\n\n'
          '**S (Subjetivo):** Síntomas referidos por el paciente, '
          'historia de la enfermedad actual.\n'
          '**O (Objetivo):** Hallazgos objetivos, signos vitales, '
          'examen físico relevante, resultados de laboratorio.\n'
          '**A (Evaluación):** Diagnósticos diferenciales, impresión clínica, '
          'análisis de la situación.\n'
          '**P (Plan):** Plan de tratamiento, intervenciones, '
          'medicamentos, seguimiento.',
        );
      case SummaryFormat.nanda:
        buffer.writeln(
          'Genera un plan de cuidados en formato NANDA:\n\n'
          '**Diagnóstico NANDA:** Diagnóstico de enfermería principal.\n'
          '**NIC (Intervenciones):** Intervenciones de enfermería específicas.\n'
          '**NOC (Resultados):** Resultados esperados medibles.\n'
          '**Fundamento Científico:** Base teórica de las intervenciones.\n'
          '**Evaluación:** Criterios para evaluar la efectividad.',
        );
    }

    buffer.writeln('');
    buffer.writeln('NOTA: Este resumen es generado por IA y debe ser '
        'revisado por un profesional de la salud antes de su uso.');

    return buffer.toString();
  }
}
