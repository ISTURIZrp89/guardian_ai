import '../../domain/usecases/check_auth_status.dart';

extension AuthStatusX on AuthStatus {
  bool get isFirstTime => this == AuthStatus.firstTime;
  bool get isLocked => this == AuthStatus.locked;
  bool get hasPin => this == AuthStatus.hasPin;
  bool get isAuthenticated => this == AuthStatus.authenticated;

  String get label {
    switch (this) {
      case AuthStatus.firstTime:
        return 'Primer inicio';
      case AuthStatus.hasPin:
        return 'PIN configurado';
      case AuthStatus.locked:
        return 'Bloqueado';
      case AuthStatus.authenticated:
        return 'Autenticado';
    }
  }

  String get route {
    switch (this) {
      case AuthStatus.firstTime:
        return '/pin-setup';
      case AuthStatus.hasPin:
        return '/unlock';
      case AuthStatus.locked:
        return '/unlock';
      case AuthStatus.authenticated:
        return '/ai';
    }
  }
}
