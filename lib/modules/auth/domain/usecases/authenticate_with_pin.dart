import '../../../../core/errors/app_exceptions.dart';
import '../repositories/auth_repository.dart';

class AuthenticateWithPin {
  final AuthRepository _repository;

  AuthenticateWithPin(this._repository);

  Future<bool> call(String pin) async {
    final isLocked = await _repository.isLocked();
    if (isLocked) {
      throw AuthenticationException('Cuenta bloqueada temporalmente');
    }

    final isValid = await _repository.verifyPin(pin);
    if (isValid) {
      await _repository.resetAttempts();
      return true;
    }

    final remaining = await _repository.getRemainingAttempts();
    if (remaining <= 0) {
      await _repository.lock();
      throw AuthenticationException('Cuenta bloqueada por 15 minutos');
    }

    throw AuthenticationException(
      'PIN incorrecto. Intentos restantes: $remaining',
    );
  }
}
