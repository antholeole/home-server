import 'package:fe/stdlib/helpers/size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sizes = [
    Size(10, 20),
    Size(37, 15),
    Size(9, 120),
    Size(8, 20),
    Size(12.2, 400.1),
    Size(8, 15),
    Size(12.0, 85.2),
  ];

  for (final size in sizes) {
    testWidgets('size provider should match $size', (tester) async {
      late Size gottenSize;

      await tester.pumpWidget(Center(
        child: SizeProvider(
          onChildSize: (gotten) => gottenSize = gotten,
          child: Container(
            width: size.width,
            height: size.height,
          ),
        ),
      ));

      tester.binding.scheduleFrame();
      await tester.pump();

      expect(gottenSize, equals(size));
    });
  }
}
