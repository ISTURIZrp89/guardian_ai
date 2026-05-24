class ClinicalRanges {
  ClinicalRanges._();

  static const double normalSystolicMin = 90;
  static const double normalSystolicMax = 140;
  static const double normalDiastolicMin = 60;
  static const double normalDiastolicMax = 90;
  static const double normalHeartRateMin = 60;
  static const double normalHeartRateMax = 100;
  static const double normalRespiratoryRateMin = 12;
  static const double normalRespiratoryRateMax = 20;
  static const double normalTemperatureMin = 36.0;
  static const double normalTemperatureMax = 37.5;
  static const double normalSpo2Min = 95;
  static const double normalSpo2Max = 100;
  static const int normalPainLevelMin = 0;
  static const int normalPainLevelMax = 3;

  static const double criticalSystolicMin = 70;
  static const double criticalSystolicMax = 180;
  static const double criticalHeartRateMin = 40;
  static const double criticalHeartRateMax = 140;
  static const double criticalSpo2Min = 85;
}

class DatabaseTables {
  DatabaseTables._();

  static const String patients = 'patients';
  static const String vitalSigns = 'vital_signs';
  static const String medications = 'medications';
  static const String clinicalNotes = 'clinical_notes';
  static const String shiftSessions = 'shift_sessions';
  static const String shiftTasks = 'shift_tasks';
  static const String shiftLogEntries = 'shift_log_entries';
  static const String settings = 'app_settings';
  static const String logs = 'app_logs';
}
