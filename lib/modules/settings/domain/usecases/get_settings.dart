import '../repositories/settings_repository.dart';
import '../entities/app_settings.dart';

class GetSettings {
  final SettingsRepository _repository;
  GetSettings(this._repository);

  Future<AppSettings> call() => _repository.getSettings();
}
