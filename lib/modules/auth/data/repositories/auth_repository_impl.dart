import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<bool> isFirstTime() async {
    try {
      return await _dataSource.isFirstTime();
    } catch (e) {
      throw StorageFailure('Error al verificar primer uso');
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      return await _dataSource.hasPin();
    } catch (e) {
      throw StorageFailure('Error al verificar PIN existente');
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      return await _dataSource.isBiometricAvailable();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setPin(String pin) async {
    try {
      await _dataSource.savePin(pin);
    } catch (e) {
      throw EncryptionFailure('Error al guardar el PIN');
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final isValid = await _dataSource.verifyPin(pin);
      if (!isValid) {
        final remaining = await _dataSource.getRemainingAttempts();
        await _dataSource.saveRemainingAttempts(remaining - 1);
      }
      return isValid;
    } catch (e) {
      throw AuthenticationFailure('Error al verificar PIN');
    }
  }

  @override
  Future<bool> authenticateBiometric() async {
    try {
      return await _dataSource.authenticateBiometric();
    } catch (e) {
      throw BiometricFailure('Error al autenticar con biometría');
    }
  }

  @override
  Future<void> lock() async {
    try {
      final lockedUntil = DateTime.now().add(
        const Duration(minutes: 15),
      );
      await _dataSource.saveLockedUntil(lockedUntil);
      await _dataSource.saveRemainingAttempts(0);
    } catch (e) {
      throw SessionFailure('Error al bloquear la cuenta');
    }
  }

  @override
  Future<bool> isLocked() async {
    try {
      return await _dataSource.isLocked();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getRemainingAttempts() async {
    try {
      return await _dataSource.getRemainingAttempts();
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> resetAttempts() async {
    try {
      await _dataSource.resetRemainingAttempts();
    } catch (e) {
      throw StorageFailure('Error al reiniciar intentos');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _dataSource.clearAll();
    } catch (e) {
      throw StorageFailure('Error al limpiar datos');
    }
  }
}
