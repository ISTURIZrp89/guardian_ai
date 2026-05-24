import '../../../../core/errors/app_exceptions.dart';
import '../repositories/auth_repository.dart';

class AuthenticateWithBiometrics {
  final AuthRepository _repository;

  AuthenticateWithBiometrics(this._repository);

  Future<bool> call() async {
    final available = await _repository.isBiometricAvailable();
    if (!available) {
      throw BiometricException('Biometría no disponible');
    }

    final result = await _repository.authenticateBiometric();
    if (!result) {
      throw BiometricException('Autenticación biométrica fallida');
    }

    await _repository.resetAttempts();
    return true;
  }
}
