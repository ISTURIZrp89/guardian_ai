import '../repositories/auth_repository.dart';

enum AuthStatus { firstTime, hasPin, locked, authenticated }

class CheckAuthStatus {
  final AuthRepository _repository;

  CheckAuthStatus(this._repository);

  Future<AuthStatus> call() async {
    final isFirstTime = await _repository.isFirstTime();
    if (isFirstTime) return AuthStatus.firstTime;

    final isLocked = await _repository.isLocked();
    if (isLocked) return AuthStatus.locked;

    final hasPin = await _repository.hasPin();
    if (!hasPin) return AuthStatus.firstTime;

    return AuthStatus.hasPin;
  }
}
