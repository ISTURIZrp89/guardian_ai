import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/shared/models/vital_signs_model.dart';

void main() {
  group('VitalSignsModel', () {
    const testPatientId = 'patient-001';

    test('crea instancia con valores por defecto', () {
      final vs = VitalSignsModel(patientId: testPatientId);

      expect(vs.patientId, testPatientId);
      expect(vs.bloodPressureSystolic, 120);
      expect(vs.bloodPressureDiastolic, 80);
      expect(vs.heartRate, 72);
      expect(vs.respiratoryRate, 16);
      expect(vs.temperature, 36.5);
      expect(vs.oxygenSaturation, 98);
      expect(vs.painLevel, 0);
      expect(vs.id, isNotEmpty);
      expect(vs.recordedAt, isNotNull);
    });

    group('rangos normales', () {
      test('isNormal retorna true para signos vitales normales', () {
        final vs = VitalSignsModel(patientId: testPatientId);
        expect(vs.isNormal, true);
      });

      test('isBpNormal valida rango de presión arterial', () {
        final normal = VitalSignsModel(
          patientId: testPatientId,
          bloodPressureSystolic: 110,
          bloodPressureDiastolic: 70,
        );
        expect(normal.isBpNormal, true);

        final hipertenso = VitalSignsModel(
          patientId: testPatientId,
          bloodPressureSystolic: 140,
          bloodPressureDiastolic: 90,
        );
        expect(hipertenso.isBpNormal, false);
      });

      test('isHrNormal valida rango de frecuencia cardíaca', () {
        final normal = VitalSignsModel(
          patientId: testPatientId,
          heartRate: 72,
        );
        expect(normal.isHrNormal, true);

        final taquicardico = VitalSignsModel(
          patientId: testPatientId,
          heartRate: 110,
        );
        expect(taquicardico.isHrNormal, false);
      });

      test('isRrNormal valida rango de frecuencia respiratoria', () {
        final normal = VitalSignsModel(
          patientId: testPatientId,
          respiratoryRate: 16,
        );
        expect(normal.isRrNormal, true);

        final taquipneico = VitalSignsModel(
          patientId: testPatientId,
          respiratoryRate: 28,
        );
        expect(taquipneico.isRrNormal, false);
      });

      test('isTempNormal valida rango de temperatura', () {
        final normal = VitalSignsModel(
          patientId: testPatientId,
          temperature: 37.0,
        );
        expect(normal.isTempNormal, true);

        final febril = VitalSignsModel(
          patientId: testPatientId,
          temperature: 38.5,
        );
        expect(febril.isTempNormal, false);
      });

      test('isSpO2Normal valida saturación de oxígeno', () {
        final normal = VitalSignsModel(
          patientId: testPatientId,
          oxygenSaturation: 98,
        );
        expect(normal.isSpO2Normal, true);

        final hipoxico = VitalSignsModel(
          patientId: testPatientId,
          oxygenSaturation: 92,
        );
        expect(hipoxico.isSpO2Normal, false);
      });

      test('isPainNormal valida nivel de dolor', () {
        final normal = VitalSignsModel(
          patientId: testPatientId,
          painLevel: 2,
        );
        expect(normal.isPainNormal, true);

        final dolor = VitalSignsModel(
          patientId: testPatientId,
          painLevel: 5,
        );
        expect(dolor.isPainNormal, false);
      });
    });

    group('JSON serialization', () {
      test('toJson produce mapa correcto', () {
        final vs = VitalSignsModel(
          patientId: testPatientId,
          bloodPressureSystolic: 130,
          bloodPressureDiastolic: 85,
          heartRate: 80,
          temperature: 37.2,
        );

        final json = vs.toJson();
        expect(json['patient_id'], testPatientId);
        expect(json['bp_systolic'], 130);
        expect(json['bp_diastolic'], 85);
        expect(json['heart_rate'], 80);
        expect(json['temperature'], 37.2);
        expect(json['recorded_at'], vs.recordedAt.toIso8601String());
      });

      test('fromJson reconstruye modelo correctamente', () {
        final json = {
          'id': 'test-id-123',
          'patient_id': testPatientId,
          'bp_systolic': 110,
          'bp_diastolic': 70,
          'heart_rate': 75,
          'respiratory_rate': 18,
          'temperature': 36.8,
          'oxygen_saturation': 97,
          'pain_level': 1,
          'recorded_at': '2026-05-24T10:30:00.000',
          'notes': 'Paciente estable',
        };

        final vs = VitalSignsModel.fromJson(json);
        expect(vs.id, 'test-id-123');
        expect(vs.patientId, testPatientId);
        expect(vs.bloodPressureSystolic, 110);
        expect(vs.bloodPressureDiastolic, 70);
        expect(vs.heartRate, 75);
        expect(vs.respiratoryRate, 18);
        expect(vs.temperature, 36.8);
        expect(vs.oxygenSaturation, 97);
        expect(vs.painLevel, 1);
        expect(vs.notes, 'Paciente estable');
      });

      test('fromJson usa valores por defecto para campos nulos', () {
        final json = {
          'patient_id': testPatientId,
        };

        final vs = VitalSignsModel.fromJson(json);
        expect(vs.bloodPressureSystolic, 120);
        expect(vs.bloodPressureDiastolic, 80);
        expect(vs.heartRate, 72);
      });

      test('toJson y fromJson son inversos', () {
        final original = VitalSignsModel(
          patientId: testPatientId,
          bloodPressureSystolic: 125,
          bloodPressureDiastolic: 82,
          heartRate: 78,
          respiratoryRate: 16,
          temperature: 36.6,
          oxygenSaturation: 99,
          painLevel: 2,
          notes: 'Nota de prueba',
        );

        final json = original.toJson();
        final restored = VitalSignsModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.patientId, original.patientId);
        expect(restored.bloodPressureSystolic, original.bloodPressureSystolic);
        expect(restored.bloodPressureDiastolic, original.bloodPressureDiastolic);
        expect(restored.heartRate, original.heartRate);
        expect(restored.temperature, original.temperature);
        expect(restored.oxygenSaturation, original.oxygenSaturation);
        expect(restored.painLevel, original.painLevel);
      });
    });

    group('copyWith', () {
      test('copyWith preserva valores no modificados', () {
        final vs = VitalSignsModel(patientId: testPatientId);
        final copied = vs.copyWith(heartRate: 90);

        expect(copied.heartRate, 90);
        expect(copied.bloodPressureSystolic, vs.bloodPressureSystolic);
        expect(copied.bloodPressureDiastolic, vs.bloodPressureDiastolic);
        expect(copied.patientId, vs.patientId);
      });
    });

    test('equality basada en id', () {
      final vs1 = VitalSignsModel(
        patientId: testPatientId,
        id: 'same-id',
      );
      final vs2 = VitalSignsModel(
        patientId: testPatientId,
        id: 'same-id',
      );

      expect(vs1 == vs2, true);
      expect(vs1.hashCode, vs2.hashCode);
    });
  });
}
