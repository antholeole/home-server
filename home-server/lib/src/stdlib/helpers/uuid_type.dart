import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:built_value/serializer.dart';

class UuidType extends Equatable {
  final String _uuid;

  UuidType(String uuid)
      : assert(_assertUuidIsValid(uuid)),
        _uuid = uuid;

  String get uuid => _uuid;

  static UuidType generate() {
    return UuidType(const Uuid().v4());
  }

  static bool _assertUuidIsValid(String uuid) {
    try {
      Uuid.parse(uuid);
      return true;
    } on FormatException catch (_) {
      return false;
    }
  }

  @override
  String toString() {
    return _uuid;
  }

  @override
  bool operator ==(covariant UuidType other) => other.uuid == uuid;

  @override
  List<Object> get props => [_uuid];
}

class CustomUuidConverter implements JsonConverter<UuidType, String> {
  const CustomUuidConverter();

  @override
  UuidType fromJson(String json) {
    return UuidType(json);
  }

  @override
  String toJson(UuidType json) => json.uuid;
}

class UuidTypeSerializer implements PrimitiveSerializer<UuidType> {
  @override
  UuidType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    assert(serialized is String,
        "UuidTypeSerializer expected 'String' but got ${serialized.runtimeType}");
    return UuidType(serialized as String);
  }

  @override
  Object serialize(
    Serializers serializers,
    UuidType uuidType, {
    FullType specifiedType = FullType.unspecified,
  }) =>
      uuidType.uuid;

  @override
  Iterable<Type> get types => [UuidType];

  @override
  String get wireName => 'uuid';
}
