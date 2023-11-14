import 'package:flutter/material.dart';

class NoOverflowCrossfade extends StatelessWidget {
  final Widget _firstChild;
  final Widget _secondChild;
  final Duration _duration;
  final CrossFadeState _crossFadeState;

  const NoOverflowCrossfade(
      {Key? key,
      required Widget firstChild,
      required Widget secondChild,
      required Duration duration,
      required CrossFadeState crossFadeState})
      : _firstChild = firstChild,
        _secondChild = secondChild,
        _duration = duration,
        _crossFadeState = crossFadeState,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: _firstChild,
        secondChild: _secondChild,
        crossFadeState: _crossFadeState,
        duration: _duration,
        layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
          return Stack(
              clipBehavior: Clip.antiAlias,
              // Align the non-positioned child to center.
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  key: bottomChildKey,
                  // Instead of forcing the positioned child to a width
                  // with left / right, just stick it to the top.
                  top: 0,
                  child: bottomChild,
                ),
                Positioned(
                  key: topChildKey,
                  child: topChild,
                ),
              ]);
        });
  }
}
