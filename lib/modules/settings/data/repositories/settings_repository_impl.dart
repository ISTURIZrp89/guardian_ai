import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<AppSettings> getSettings() => _dataSource.loadSettings();

  @override
  Future<void> updateSettings(AppSettings settings) =>
      _dataSource.saveSettings(settings);

  @override
  Future<void> resetSettings() => _dataSource.deleteSettings();
}
