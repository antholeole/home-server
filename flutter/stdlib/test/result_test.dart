
import 'package:flutter_test/flutter_test.dart';
import 'package:stdlib/result.dart';
import 'package:stdlib/test_helpers.dart';

void main() {
  const valueV = "hi";

  final value = Result.value(valueV);
  final err = Result.error(Exception("some exception"));

  test("on value should run on value", () {
    String? ran;
    value.onValue((s) => ran = s);
    expect(ran, value);
  }); 
  test("on value should not run on error", () {
    String? ran;
    
    value.onErr((s) => ran = s);
    expect(ran, null);
  }); 
}