import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/reset_settings.dart';
import '../../domain/usecases/update_settings.dart';

class SettingsState {
  final AppSettings settings;
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    this.settings = const AppSettings(),
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = SettingsLocalDataSource();
  return SettingsRepositoryImpl(dataSource);
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;
  late final GetSettings _getSettings;
  late final UpdateSettings _updateSettings;
  late final ResetSettings _resetSettings;

  SettingsNotifier(this._repository) : super(const SettingsState()) {
    _getSettings = GetSettings(_repository);
    _updateSettings = UpdateSettings(_repository);
    _resetSettings = ResetSettings(_repository);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final settings = await _getSettings.call();
      state = state.copyWith(settings: settings, isLoading: false);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error inesperado al cargar configuración',
      );
    }
  }

  Future<void> update(AppSettings newSettings) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _updateSettings.call(newSettings);
      state = state.copyWith(settings: newSettings, isLoading: false);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error inesperado al guardar configuración',
      );
    }
  }

  Future<void> reset() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _resetSettings.call();
      state = state.copyWith(settings: const AppSettings(), isLoading: false);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error inesperado al restablecer configuración',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
