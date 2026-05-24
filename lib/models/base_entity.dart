import 'package:uuid/uuid.dart';

const _uuid = Uuid();

abstract class BaseEntity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaseEntity({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}

abstract class BaseModel<T> {
  T toEntity();
  Map<String, dynamic> toJson();
}
