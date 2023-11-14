import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final bool filled;

  const Logo({this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      'club app',
      style: Theme.of(context).textTheme.headline3?.copyWith(
          color: !filled ? Colors.white : Theme.of(context).primaryColor,
          fontWeight: FontWeight.w900,
          fontFamily: 'Kontora'),
    );
  }
}
