class AppConstants {
  AppConstants._();

  static const String appName = 'Guardian AI';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Plataforma Clínica Multiplataforma Offline-First';

  static const String dbName = 'guardian_ai.db';
  static const int dbVersion = 1;
  static const String dbPasswordKey = 'guardian_db_key';

  static const String sharedPrefsKey = 'guardian_prefs';
  static const String secureStorageKey = 'guardian_secure';

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration sessionTimeout = Duration(hours: 12);
  static const Duration autoLockDuration = Duration(minutes: 5);

  static const int maxPinAttempts = 5;
  static const int pinLength = 6;
  static const int lockoutDurationMinutes = 15;

  static const String dateFormatDisplay = 'dd/MM/yyyy HH:mm';
  static const String dateFormatStorage = 'yyyy-MM-ddTHH:mm:ss';
  static const String dateFormatClinical = 'dd/MMM/yyyy';

  static const double maxWeightKg = 300.0;
  static const double minWeightKg = 0.5;
  static const double maxDoseMg = 10000.0;
  static const double maxInfusionRate = 5000.0;

  static const String aiModelDefault = 'biomistral-7b-q4.gguf';
  static const int aiContextSize = 2048;
  static const int aiMaxTokens = 512;
  static const double aiTemperature = 0.3;
  static const int aiThreads = 4;

  static const String exportPdfPrefix = 'guardian_report_';
  static const String exportTxtPrefix = 'guardian_notes_';
}
