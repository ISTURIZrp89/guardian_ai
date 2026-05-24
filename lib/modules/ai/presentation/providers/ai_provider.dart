import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_ai/core/errors/failures.dart';
import 'package:guardian_ai/modules/ai/domain/entities/ai_model_info.dart';
import 'package:guardian_ai/modules/ai/domain/entities/ai_response.dart';
import 'package:guardian_ai/modules/ai/domain/entities/clinical_context.dart';
import 'package:guardian_ai/modules/ai/domain/repositories/ai_repository.dart';
import 'package:guardian_ai/modules/ai/domain/usecases/analyze_medication.dart';
import 'package:guardian_ai/modules/ai/domain/usecases/analyze_vital_signs.dart';
import 'package:guardian_ai/modules/ai/domain/usecases/generate_clinical_response.dart';
import 'package:guardian_ai/modules/ai/domain/usecases/generate_clinical_summary.dart';
import 'package:guardian_ai/modules/ai/domain/usecases/load_ai_model.dart';
import 'package:guardian_ai/modules/ai/data/repositories/ai_repository_impl.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl();
});

final aiProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return AiNotifier(repository);
});

class AiState {
  final bool isLoaded;
  final bool isLoading;
  final AiModelInfo? selectedModel;
  final AiResponse? response;
  final double memoryUsage;
  final String? error;
  final double downloadProgress;
  final List<AiResponse> conversationHistory;
  final ClinicalContext? clinicalContext;

  const AiState({
    this.isLoaded = false,
    this.isLoading = false,
    this.selectedModel,
    this.response,
    this.memoryUsage = 0.0,
    this.error,
    this.downloadProgress = 0.0,
    this.conversationHistory = const [],
    this.clinicalContext,
  });

  AiState copyWith({
    bool? isLoaded,
    bool? isLoading,
    AiModelInfo? selectedModel,
    AiResponse? response,
    double? memoryUsage,
    String? error,
    double? downloadProgress,
    List<AiResponse>? conversationHistory,
    ClinicalContext? clinicalContext,
    bool clearError = false,
    bool clearResponse = false,
  }) {
    return AiState(
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      selectedModel: selectedModel ?? this.selectedModel,
      response: clearResponse ? null : (response ?? this.response),
      memoryUsage: memoryUsage ?? this.memoryUsage,
      error: clearError ? null : (error ?? this.error),
      downloadProgress: downloadProgress ?? this.downloadProgress,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      clinicalContext: clinicalContext ?? this.clinicalContext,
    );
  }
}

class AiNotifier extends StateNotifier<AiState> {
  final AiRepository _repository;
  late final LoadAiModel _loadAiModel;
  late final GenerateClinicalResponse _generateClinicalResponse;
  late final AnalyzeMedication _analyzeMedication;
  late final GenerateClinicalSummary _generateClinicalSummary;
  late final AnalyzeVitalSigns _analyzeVitalSigns;
  StreamSubscription<double>? _downloadSubscription;

  AiNotifier(this._repository) : super(const AiState()) {
    _loadAiModel = LoadAiModel(_repository);
    _generateClinicalResponse = GenerateClinicalResponse(_repository);
    _analyzeMedication = AnalyzeMedication(_repository);
    _generateClinicalSummary = GenerateClinicalSummary(_repository);
    _analyzeVitalSigns = AnalyzeVitalSigns(_repository);
    _init();
  }

  Future<void> _init() async {
    try {
      final models = await _repository.getAvailableModels();
      if (models.isNotEmpty) {
        final loaded = models.firstWhere(
          (m) => m.isLoaded,
          orElse: () => models.first,
        );
        final isLoaded = await _repository.isModelLoaded();
        final memory = await _repository.getMemoryUsage();
        state = state.copyWith(
          selectedModel: loaded,
          isLoaded: isLoaded,
          memoryUsage: memory,
        );
      }
    } catch (_) {}
  }

  Future<void> loadModel(String modelId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final model = await _loadAiModel.execute(modelId);
      final memory = await _repository.getMemoryUsage();
      state = state.copyWith(
        isLoaded: true,
        isLoading: false,
        selectedModel: model,
        memoryUsage: memory,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  Future<void> unloadModel() async {
    state = state.copyWith(isLoading: true);
    try {
      await _loadAiModel.unload();
      state = state.copyWith(
        isLoaded: false,
        isLoading: false,
        selectedModel: null,
        memoryUsage: 0.0,
        conversationHistory: [],
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _generateClinicalResponse.execute(
        message: message,
        context: state.clinicalContext,
      );
      state = state.copyWith(
        isLoading: false,
        response: response,
        conversationHistory: [...state.conversationHistory, response],
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  Future<void> analyzeMedication(String medicationName) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _analyzeMedication.execute(
        medicationName: medicationName,
        context: state.clinicalContext,
      );
      state = state.copyWith(
        isLoading: false,
        response: response,
        conversationHistory: [...state.conversationHistory, response],
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  Future<void> generateSummary({
    required ClinicalContext context,
    SummaryFormat format = SummaryFormat.soap,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clinicalContext: context,
    );
    try {
      final response = await _generateClinicalSummary.execute(
        context: context,
        format: format,
      );
      state = state.copyWith(
        isLoading: false,
        response: response,
        conversationHistory: [...state.conversationHistory, response],
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  Future<void> analyzeVitals(Map<String, dynamic> vitalSigns) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _analyzeVitalSigns.execute(
        vitalSigns: vitalSigns,
        context: state.clinicalContext,
      );
      state = state.copyWith(
        isLoading: false,
        response: response,
        conversationHistory: [...state.conversationHistory, response],
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  Future<void> downloadModel(String modelId) async {
    state = state.copyWith(isLoading: true, downloadProgress: 0.0);
    try {
      _downloadSubscription?.cancel();
      _downloadSubscription = _repository
          .getDownloadProgress(modelId)
          .listen((progress) {
        state = state.copyWith(downloadProgress: progress);
      });
      await _repository.downloadModel(modelId);
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false, downloadProgress: 1.0);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  void clearResponse() {
    state = state.copyWith(clearResponse: true, clearError: true);
  }

  void clearConversation() {
    state = state.copyWith(
      conversationHistory: [],
      clearResponse: true,
      clearError: true,
    );
  }

  void setClinicalContext(ClinicalContext context) {
    state = state.copyWith(clinicalContext: context);
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    super.dispose();
  }
}
