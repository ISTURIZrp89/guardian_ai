import 'package:guardian_ai/core/errors/failures.dart';
import '../entities/ai_response.dart';
import '../entities/clinical_context.dart';
import '../repositories/ai_repository.dart';

class GenerateClinicalResponse {
  final AiRepository _repository;

  GenerateClinicalResponse(this._repository);

  Future<AiResponse> execute({
    required String message,
    ClinicalContext? context,
    String systemPrompt = '',
  }) async {
    try {
      final prompt = _buildPrompt(message, context, systemPrompt);
      return await _repository.generateResponse(prompt, context: context);
    } on AiFailure {
      rethrow;
    } catch (e) {
      throw AiFailure('Error al generar respuesta: $e',
          code: 'GENERATION_ERROR');
    }
  }

  String _buildPrompt(
      String message, ClinicalContext? context, String systemPrompt) {
    final buffer = StringBuffer();

    buffer.writeln('[SISTEMA] Eres un asistente clínico de enfermería. '
        'Debes proporcionar información precisa y basada en evidencia. '
        'Si no estás seguro de algo, indícalo claramente. '
        'Nunca reemplaces el juicio clínico de un profesional de la salud. '
        'En caso de emergencia, indica al usuario que contacte al médico tratante.');

    if (context != null && context.hasPatientData) {
      buffer.writeln('');
      buffer.writeln('[CONTEXTO DEL PACIENTE]');
      buffer.writeln(context.summary);
    }

    if (systemPrompt.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('[INSTRUCCIÓN ESPECÍFICA]');
      buffer.writeln(systemPrompt);
    }

    buffer.writeln('');
    buffer.writeln('[CONSULTA]');
    buffer.writeln(message);

    buffer.writeln('');
    buffer.writeln('[RESPUESTA]');

    return buffer.toString();
  }
}
