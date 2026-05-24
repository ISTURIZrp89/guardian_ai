import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/app_settings.dart';

class SettingsLocalDataSource {
  final FlutterSecureStorage _storage;
  static const _key = 'guardian_app_settings';

  SettingsLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSettings(AppSettings settings) async {
    final json = jsonEncode(settings.toMap());
    await _storage.write(key: _key, value: json);
  }

  Future<AppSettings> loadSettings() async {
    try {
      final json = await _storage.read(key: _key);
      if (json == null) return const AppSettings();
      final map = jsonDecode(json) as Map<String, dynamic>;
      return AppSettings.fromMap(map);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> deleteSettings() async {
    await _storage.delete(key: _key);
  }
}
