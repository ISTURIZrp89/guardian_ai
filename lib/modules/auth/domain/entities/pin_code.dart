import 'package:equatable/equatable.dart';

class PinCode extends Equatable {
  final String value;

  const PinCode._(this.value);

  static PinCode? create(String value) {
    if (value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value)) {
      return PinCode._(value);
    }
    return null;
  }

  bool get isValid => value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value);

  @override
  List<Object> get props => [value];
}
