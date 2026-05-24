import '../repositories/settings_repository.dart';

class ResetSettings {
  final SettingsRepository _repository;
  ResetSettings(this._repository);

  Future<void> call() => _repository.resetSettings();
}
