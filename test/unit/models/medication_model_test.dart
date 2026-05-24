import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/shared/models/medication_model.dart';

void main() {
  group('MedicationRoute', () {
    test('toJson y fromJson son inversos para todas las rutas', () {
      for (final route in MedicationRoute.values) {
        final json = route.toJson();
        expect(MedicationRoute.fromJson(json), route);
      }
    });

    test('fromJson retorna MedicationRoute.other para valor desconocido', () {
      expect(
        MedicationRoute.fromJson('inexistente'),
        MedicationRoute.other,
      );
    });

    test('label retorna texto en español', () {
      expect(MedicationRoute.oral.label, 'Oral');
      expect(MedicationRoute.iv.label, 'IV');
      expect(MedicationRoute.im.label, 'IM');
    });
  });

  group('MedicationStatus', () {
    test('toJson y fromJson son inversos para todos los estados', () {
      for (final status in MedicationStatus.values) {
        final json = status.toJson();
        expect(MedicationStatus.fromJson(json), status);
      }
    });

    test('fromJson retorna MedicationStatus.active para valor desconocido', () {
      expect(
        MedicationStatus.fromJson('inexistente'),
        MedicationStatus.active,
      );
    });

    test('label retorna texto en español', () {
      expect(MedicationStatus.active.label, 'Activo');
      expect(MedicationStatus.paused.label, 'Pausado');
      expect(MedicationStatus.completed.label, 'Completado');
      expect(MedicationStatus.discontinued.label, 'Discontinuado');
    });
  });

  group('MedicationModel', () {
    const testPatientId = 'patient-001';
    final testStartDate = DateTime(2026, 5, 1);

    test('crea instancia con valores requeridos', () {
      final med = MedicationModel(
        patientId: testPatientId,
        name: 'Paracetamol',
        dosage: 500,
        frequency: 'C/8h',
        startDate: testStartDate,
        prescribedBy: 'Dr. García',
      );

      expect(med.patientId, testPatientId);
      expect(med.name, 'Paracetamol');
      expect(med.dosage, 500);
      expect(med.unit, 'mg');
      expect(med.route, MedicationRoute.oral);
      expect(med.status, MedicationStatus.active);
      expect(med.id, isNotEmpty);
    });

    group('JSON serialization', () {
      test('toJson produce mapa correcto', () {
        final med = MedicationModel(
          patientId: testPatientId,
          name: 'Amoxicilina',
          dosage: 1000,
          unit: 'mg',
          route: MedicationRoute.oral,
          frequency: 'C/12h',
          startDate: testStartDate,
          prescribedBy: 'Dr. García',
          notes: 'Tomar con alimentos',
          status: MedicationStatus.active,
        );

        final json = med.toJson();
        expect(json['patient_id'], testPatientId);
        expect(json['name'], 'Amoxicilina');
        expect(json['dosage'], 1000);
        expect(json['unit'], 'mg');
        expect(json['route'], 'oral');
        expect(json['frequency'], 'C/12h');
        expect(json['prescribed_by'], 'Dr. García');
        expect(json['notes'], 'Tomar con alimentos');
        expect(json['status'], 'active');
      });

      test('fromJson reconstruye modelo correctamente', () {
        final json = {
          'id': 'med-001',
          'patient_id': testPatientId,
          'name': 'Ibuprofeno',
          'dosage': 600,
          'unit': 'mg',
          'route': 'oral',
          'frequency': 'C/8h',
          'start_date': '2026-05-01T08:00:00.000',
          'end_date': '2026-05-10T08:00:00.000',
          'prescribed_by': 'Dr. López',
          'notes': 'Con alimentos',
          'status': 'active',
        };

        final med = MedicationModel.fromJson(json);
        expect(med.id, 'med-001');
        expect(med.patientId, testPatientId);
        expect(med.name, 'Ibuprofeno');
        expect(med.dosage, 600);
        expect(med.unit, 'mg');
        expect(med.route, MedicationRoute.oral);
        expect(med.frequency, 'C/8h');
        expect(med.prescribedBy, 'Dr. López');
        expect(med.notes, 'Con alimentos');
        expect(med.status, MedicationStatus.active);
        expect(med.endDate, DateTime(2026, 5, 10, 8, 0, 0));
      });

      test('fromJson usa valores por defecto', () {
        final json = {
          'patient_id': testPatientId,
          'name': 'Test',
          'dosage': 100,
          'frequency': 'C/8h',
          'start_date': '2026-05-01T00:00:00.000',
          'prescribed_by': 'Dr. Test',
        };

        final med = MedicationModel.fromJson(json);
        expect(med.unit, 'mg');
        expect(med.route, MedicationRoute.oral);
        expect(med.status, MedicationStatus.active);
        expect(med.endDate, isNull);
      });

      test('toJson y fromJson son inversos', () {
        final original = MedicationModel(
          patientId: testPatientId,
          name: 'Metformina',
          dosage: 850,
          unit: 'mg',
          route: MedicationRoute.oral,
          frequency: 'C/12h',
          startDate: testStartDate,
          endDate: DateTime(2026, 6, 1),
          prescribedBy: 'Dra. Martínez',
          notes: 'Suspender si FG < 30',
          status: MedicationStatus.active,
        );

        final json = original.toJson();
        final restored = MedicationModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.patientId, original.patientId);
        expect(restored.name, original.name);
        expect(restored.dosage, original.dosage);
        expect(restored.unit, original.unit);
        expect(restored.route, original.route);
        expect(restored.frequency, original.frequency);
        expect(restored.startDate, original.startDate);
        expect(restored.endDate, original.endDate);
        expect(restored.prescribedBy, original.prescribedBy);
        expect(restored.notes, original.notes);
        expect(restored.status, original.status);
      });
    });

    group('copyWith', () {
      test('copyWith modifica campos específicos', () {
        final med = MedicationModel(
          patientId: testPatientId,
          name: 'Paracetamol',
          dosage: 500,
          frequency: 'C/8h',
          startDate: testStartDate,
          prescribedBy: 'Dr. García',
        );

        final copied = med.copyWith(
          dosage: 1000,
          status: MedicationStatus.discontinued,
        );

        expect(copied.dosage, 1000);
        expect(copied.status, MedicationStatus.discontinued);
        expect(copied.name, med.name);
        expect(copied.patientId, med.patientId);
      });
    });

    test('equality basada en id', () {
      final med1 = MedicationModel(
        patientId: testPatientId,
        id: 'same-id',
        name: 'Test',
        dosage: 500,
        frequency: 'C/8h',
        startDate: testStartDate,
        prescribedBy: 'Dr. Test',
      );

      final med2 = MedicationModel(
        patientId: testPatientId,
        id: 'same-id',
        name: 'Otro nombre',
        dosage: 500,
        frequency: 'C/8h',
        startDate: testStartDate,
        prescribedBy: 'Dr. Test',
      );

      expect(med1 == med2, true);
      expect(med1.hashCode, med2.hashCode);
    });
  });
}
