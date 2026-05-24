import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthLocalDataSource {
  static const _keyPinHash = 'guardian_auth_pin_hash';
  static const _keyRemainingAttempts = 'guardian_auth_remaining_attempts';
  static const _keyLockedUntil = 'guardian_auth_locked_until';
  static const _keyFirstTimeCompleted = 'guardian_auth_first_time_completed';

  static const _maxAttempts = 5;
  static const _lockoutMinutes = 15;

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  AuthLocalDataSource({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> isFirstTime() async {
    final completed = await _secureStorage.read(key: _keyFirstTimeCompleted);
    return completed == null;
  }

  Future<void> markFirstTimeCompleted() async {
    await _secureStorage.write(key: _keyFirstTimeCompleted, value: 'true');
  }

  Future<bool> hasPin() async {
    final hash = await _secureStorage.read(key: _keyPinHash);
    return hash != null && hash.isNotEmpty;
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<void> savePin(String pin) async {
    final hash = _hashPin(pin);
    await _secureStorage.write(key: _keyPinHash, value: hash);
    await markFirstTimeCompleted();
    await resetRemainingAttempts();
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _keyPinHash);
    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  Future<bool> authenticateBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Autentíquese para acceder a Guardian AI',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<int> getRemainingAttempts() async {
    final value = await _secureStorage.read(key: _keyRemainingAttempts);
    if (value == null) return _maxAttempts;
    return int.tryParse(value) ?? _maxAttempts;
  }

  Future<void> saveRemainingAttempts(int attempts) async {
    await _secureStorage.write(
      key: _keyRemainingAttempts,
      value: attempts.toString(),
    );
  }

  Future<void> resetRemainingAttempts() async {
    await _secureStorage.write(
      key: _keyRemainingAttempts,
      value: _maxAttempts.toString(),
    );
  }

  Future<bool> isLocked() async {
    final lockedUntilStr = await _secureStorage.read(key: _keyLockedUntil);
    if (lockedUntilStr == null) return false;

    final lockedUntil = DateTime.tryParse(lockedUntilStr);
    if (lockedUntil == null) return false;

    if (DateTime.now().isAfter(lockedUntil)) {
      await _clearLockout();
      return false;
    }

    return true;
  }

  Future<void> saveLockedUntil(DateTime until) async {
    await _secureStorage.write(
      key: _keyLockedUntil,
      value: until.toIso8601String(),
    );
  }

  Future<DateTime?> getLockedUntil() async {
    final value = await _secureStorage.read(key: _keyLockedUntil);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> _clearLockout() async {
    await _secureStorage.delete(key: _keyLockedUntil);
    await _secureStorage.write(
      key: _keyRemainingAttempts,
      value: _maxAttempts.toString(),
    );
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
