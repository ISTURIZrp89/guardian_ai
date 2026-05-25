import 'package:guardian_ai/core/errors/failures.dart';
import '../entities/ai_response.dart';
import '../entities/clinical_context.dart';
import '../repositories/ai_repository.dart';

class AnalyzeMedication {
  final AiRepository _repository;

  AnalyzeMedication(this._repository);

  Future<AiResponse> execute({
    required String medicationName,
    ClinicalContext? context,
  }) async {
    try {
      if (medicationName.trim().isEmpty) {
        throw AiFailure(
          'Debe especificar un medicamento para analizar',
          code: 'EMPTY_MEDICATION',
        );
      }

      final prompt = _buildMedicationPrompt(medicationName, context);
      return await _repository.generateResponse(prompt, context: context);
    } on AiFailure {
      rethrow;
    } catch (e) {
      throw AiFailure(
        'Error al analizar medicamento: $e',
        code: 'MEDICATION_ANALYSIS_ERROR',
      );
    }
  }

  String _buildMedicationPrompt(String medication, ClinicalContext? context) {
    final buffer = StringBuffer();

    buffer.writeln(
        '[SISTEMA] Eres un farmacólogo clínico especializado en enfermería. '
        'Proporciona análisis detallados de medicamentos incluyendo: '
        'mecanismo de acción, indicaciones, dosis habitual, '
        'efectos adversos, contraindicaciones, interacciones, '
        'y consideraciones de enfermería. Usa lenguaje claro y preciso.');

    if (context != null && context.hasPatientData) {
      buffer.writeln('');
      buffer.writeln('[CONTEXTO DEL PACIENTE]');
      buffer.writeln(context.summary);
    }

    buffer.writeln('');
    buffer.writeln('[ANÁLISIS FARMACOLÓGICO]');
    buffer.writeln('Medicamento: $medication');

    if (context != null && context.allergies.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('[ALERTA DE ALERGIAS]');
      buffer.writeln(
        'El paciente tiene registradas las siguientes alergias: '
        '${context.allergies.join(", ")}. Verificar posible reactividad cruzada.',
      );
    }

    buffer.writeln('');
    buffer.writeln(
      'Proporciona el análisis en la siguiente estructura:\n'
      '1. **Mecanismo de acción**\n'
      '2. **Indicaciones principales**\n'
      '3. **Dosis habitual para adultos**\n'
      '4. **Efectos adversos frecuentes**\n'
      '5. **Contraindicaciones**\n'
      '6. **Interacciones medicamentosas relevantes**\n'
      '7. **Consideraciones de enfermería**\n'
      '8. **Monitoreo requerido**',
    );

    return buffer.toString();
  }
}
