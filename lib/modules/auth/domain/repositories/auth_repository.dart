abstract class AuthRepository {
  Future<bool> isFirstTime();
  Future<bool> hasPin();
  Future<bool> isBiometricAvailable();
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> authenticateBiometric();
  Future<void> lock();
  Future<bool> isLocked();
  Future<int> getRemainingAttempts();
  Future<void> resetAttempts();
  Future<void> clearAll();
}
