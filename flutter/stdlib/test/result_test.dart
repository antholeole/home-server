
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
    expect(ran, valueV);
  }); 

  test("on value should not run on error", () {
    String? ran;
    
    value.onErr((s) => ran = s);
    expect(ran, null);
  }); 

  test("on error should run on err", () {
    final vc = VoidCapture();

    err.onErr(vc.runA);

    expect(vc.didRun, true);
  });

  test("on error should run on err", () {
    final vc = VoidCapture();

    value.onErr(vc.runA);

    expect(vc.didRun, false);
  });

  test("tap should call f", () {
    final vc = VoidCapture();
    
    value.tap(vc.runA);

    expect(vc.didRun, true);
  }); 

  test("tap should call f", () {
    final vc = VoidCapture();
    
    value.tap(vc.runA);

    expect(vc.didRun, true);
  }); 
}