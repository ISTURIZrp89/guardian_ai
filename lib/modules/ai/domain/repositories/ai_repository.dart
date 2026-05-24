import 'dart:async';
import '../entities/ai_model_info.dart';
import '../entities/ai_response.dart';
import '../entities/clinical_context.dart';

abstract class AiRepository {
  Future<List<AiModelInfo>> getAvailableModels();
  Future<bool> loadModel(String modelId);
  Future<bool> unloadModel();
  Future<AiResponse> generateResponse(
    String prompt, {
    ClinicalContext? context,
  });
  Future<double> getMemoryUsage();
  Future<bool> isModelLoaded();
  Future<void> clearContext();
  Stream<double> getDownloadProgress(String modelId);
  Future<bool> downloadModel(String modelId);
  Future<bool> deleteModel(String modelId);
}
