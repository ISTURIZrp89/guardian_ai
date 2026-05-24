class AppSettings {
  final bool biometricEnabled;
  final int autoLockMinutes;
  final bool screenCaptureBlocked;
  final bool aiEnabled;
  final String aiModel;
  final int aiContextSize;
  final double aiTemperature;
  final bool batterySaverMode;
  final String exportFormat;

  const AppSettings({
    this.biometricEnabled = false,
    this.autoLockMinutes = 5,
    this.screenCaptureBlocked = false,
    this.aiEnabled = true,
    this.aiModel = 'biomistral-7b-q4',
    this.aiContextSize = 2048,
    this.aiTemperature = 0.7,
    this.batterySaverMode = false,
    this.exportFormat = 'pdf',
  });

  AppSettings copyWith({
    bool? biometricEnabled,
    int? autoLockMinutes,
    bool? screenCaptureBlocked,
    bool? aiEnabled,
    String? aiModel,
    int? aiContextSize,
    double? aiTemperature,
    bool? batterySaverMode,
    String? exportFormat,
  }) {
    return AppSettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      screenCaptureBlocked: screenCaptureBlocked ?? this.screenCaptureBlocked,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiModel: aiModel ?? this.aiModel,
      aiContextSize: aiContextSize ?? this.aiContextSize,
      aiTemperature: aiTemperature ?? this.aiTemperature,
      batterySaverMode: batterySaverMode ?? this.batterySaverMode,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }

  Map<String, dynamic> toMap() => {
    'biometricEnabled': biometricEnabled ? 1 : 0,
    'autoLockMinutes': autoLockMinutes,
    'screenCaptureBlocked': screenCaptureBlocked ? 1 : 0,
    'aiEnabled': aiEnabled ? 1 : 0,
    'aiModel': aiModel,
    'aiContextSize': aiContextSize,
    'aiTemperature': aiTemperature,
    'batterySaverMode': batterySaverMode ? 1 : 0,
    'exportFormat': exportFormat,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    biometricEnabled: (map['biometricEnabled'] as int? ?? 0) == 1,
    autoLockMinutes: map['autoLockMinutes'] as int? ?? 5,
    screenCaptureBlocked: (map['screenCaptureBlocked'] as int? ?? 0) == 1,
    aiEnabled: (map['aiEnabled'] as int? ?? 1) == 1,
    aiModel: map['aiModel'] as String? ?? 'biomistral-7b-q4',
    aiContextSize: map['aiContextSize'] as int? ?? 2048,
    aiTemperature: (map['aiTemperature'] as num?)?.toDouble() ?? 0.7,
    batterySaverMode: (map['batterySaverMode'] as int? ?? 0) == 1,
    exportFormat: map['exportFormat'] as String? ?? 'pdf',
  );
}
