class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es requerido';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Correo electrónico inválido';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El peso es requerido';
    }
    final weight = double.tryParse(value.trim());
    if (weight == null || weight < 0.5 || weight > 300) {
      return 'El peso debe estar entre 0.5 y 300 kg';
    }
    return null;
  }

  static String? validateDose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dosis es requerida';
    }
    final dose = double.tryParse(value.trim());
    if (dose == null || dose <= 0) {
      return 'La dosis debe ser mayor a 0';
    }
    if (dose > 10000) {
      return 'La dosis no puede exceder 10000';
    }
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El PIN es requerido';
    }
    final cleaned = value.trim();
    if (cleaned.length != 6) {
      return 'El PIN debe tener exactamente 6 dígitos';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(cleaned)) {
      return 'El PIN debe contener solo dígitos';
    }
    return null;
  }

  static String? validateBloodPressure(String? systolic, String? diastolic) {
    if (systolic == null || systolic.trim().isEmpty) {
      return 'Presión sistólica requerida';
    }
    if (diastolic == null || diastolic.trim().isEmpty) {
      return 'Presión diastólica requerida';
    }
    final sys = int.tryParse(systolic.trim());
    final dia = int.tryParse(diastolic.trim());
    if (sys == null || sys < 50 || sys > 250) {
      return 'Sistólica debe estar entre 50 y 250';
    }
    if (dia == null || dia < 30 || dia > 150) {
      return 'Diastólica debe estar entre 30 y 150';
    }
    if (dia >= sys) {
      return 'Diastólica debe ser menor que sistólica';
    }
    return null;
  }

  static String? validateHeartRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Frecuencia cardíaca requerida';
    }
    final hr = int.tryParse(value.trim());
    if (hr == null || hr < 20 || hr > 250) {
      return 'Frecuencia cardíaca debe estar entre 20 y 250 lpm';
    }
    return null;
  }

  static String? validateTemperature(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Temperatura requerida';
    }
    final temp = double.tryParse(value.trim());
    if (temp == null || temp < 34.0 || temp > 42.0) {
      return 'Temperatura debe estar entre 34°C y 42°C';
    }
    return null;
  }

  static String? validateRequired(String? value,
      [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }
}
