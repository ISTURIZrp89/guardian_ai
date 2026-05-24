import 'dart:async';
import 'package:guardian_ai/core/errors/failures.dart';
import 'package:guardian_ai/modules/ai/domain/entities/ai_model_info.dart';
import 'package:guardian_ai/modules/ai/domain/entities/ai_response.dart';
import 'package:guardian_ai/modules/ai/domain/entities/clinical_context.dart';
import 'package:guardian_ai/modules/ai/domain/repositories/ai_repository.dart';
import 'package:guardian_ai/modules/ai/data/datasources/ai_local_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiLocalDataSource _localDataSource;

  AiRepositoryImpl({AiLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? AiLocalDataSource();

  @override
  Future<List<AiModelInfo>> getAvailableModels() async {
    try {
      return await _localDataSource.getAvailableModels();
    } catch (e) {
      throw AiFailure('Error al obtener modelos disponibles: $e');
    }
  }

  @override
  Future<bool> loadModel(String modelId) async {
    try {
      return await _localDataSource.loadModel(modelId);
    } catch (e) {
      throw AiFailure('Error al cargar el modelo: $e', code: 'LOAD_ERROR');
    }
  }

  @override
  Future<bool> unloadModel() async {
    try {
      return await _localDataSource.unloadModel();
    } catch (e) {
      throw AiFailure('Error al descargar el modelo: $e', code: 'UNLOAD_ERROR');
    }
  }

  @override
  Future<AiResponse> generateResponse(
    String prompt, {
    ClinicalContext? context,
  }) async {
    try {
      return await _localDataSource.generateResponse(prompt, context: context);
    } catch (e) {
      throw AiFailure('Error al generar respuesta: $e', code: 'GENERATION_ERROR');
    }
  }

  @override
  Future<double> getMemoryUsage() async {
    try {
      return await _localDataSource.getMemoryUsage();
    } catch (e) {
      throw AiFailure('Error al obtener uso de memoria: $e');
    }
  }

  @override
  Future<bool> isModelLoaded() async {
    try {
      return await _localDataSource.isModelLoaded();
    } catch (e) {
      throw AiFailure('Error al verificar estado del modelo: $e');
    }
  }

  @override
  Future<void> clearContext() async {
    try {
      await _localDataSource.clearContext();
    } catch (e) {
      throw AiFailure('Error al limpiar contexto: $e');
    }
  }

  @override
  Stream<double> getDownloadProgress(String modelId) {
    try {
      return _localDataSource.getDownloadProgress(modelId);
    } catch (e) {
      throw AiFailure('Error al obtener progreso de descarga: $e');
    }
  }

  @override
  Future<bool> downloadModel(String modelId) async {
    try {
      return await _localDataSource.downloadModel(modelId);
    } catch (e) {
      throw AiFailure('Error al descargar el modelo: $e', code: 'DOWNLOAD_ERROR');
    }
  }

  @override
  Future<bool> deleteModel(String modelId) async {
    try {
      return await _localDataSource.deleteModel(modelId);
    } catch (e) {
      throw AiFailure('Error al eliminar el modelo: $e', code: 'DELETE_ERROR');
    }
  }
}
