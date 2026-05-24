import '../../../../core/errors/app_exceptions.dart';
import '../entities/pin_code.dart';
import '../repositories/auth_repository.dart';

class SetupPin {
  final AuthRepository _repository;

  SetupPin(this._repository);

  Future<void> call(String pin) async {
    final pinCode = PinCode.create(pin);
    if (pinCode == null) {
      throw ValidationException('El PIN debe tener 6 dígitos');
    }

    try {
      await _repository.setPin(pinCode.value);
    } catch (e) {
      throw EncryptionException('Error al guardar el PIN');
    }
  }
}
