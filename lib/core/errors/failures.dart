sealed class Failure {
  final String message;
  final String? code;

  Failure(this.message, {this.code});
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message, {super.code});
}

class EncryptionFailure extends Failure {
  EncryptionFailure(super.message, {super.code});
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure(super.message, {super.code});
}

class BiometricFailure extends Failure {
  BiometricFailure(super.message, {super.code});
}

class AiFailure extends Failure {
  AiFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message, {super.code});
}

class CalculationFailure extends Failure {
  CalculationFailure(super.message, {super.code});
}

class ExportFailure extends Failure {
  ExportFailure(super.message, {super.code});
}

class StorageFailure extends Failure {
  StorageFailure(super.message, {super.code});
}

class SessionFailure extends Failure {
  SessionFailure(super.message, {super.code});
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message, {super.code});
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure(super.message, {super.code});
}
