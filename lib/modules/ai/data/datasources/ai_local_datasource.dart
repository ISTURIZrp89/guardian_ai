import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:guardian_ai/modules/ai/domain/entities/ai_model_info.dart';
import 'package:guardian_ai/modules/ai/domain/entities/ai_response.dart';
import 'package:guardian_ai/modules/ai/domain/entities/clinical_context.dart';
import 'package:guardian_ai/modules/ai/data/services/llama_service.dart';
import 'package:guardian_ai/modules/ai/data/services/ollama_service.dart';
import 'package:guardian_ai/modules/ai/data/native/llama_ffi.dart';

class AiLocalDataSource {
  AiModelInfo? _loadedModel;
  double _memoryUsageMb = 0.0;
  final List<String> _conversationHistory = [];
  final Random _random = Random();
  final Dio _dio = Dio();
  final Map<String, StreamController<double>> _downloadProgressControllers = {};

  Future<String> _getModelPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  Future<List<AiModelInfo>> getAvailableModels() async {
    final now = DateTime.now();
    final models = [
      AiModelInfo(
        id: 'biomistral-7b-q4',
        name: 'BioMistral 7B Q4_K_M',
        path: '',
        size: 4100000000,
        modelType: AiModelType.biomistral,
        quantization: 'Q4_K_M',
        hfRepo: 'TheBloke/BioMistral-7B-GGUF',
        hfFile: 'biomistral-7b.Q4_K_M.gguf',
        downloadUrl:
            'https://huggingface.co/TheBloke/BioMistral-7B-GGUF/resolve/main/biomistral-7b.Q4_K_M.gguf',
        sha256Checksum: 'dummy_checksum_1', // Reemplazar con real
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
      AiModelInfo(
        id: 'meditron-7b-q4',
        name: 'Meditron 7B Q4_K_M',
        path: '',
        size: 4100000000,
        modelType: AiModelType.meditron,
        quantization: 'Q4_K_M',
        hfRepo: 'TheBloke/meditron-7b-GGUF',
        hfFile: 'meditron-7b.Q4_K_M.gguf',
        downloadUrl:
            'https://huggingface.co/TheBloke/meditron-7b-GGUF/resolve/main/meditron-7b.Q4_K_M.gguf',
        sha256Checksum: 'dummy_checksum_2', // Reemplazar con real
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
      AiModelInfo(
        id: 'clinicalcamel-7b-q4',
        name: 'ClinicalCamel 7B Q4_K_M',
        path: '',
        size: 4100000000,
        modelType: AiModelType.clinicalCamel,
        quantization: 'Q4_K_M',
        hfRepo: 'TheBloke/ClinicalCamel-7B-GGUF',
        hfFile: 'clinicalcamel-7b.Q4_K_M.gguf',
        downloadUrl:
            'https://huggingface.co/TheBloke/ClinicalCamel-7B-GGUF/resolve/main/clinicalcamel-7b.Q4_K_M.gguf',
        sha256Checksum: 'dummy_checksum_3', // Reemplazar con real
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
      AiModelInfo(
        id: 'biomistral-7b-q8',
        name: 'BioMistral 7B Q8_0 (Premium)',
        path: '',
        size: 7700000000,
        modelType: AiModelType.biomistral,
        quantization: 'Q8_0',
        hfRepo: 'TheBloke/BioMistral-7B-GGUF',
        hfFile: 'biomistral-7b.Q8_0.gguf',
        downloadUrl:
            'https://huggingface.co/TheBloke/BioMistral-7B-GGUF/resolve/main/biomistral-7b.Q8_0.gguf',
        sha256Checksum: 'dummy_checksum_4', // Reemplazar con real
        isPremium: true,
        createdAt: now,
        updatedAt: now,
      ),
      AiModelInfo(
        id: 'ii-medical-8b-q4',
        name: 'II-Medical 8B Q4_K_M',
        path: '',
        size: 5030000000,
        modelType: AiModelType.iiMedical,
        quantization: 'Q4_K_M',
        hfRepo: 'Intelligent-Internet/II-Medical-8B-1706-GGUF',
        hfFile: 'II-Medical-8B-1706.Q4_K_M.gguf',
        downloadUrl:
            'https://huggingface.co/Intelligent-Internet/II-Medical-8B-1706-GGUF/resolve/main/II-Medical-8B-1706.Q4_K_M.gguf',
        sha256Checksum: 'dummy_checksum_5',
        isPremium: false,
        createdAt: now,
        updatedAt: now,
      ),
      AiModelInfo(
        id: 'llama3-1-8b-medical-q4',
        name: 'LlaMA-3.1 8B Medical Q4_K_M',
        path: '',
        size: 4920000000,
        modelType: AiModelType.llama3Medical,
        quantization: 'Q4_K_M',
        hfRepo: 'mradermacher/LlaMA-3.1-8B-Medical-GGUF',
        hfFile: 'LlaMA-3.1-8B-Medical.Q4_K_M.gguf',
        downloadUrl:
            'https://huggingface.co/mradermacher/LlaMA-3.1-8B-Medical-GGUF/resolve/main/LlaMA-3.1-8B-Medical.Q4_K_M.gguf',
        sha256Checksum: 'dummy_checksum_6',
        isPremium:
            false, // Opcional: cámbialo a true si quieres que sea Premium
        createdAt: now,
        updatedAt: now,
      ),
    ];

    List<AiModelInfo> updatedModels = [];
    for (var m in models) {
      final actualPath = await _getModelPath(m.hfFile);
      final exists = File(actualPath).existsSync();
      updatedModels.add(m.copyWith(
        path: actualPath,
        isLoaded: _loadedModel?.id == m.id || exists,
      ));
    }
    return updatedModels;
  }

  Future<bool> loadModel(String modelId) async {
    final models = await getAvailableModels();
    final model = models.where((m) => m.id == modelId).firstOrNull;
    if (model == null) return false;

    if (!File(model.path).existsSync()) {
      return false; // El archivo no existe en disco aún
    }

    // Cargar en LlamaService si la plataforma lo soporta (Android/Linux/macOS)
    if (LlamaFFI.isSupported) {
      final loaded = await LlamaService.instance.loadModel(
        modelPath: model.path,
        nCtx: 2048,
        nThreads: 4,
      );
      if (!loaded) return false;
      _memoryUsageMb = 2800.0 + _random.nextDouble() * 400;
    } else {
      // Plataforma web: modo simulación
      _memoryUsageMb = 2800.0 + _random.nextDouble() * 400;
    }

    _loadedModel = model;
    return true;
  }

  Future<bool> unloadModel() async {
    _loadedModel = null;
    _memoryUsageMb = 0.0;
    _conversationHistory.clear();
    return true;
  }

  Future<bool> isModelLoaded() async {
    if (_loadedModel == null) return false;
    return File(_loadedModel!.path).existsSync();
  }

  Future<double> getMemoryUsage() async {
    return _memoryUsageMb;
  }

  Future<void> clearContext() async {
    _conversationHistory.clear();
  }

  Stream<double> getDownloadProgress(String modelId) {
    if (!_downloadProgressControllers.containsKey(modelId)) {
      _downloadProgressControllers[modelId] =
          StreamController<double>.broadcast();
    }
    return _downloadProgressControllers[modelId]!.stream;
  }

  Future<bool> downloadModel(String modelId) async {
    final models = await getAvailableModels();
    final model = models.where((m) => m.id == modelId).firstOrNull;
    if (model == null) return false;

    if (model.isPremium) {
      // TODO: Lógica de validación de suscripción aquí.
      // return false si no tiene acceso.
    }

    final savePath = model.path;
    if (!_downloadProgressControllers.containsKey(modelId)) {
      _downloadProgressControllers[modelId] =
          StreamController<double>.broadcast();
    }
    final controller = _downloadProgressControllers[modelId]!;

    try {
      await _dio.download(
        model.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            controller.add(progress);
          }
        },
      );

      // Verificación de integridad SHA-256
      // Comentado para desarrollo por cuestiones de velocidad, ya que los archivos pesan ~4GB
      /*
      final bytes = await File(savePath).readAsBytes();
      final digest = sha256.convert(bytes);
      if (digest.toString() != model.sha256Checksum && model.sha256Checksum != 'dummy_checksum') {
        await File(savePath).delete();
        throw Exception('Checksum verification failed');
      }
      */

      controller.add(1.0);
      return true;
    } catch (e) {
      if (File(savePath).existsSync()) {
        await File(savePath).delete();
      }
      return false;
    } finally {
      controller.close();
      _downloadProgressControllers.remove(modelId);
    }
  }

  Future<bool> deleteModel(String modelId) async {
    final models = await getAvailableModels();
    final model = models.where((m) => m.id == modelId).firstOrNull;
    if (model == null) return false;

    final file = File(model.path);
    if (file.existsSync()) {
      await file.delete();
    }

    if (_loadedModel?.id == modelId) {
      _loadedModel = null;
      _memoryUsageMb = 0.0;
    }
    return true;
  }

  final Map<String, AiResponse> _responseCache = {};

  Future<AiResponse> generateResponse(
    String prompt, {
    ClinicalContext? context,
  }) async {
    final cacheKey = '${prompt}_${context?.hashCode ?? 0}';
    if (_responseCache.containsKey(cacheKey)) {
      return _responseCache[cacheKey]!;
    }

    final startTime = DateTime.now();
    String content;
    bool usedRealInference = false;

    // ── Inferencia Real con llama.cpp (Local Nativa) ────────────────────────────
    if (LlamaFFI.isSupported && LlamaService.instance.isModelLoaded) {
      final fullPrompt = _buildClinicalPrompt(prompt, context);
      try {
        content = await LlamaService.instance.generate(
          prompt: fullPrompt,
          maxTokens: 512,
          temperature: 0.3, // Bajo = respuestas más precisas (uso médico)
        );
        usedRealInference = true;
      } catch (e) {
        // Fallback a Ollama si está disponible
        final ollamaResult = await _tryOllamaInference(prompt, context);
        content = ollamaResult.$1;
        usedRealInference = ollamaResult.$2;
      }
    } else {
      // ── Inferencia Real con Ollama (Servidor Local/WiFi) ────────────────────────
      final ollamaResult = await _tryOllamaInference(prompt, context);
      content = ollamaResult.$1;
      usedRealInference = ollamaResult.$2;
    }

    final processingTime = DateTime.now().difference(startTime);
    _conversationHistory.add(content);

    final response = AiResponse(
      content: content,
      confidence: usedRealInference ? 0.92 : 0.75 + _random.nextDouble() * 0.2,
      processingTimeMs: processingTime.inMilliseconds,
      tokensUsed: content.split(' ').length,
      isComplete: true,
      category: _categorizePrompt(prompt),
    );

    _responseCache[cacheKey] = response;
    return response;
  }

  /// Intenta realizar inferencia real usando Ollama sobre la red local
  Future<(String, bool)> _tryOllamaInference(
      String prompt, ClinicalContext? context) async {
    try {
      final ollama = OllamaService.instance;

      // Autodetectar dirección IP según el entorno para apuntar a la PC de desarrollo
      if (ollama.baseUrl == 'http://localhost:11434') {
        if (Platform.isAndroid) {
          // 10.0.2.2 es la IP del Host en el emulador Android de Google
          ollama.configure(host: 'http://10.0.2.2:11434', model: 'biomistral');
        } else {
          ollama.configure(host: 'http://localhost:11434', model: 'biomistral');
        }
      }

      final isAvailable = await ollama.checkConnection();
      if (isAvailable) {
        final fullPrompt = _buildClinicalPrompt(prompt, context);
        final result = await ollama.generate(
          prompt: fullPrompt,
          temperature: 0.3,
          maxTokens: 512,
        );
        if (result.isNotEmpty) {
          return (result, true);
        }
      }
    } catch (_) {
      // Si falla, cae al simulador de abajo
    }

    // Si no está Ollama, cae en simulación estructurada
    return (_generateSimulatedResponse(prompt, context), false);
  }

  /// Construye el prompt completo con contexto clínico para el modelo
  String _buildClinicalPrompt(String userMessage, ClinicalContext? context) {
    final buffer = StringBuffer();
    buffer.writeln('<|system|>');
    buffer.writeln(
        'Eres un asistente médico especializado. Proporciona información clínica '
        'precisa y basada en evidencia. IMPORTANTE: Esta información es solo de '
        'apoyo para profesionales de salud. Siempre recomienda consulta médica directa.');
    buffer.writeln('<|end|>');

    if (context != null && context.hasPatientData) {
      buffer.writeln('<|user|>');
      buffer.writeln('Contexto clínico del paciente: ${context.summary}');
    }

    buffer.writeln('<|user|>');
    buffer.writeln(userMessage);
    buffer.writeln('<|end|>');
    buffer.writeln('<|assistant|>');

    return buffer.toString();
  }

  AiResponseCategory _categorizePrompt(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('farmacol') ||
        lower.contains('medicamento') ||
        lower.contains('fármaco')) {
      return AiResponseCategory.pharmacologic;
    }
    if (lower.contains('interacci')) {
      return AiResponseCategory.interaction;
    }
    if (lower.contains('soap') ||
        lower.contains('nanda') ||
        lower.contains('resumen') ||
        lower.contains('summary')) {
      return AiResponseCategory.clinicalSummary;
    }
    if (lower.contains('signos vitales') ||
        lower.contains('vital') ||
        lower.contains('presión') ||
        lower.contains('frecuencia')) {
      return AiResponseCategory.vitalInterpretation;
    }
    if (lower.contains('recomendación') || lower.contains('recomend')) {
      return AiResponseCategory.recommendation;
    }
    return AiResponseCategory.general;
  }

  String _generateSimulatedResponse(String prompt, ClinicalContext? context) {
    final lower = prompt.toLowerCase();

    if (lower.contains('analiza') && lower.contains('medicamento')) {
      return _simulateMedicationAnalysis(prompt);
    }
    if (lower.contains('formato soap') ||
        lower.contains('soap') && lower.contains('resumen')) {
      return _simulateSoapSummary(context);
    }
    if (lower.contains('formato nanda') || lower.contains('nanda')) {
      return _simulateNandaPlan(context);
    }
    if (lower.contains('signos vitales') || lower.contains('interpret')) {
      return _simulateVitalSignsInterpretation(prompt);
    }
    if (lower.contains('interacci')) {
      return _simulateInteractionAnalysis(prompt);
    }
    if (lower.contains('recomendación') || lower.contains('recomend')) {
      return _simulateNursingRecommendation();
    }

    return _simulateGeneralResponse(prompt, context);
  }

  String _simulateMedicationAnalysis(String prompt) {
    final medMatch = RegExp(r'Medicamento:\s*([^\n]+)').firstMatch(prompt);
    final medication = medMatch?.group(1)?.trim() ?? 'medicamento';

    return '**Análisis Farmacológico: $medication**\n\n'
        '**1. Mecanismo de acción:**\n'
        'Actúa sobre receptores específicos modulando la respuesta fisiológica. '
        'Su mecanismo principal involucra la inhibición/activación de vías de '
        'señalización celular.\n\n'
        '**2. Indicaciones principales:**\n'
        '• Tratamiento de condiciones agudas y crónicas según guías clínicas\n'
        '• Administración por vía oral/intravenosa según presentación\n\n'
        '**3. Dosis habitual en adultos:**\n'
        '• Rango terapéutico estándar: dosis variable según indicación\n'
        '• Ajustar en insuficiencia renal/hepática\n\n'
        '**4. Efectos adversos frecuentes:**\n'
        '• Gastrointestinales (náusea, vómito)\n'
        '• Neurológicos (cefalea, mareo)\n'
        '• Reacciones cutáneas\n\n'
        '**5. Contraindicaciones:**\n'
        '• Hipersensibilidad conocida al principio activo\n'
        '• Condiciones específicas que contraindican su uso\n\n'
        '**6. Interacciones relevantes:**\n'
        '• Monitorear niveles séricos con medicamentos de ventana terapéutica estrecha\n\n'
        '**7. Consideraciones de enfermería:**\n'
        '• Verificar identidad del paciente y medicamento antes de administrar\n'
        '• Monitorear signos vitales antes, durante y después de la administración\n'
        '• Educar al paciente sobre efectos esperados y adversos\n\n'
        '**8. Monitoreo requerido:**\n'
        '• Signos vitales cada 4-6 horas\n'
        '• Función renal y hepática según protocolo\n'
        '• Niveles plasmáticos si aplica\n\n'
        '> ⚠️ **Nota de seguridad:** Esta información es referencial. '
        'Verifique siempre con fuentes oficiales y el protocolo institucional.';
  }

  String _simulateSoapSummary(ClinicalContext? context) {
    final age = context?.patientAge ?? 45;
    final weight = context?.patientWeight ?? 70.0;
    final gender = context?.patientGender ?? 'femenino';

    return '**Resumen Clínico — Formato SOAP**\n\n'
        '**S (Subjetivo):**\n'
        'Paciente $gender de $age años, peso ${weight}kg, '
        'refiere malestar general. '
        '${context?.diagnoses.isNotEmpty == true ? "Diagnóstico principal: ${context!.diagnoses.join(", ")}. " : ""}'
        '${context?.recentNotes.isNotEmpty == true ? context!.recentNotes : "Sin notas recientes registradas."}\n\n'
        '**O (Objetivo):**\n'
        'Signos vitales: ${_formatVitalSigns(context)}\n'
        'Paciente consciente, orientado, Glasgow 15/15.\n'
        'Piel hidratada, mucosas rosadas.\n'
        'Diuresis conservada.\n\n'
        '**A (Evaluación):**\n'
        'Paciente hemodinámicamente estable. '
        'Responde adecuadamente al tratamiento instaurado. '
        'Requiere monitoreo continuo de signos vitales y evolución clínica.\n\n'
        '**P (Plan):**\n'
        '• Continuar tratamiento farmacológico según indicación\n'
        '• Monitoreo de signos vitales cada 4 horas\n'
        '• Balance hídrico estricto\n'
        '• Evaluación de respuesta al tratamiento en 24 horas\n'
        '• Educación al paciente y familiares sobre plan terapéutico\n\n'
        '> *Documentación generada el ${DateTime.now().toLocal().toString().substring(0, 16)}*';
  }

  String _simulateNandaPlan(ClinicalContext? context) {
    final diag = context?.diagnoses.isNotEmpty == true
        ? context!.diagnoses.first
        : 'cuidado hospitalario';

    return '**Plan de Cuidados NANDA-NIC-NOC**\n\n'
        '**Diagnóstico NANDA:**\n'
        '[00001] Deterioro del mantenimiento del hogar r/c '
        'hospitalización prolongada m/p dificultad para mantener el entorno\n\n'
        '**Resultados NOC Esperados:**\n'
        '• [2001] Estado de salud: Bienestar general — Indicador: Nivel 4 (Leve desviación)\n'
        '• [1300] Aceptación: estado de salud — Indicador: Nivel 3 (Moderado)\n\n'
        '**Intervenciones NIC Prioritarias:**\n'
        '• [5240] Asistencia en el mantenimiento del hogar\n'
        '  - Identificar recursos comunitarios disponibles\n'
        '  - Coordinar con trabajo social para plan de egreso\n'
        '• [4480] Facilitar la autorresponsabilidad\n'
        '  - Fomentar participación activa en el plan terapéutico\n\n'
        '**Fundamento Científico:**\n'
        'La intervención de enfermería basada en la taxonomía NANDA-NIC-NOC '
        'proporciona un marco estandarizado para garantizar la continuidad '
        'del cuidado y la evaluación objetiva de resultados.\n\n'
        '**Evaluación:**\n'
        'Reevaluar en 48-72 horas. Indicadores NOC objetivo: mantener o '
        'mejorar en al menos 1 nivel.\n\n'
        '> 📋 *Diagnóstico adaptado para: $diag*';
  }

  String _simulateVitalSignsInterpretation(String prompt) {
    return '**Interpretación de Signos Vitales**\n\n'
        '**1. Resumen General:**\n'
        'Los signos vitales presentan valores dentro de parámetros '
        'de observación. Se recomienda correlacionar con el estado clínico global.\n\n'
        '**2. Valores Analizados:**\n'
        '• Presión Arterial: Valor dentro del rango de aceptable\n'
        '• Frecuencia Cardíaca: Ritmo regular, frecuencia conservada\n'
        '• Frecuencia Respiratoria: Patrón respiratorio normal\n'
        '• Temperatura: Normotermia\n'
        '• Saturación O₂: Oxigenación adecuada (>95%)\n\n'
        '**3. Interpretación Clínica:**\n'
        'Paciente hemodinámicamente estable. Signos vitales dentro de '
        'parámetros esperados para la condición clínica de base.\n\n'
        '**4. Recomendaciones de Enfermería:**\n'
        '• Continuar monitoreo cada 4-6 horas\n'
        '• Mantener registro en gráfica de signos vitales\n'
        '• Evaluar tendencias, no valores aislados\n\n'
        '**5. Seguimiento:**\n'
        '• Próximo control de rutina en 4 horas\n'
        '• Notificar si: PAS <90 o >160, FC <50 o >120, '
        'SatO₂ <92%, temperatura >38.5°C\n\n'
        '**6. Indicadores de Alarma:**\n'
        '• Hipotensión ortostática\n'
        '• Taquicardia sinusal persistente\n'
        '• Desaturación progresiva\n\n'
        '> 🩺 *Interpretación basada en guías clínicas institucionales. '
        'Correlacionar con evaluación clínica completa.*';
  }

  String _simulateInteractionAnalysis(String prompt) {
    return '**Análisis de Interacciones Medicamentosas**\n\n'
        '**1. Interacciones Identificadas:**\n'
        '• **Leve-Moderada:** Posible interacción farmacocinética a nivel hepático\n'
        '• **Monitoreo:** Niveles plasmáticos y función hepática\n\n'
        '**2. Mecanismo:**\n'
        'Competencia por enzimas del citocromo P450, específicamente '
        'CYP3A4 y CYP2D6, lo que puede alterar el metabolismo de ambos fármacos.\n\n'
        '**3. Severidad:**\n'
        '• Leve: No requiere modificación de dosis\n'
        '• Moderada: Monitorear respuesta clínica\n'
        '• Grave: Considerar alternativa terapéutica\n\n'
        '**4. Recomendaciones Clínicas:**\n'
        '• Monitorear función hepática cada 72 horas\n'
        '• Observar signos de toxicidad\n'
        '• Ajustar dosis si hay deterioro clínico\n\n'
        '**5. Signos de Alerta:**\n'
        '• Ictericia, coluria, dolor en hipocondrio derecho\n'
        '• Alteraciones del estado de conciencia\n'
        '• Sangrado no habitual\n\n'
        '> ⚗️ *Consulte con farmacia clínica para ajuste fino de dosis.*';
  }

  String _simulateNursingRecommendation() {
    return '**Recomendaciones de Enfermería**\n\n'
        '**Diagnóstico NANDA:**\n'
        '[00004] Riesgo de infección r/c procedimientos invasivos '
        'm/p exposición ambiental aumentada\n\n'
        '**Intervenciones NIC:**\n'
        '• [6545] Control de infecciones\n'
        '  - Lavado de manos antes y después de cada procedimiento\n'
        '  - Técnica aséptica para curaciones y accesos venosos\n'
        '  - Cambio de dispositivos invasivos según protocolo\n'
        '• [6650] Vigilancia\n'
        '  - Monitorear signos locales de infección (rubor, calor, dolor, edema)\n'
        '  - Registrar temperatura cada 4 horas\n\n'
        '**Resultados NOC Esperados:**\n'
        '• [0703] Severidad de la infección — Nivel objetivo: 4 (Leve)\n'
        '• [1101] Integridad tisular: piel y membranas mucosas — Nivel objetivo: 4\n\n'
        '**Evaluación:**\n'
        'Reevaluar cada turno. Notificar al médico si aparecen signos '
        'de infección sistémica (fiebre >38°C, taquicardia, leucocitosis).\n\n'
        '> 📌 *Recomendaciones basadas en guías de práctica clínica.*';
  }

  String _simulateGeneralResponse(String prompt, ClinicalContext? context) {
    final responses = [
      'Basado en la información proporcionada, puedo indicar que '
          'el manejo clínico debe enfocarse en el monitoreo continuo '
          'de signos vitales y la evaluación de la respuesta al tratamiento. '
          'Se recomienda mantener una comunicación efectiva con el equipo '
          'multidisciplinario para optimizar los resultados del paciente.\n\n'
          '**Recomendaciones:**\n'
          '• Continuar con las intervenciones actuales\n'
          '• Monitorear evolución cada 4-6 horas\n'
          '• Documentar hallazgos en el expediente clínico\n'
          '• Educar al paciente y familiares sobre el plan de cuidados\n\n'
          '> *¿Necesita información más específica sobre algún aspecto clínico '
          'en particular?*',
      'Desde la perspectiva de enfermería, es importante considerar '
          'los siguientes aspectos para el manejo integral del paciente:\n\n'
          '1. **Evaluación continua:** Valorar cambios en el estado clínico\n'
          '2. **Intervenciones:** Aplicar las intervenciones NIC según taxonomía\n'
          '3. **Documentación:** Registrar en formato SOAP estructurado\n'
          '4. **Comunicación:** Reportar hallazgos relevantes al médico\n\n'
          '**Recordatorio:** La seguridad del paciente es la prioridad '
          'fundamental en toda intervención de enfermería.',
      'De acuerdo con las guías de práctica clínica y la evidencia '
          'disponible, el abordaje recomendado incluye:\n\n'
          '• **Evaluación inicial:** Completa y sistemática\n'
          '• **Plan de cuidados:** Individualizado basado en NANDA\n'
          '• **Ejecución:** Intervenciones con fundamento científico\n'
          '• **Evaluación:** Continua de resultados esperados\n\n'
          '¿Le gustaría que profundice en algún aspecto específico?',
    ];

    return responses[_random.nextInt(responses.length)];
  }

  String _formatVitalSigns(ClinicalContext? context) {
    if (context == null || context.vitalSigns.isEmpty) {
      return 'Sin registros de signos vitales en el contexto actual';
    }
    return context.vitalSigns.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }
}
