import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final Widget child;

  const Tile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1))),
      child: child,
    );
  }
}
