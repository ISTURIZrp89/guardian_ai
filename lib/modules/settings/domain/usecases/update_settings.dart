import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettings {
  final SettingsRepository _repository;
  UpdateSettings(this._repository);

  Future<void> call(AppSettings settings) => _repository.updateSettings(settings);
}
