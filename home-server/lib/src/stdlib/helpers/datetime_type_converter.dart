import 'package:built_value/serializer.dart';
import 'package:json_annotation/json_annotation.dart';

class CustomDateTimeConverter implements JsonConverter<DateTime, String> {
  const CustomDateTimeConverter();

  @override
  DateTime fromJson(String string) {
    return DateTime.parse(string);
  }

  @override
  String toJson(DateTime json) => json.toIso8601String();
}

class DateTimeSerializer implements PrimitiveSerializer<DateTime> {
  @override
  DateTime deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    assert(serialized is String,
        "Timestamptz expected 'String' but got ${serialized.runtimeType}");

    return DateTime.parse(serialized as String);
  }

  @override
  String serialize(
    Serializers serializers,
    DateTime datetime, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return datetime.toIso8601String();
  }

  @override
  Iterable<Type> get types => [DateTime];

  @override
  String get wireName => 'uuid';
}
