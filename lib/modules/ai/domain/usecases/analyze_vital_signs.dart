import 'package:guardian_ai/core/errors/failures.dart';
import '../entities/ai_response.dart';
import '../entities/clinical_context.dart';
import '../repositories/ai_repository.dart';

class AnalyzeVitalSigns {
  final AiRepository _repository;

  AnalyzeVitalSigns(this._repository);

  Future<AiResponse> execute({
    required Map<String, dynamic> vitalSigns,
    ClinicalContext? context,
  }) async {
    try {
      if (vitalSigns.isEmpty) {
        throw AiFailure(
          'No se proporcionaron signos vitales para analizar',
          code: 'EMPTY_VITAL_SIGNS',
        );
      }

      final prompt = _buildVitalSignsPrompt(vitalSigns, context);
      return await _repository.generateResponse(prompt, context: context);
    } on AiFailure {
      rethrow;
    } catch (e) {
      throw AiFailure(
        'Error al analizar signos vitales: $e',
        code: 'VITAL_ANALYSIS_ERROR',
      );
    }
  }

  String _buildVitalSignsPrompt(
    Map<String, dynamic> vitalSigns,
    ClinicalContext? context,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('[SISTEMA] Eres un especialista en monitoreo de signos '
        'vitales para enfermería. Proporciona interpretaciones clínicas '
        'precisas de los signos vitales, identificando valores anormales '
        'y recomendando intervenciones apropiadas.');

    if (context != null && context.hasPatientData) {
      buffer.writeln('');
      buffer.writeln('[CONTEXTO DEL PACIENTE]');
      buffer.writeln(context.summary);
    }

    buffer.writeln('');
    buffer.writeln('[SIGNOS VITALES]');
    for (final entry in vitalSigns.entries) {
      buffer.writeln('- ${entry.key}: ${entry.value}');
    }

    buffer.writeln('');
    buffer.writeln(
      'Analiza los signos vitales siguiendo esta estructura:\n'
      '1. **Resumen general** de los signos vitales\n'
      '2. **Valores anormales** identificados y su significado clínico\n'
      '3. **Interpretación** basada en el contexto del paciente\n'
      '4. **Recomendaciones de enfermería** inmediatas\n'
      '5. **Seguimiento sugerido** y frecuencia de monitoreo\n'
      '6. **Indicadores de alarma** que requieren notificación médica',
    );

    return buffer.toString();
  }
}
