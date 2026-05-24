import 'package:guardian_ai/core/errors/failures.dart';
import '../entities/ai_model_info.dart';
import '../repositories/ai_repository.dart';

class LoadAiModel {
  final AiRepository _repository;

  LoadAiModel(this._repository);

  Future<AiModelInfo> execute(String modelId) async {
    try {
      final models = await _repository.getAvailableModels();
      final model = models.where((m) => m.id == modelId).firstOrNull;
      if (model == null) {
        throw AiFailure('Modelo no encontrado: $modelId', code: 'MODEL_NOT_FOUND');
      }
      final success = await _repository.loadModel(modelId);
      if (!success) {
        throw AiFailure('No se pudo cargar el modelo $modelId', code: 'LOAD_FAILED');
      }
      return model.copyWith(isLoaded: true);
    } on AiFailure {
      rethrow;
    } on Failure {
      rethrow;
    } catch (e) {
      throw AiFailure('Error al cargar el modelo: $e', code: 'LOAD_ERROR');
    }
  }

  Future<bool> unload() async {
    try {
      return await _repository.unloadModel();
    } catch (e) {
      throw AiFailure('Error al descargar el modelo: $e', code: 'UNLOAD_ERROR');
    }
  }
}
