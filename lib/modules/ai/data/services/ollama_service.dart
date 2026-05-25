// lib/modules/ai/data/services/ollama_service.dart
//
// Servicio real de inferencia via Ollama HTTP API.
// Se conecta al servidor Ollama corriendo en la misma red WiFi.
// Soporta streaming de tokens en tiempo real.

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

class OllamaService {
  static final OllamaService _instance = OllamaService._();
  static OllamaService get instance => _instance;

  OllamaService._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(minutes: 5),
    headers: {'Content-Type': 'application/json'},
  ));

  String _baseUrl = 'http://localhost:11434';
  String _modelName = 'biomistral';
  bool _isConnected = false;

  String get baseUrl => _baseUrl;
  String get modelName => _modelName;
  bool get isConnected => _isConnected;

  void configure({required String host, required String model}) {
    _baseUrl = host.endsWith('/') ? host.substring(0, host.length - 1) : host;
    _modelName = model;
  }

  /// Verifica si el servidor Ollama está disponible.
  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get<dynamic>('$_baseUrl/api/tags');
      _isConnected = response.statusCode == 200;
      return _isConnected;
    } catch (_) {
      _isConnected = false;
      return false;
    }
  }

  /// Obtiene los modelos disponibles en el servidor Ollama.
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await _dio.get<dynamic>('$_baseUrl/api/tags');
      final models = response.data['models'] as List? ?? [];
      return models
          .map((m) => (m['name'] as String).split(':').first)
          .toSet()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Genera una respuesta completa (no streaming) desde Ollama.
  ///
  /// Para uso médico: temperature baja (0.1-0.3) = respuestas más deterministas.
  Future<String> generate({
    required String prompt,
    double temperature = 0.2,
    int maxTokens = 512,
    String? systemPrompt,
  }) async {
    final body = {
      'model': _modelName,
      'prompt': prompt,
      'stream': false,
      'options': {
        'temperature': temperature,
        'num_predict': maxTokens,
        'stop': ['<|end|>', '</s>', '[INST]'],
      },
      if (systemPrompt != null) 'system': systemPrompt,
    };

    try {
      final response = await _dio.post<dynamic>(
        '$_baseUrl/api/generate',
        data: jsonEncode(body),
      );
      return (response.data['response'] as String? ?? '').trim();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception(
          'No se pudo conectar a Ollama en $_baseUrl.\n'
          'Asegúrate de que Ollama esté corriendo y el teléfono esté en la misma red WiFi.',
        );
      }
      throw Exception('Error de Ollama: ${e.message}');
    }
  }

  /// Genera una respuesta con streaming (token por token en tiempo real).
  Stream<String> generateStream({
    required String prompt,
    double temperature = 0.2,
    int maxTokens = 512,
    String? systemPrompt,
  }) async* {
    final body = {
      'model': _modelName,
      'prompt': prompt,
      'stream': true,
      'options': {
        'temperature': temperature,
        'num_predict': maxTokens,
        'stop': ['<|end|>', '</s>', '[INST]'],
      },
      if (systemPrompt != null) 'system': systemPrompt,
    };

    try {
      final response = await _dio.post<ResponseBody>(
        '$_baseUrl/api/generate',
        data: jsonEncode(body),
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (line.isEmpty) continue;
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          final token = json['response'] as String? ?? '';
          if (token.isNotEmpty) yield token;
          if (json['done'] == true) break;
        } catch (_) {
          continue;
        }
      }
    } on DioException catch (e) {
      throw Exception('Error de streaming Ollama: ${e.message}');
    }
  }
}
