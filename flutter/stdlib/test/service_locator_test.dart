import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:stdlib/config.dart';
import 'package:stdlib/service_locator.dart';

class SomeFakeObject {}

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  test("more should setup more", () {
    setup(
      LocalConfig(),
      (GetIt g) {
        getIt.registerSingleton<SomeFakeObject>(SomeFakeObject());
      });

    expect(getIt<SomeFakeObject>(), isNotNull);
  });
}