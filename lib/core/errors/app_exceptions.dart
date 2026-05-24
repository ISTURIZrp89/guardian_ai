sealed class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.stackTrace});
}

class EncryptionException extends AppException {
  EncryptionException(super.message, {super.code, super.stackTrace});
}

class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code, super.stackTrace});
}

class BiometricException extends AppException {
  BiometricException(super.message, {super.code, super.stackTrace});
}

class AiException extends AppException {
  AiException(super.message, {super.code, super.stackTrace});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.stackTrace});
}

class CalculationException extends AppException {
  CalculationException(super.message, {super.code, super.stackTrace});
}

class ExportException extends AppException {
  ExportException(super.message, {super.code, super.stackTrace});
}

class StorageException extends AppException {
  StorageException(super.message, {super.code, super.stackTrace});
}

class SessionException extends AppException {
  SessionException(super.message, {super.code, super.stackTrace});
}

class PermissionException extends AppException {
  PermissionException(super.message, {super.code, super.stackTrace});
}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code, super.stackTrace});
}
