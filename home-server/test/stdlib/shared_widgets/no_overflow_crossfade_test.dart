import 'package:fe/stdlib/shared_widgets/no_overflow_crossfade.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('should transition between two widgets with no overflow',
      (tester) async {
    final widgetOne = Container(
      color: Colors.blue,
      height: 100,
      width: 400,
    );

    const widgetTwoKey = ValueKey('hi');
    final widgetTwo = Container(
      key: widgetTwoKey,
      color: Colors.green,
      height: 400,
      width: 100,
    );

    const switchStateKey = ValueKey('asdasd');

    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => ValueNotifier(CrossFadeState.showFirst),
      child: Builder(
          builder: (context) => GestureDetector(
                key: switchStateKey,
                onTap: () => context
                    .read<ValueNotifier<CrossFadeState>>()
                    .value = CrossFadeState.showSecond,
                child: NoOverflowCrossfade(
                  crossFadeState:
                      context.watch<ValueNotifier<CrossFadeState>>().value,
                  firstChild: widgetOne,
                  secondChild: widgetTwo,
                  duration: const Duration(milliseconds: 100),
                ),
              )),
    ));

    await tester.tap(find.byKey(switchStateKey).first);
    await tester.pumpAndSettle();
    expect(find.byKey(widgetTwoKey), findsOneWidget,
        reason: 'should not cause an error');
  });
}
