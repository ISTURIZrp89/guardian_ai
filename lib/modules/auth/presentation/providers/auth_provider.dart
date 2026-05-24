import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/authenticate_with_biometrics.dart';
import '../../domain/usecases/authenticate_with_pin.dart';
import '../../domain/usecases/check_auth_status.dart' as status;
import '../../domain/usecases/setup_pin.dart';

enum AppAuthStatus { uninitialized, firstTime, hasPin, locked, authenticated }

class AuthState {
  final AppAuthStatus status;
  final bool isLoading;
  final String? errorMessage;
  final int remainingAttempts;
  final DateTime? lockedUntil;

  const AuthState({
    this.status = AppAuthStatus.uninitialized,
    this.isLoading = false,
    this.errorMessage,
    this.remainingAttempts = 5,
    this.lockedUntil,
  });

  AuthState copyWith({
    AppAuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    int? remainingAttempts,
    DateTime? lockedUntil,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = AuthLocalDataSource();
  return AuthRepositoryImpl(dataSource);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  late final status.CheckAuthStatus _checkAuthStatus;
  late final AuthenticateWithPin _authenticateWithPin;
  late final AuthenticateWithBiometrics _authenticateWithBiometrics;
  late final SetupPin _setupPin;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkAuthStatus = status.CheckAuthStatus(_repository);
    _authenticateWithPin = AuthenticateWithPin(_repository);
    _authenticateWithBiometrics = AuthenticateWithBiometrics(_repository);
    _setupPin = SetupPin(_repository);
  }

  Future<AppAuthStatus> checkStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _checkAuthStatus.call();
      final mapped = _mapStatus(result);
      state = state.copyWith(status: mapped, isLoading: false);
      return mapped;
    } catch (_) {
      state = state.copyWith(
        status: AppAuthStatus.firstTime,
        isLoading: false,
        errorMessage: 'Error al verificar estado',
      );
      return AppAuthStatus.firstTime;
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authenticateWithPin.call(pin);
      state = state.copyWith(
        status: AppAuthStatus.authenticated,
        isLoading: false,
        remainingAttempts: 5,
      );
      return true;
    } on AuthenticationException catch (_) {
      final remaining = await _repository.getRemainingAttempts();
      final isLocked = await _repository.isLocked();
      state = state.copyWith(
        isLoading: false,
        errorMessage: isLocked
            ? 'Cuenta bloqueada por 15 minutos'
            : 'PIN incorrecto. Intentos restantes: $remaining',
        remainingAttempts: remaining,
        status: isLocked ? AppAuthStatus.locked : state.status,
        lockedUntil: isLocked
            ? DateTime.now().add(const Duration(minutes: 15))
            : null,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error inesperado',
      );
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authenticateWithBiometrics.call();
      state = state.copyWith(
        status: AppAuthStatus.authenticated,
        isLoading: false,
      );
      return true;
    } on BiometricException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error biométrico',
      );
      return false;
    }
  }

  Future<bool> setupPin(String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _setupPin.call(pin);
      state = state.copyWith(
        status: AppAuthStatus.authenticated,
        isLoading: false,
        remainingAttempts: 5,
      );
      return true;
    } on ValidationException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } on EncryptionException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al configurar PIN',
      );
      return false;
    }
  }

  Future<void> lock() async {
    await _repository.lock();
    state = state.copyWith(
      status: AppAuthStatus.locked,
      lockedUntil: DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  Future<void> clearSession() async {
    await _repository.clearAll();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  AppAuthStatus _mapStatus(status.AuthStatus domainStatus) {
    switch (domainStatus) {
      case status.AuthStatus.firstTime:
        return AppAuthStatus.firstTime;
      case status.AuthStatus.hasPin:
        return AppAuthStatus.hasPin;
      case status.AuthStatus.locked:
        return AppAuthStatus.locked;
      case status.AuthStatus.authenticated:
        return AppAuthStatus.authenticated;
    }
  }
}
