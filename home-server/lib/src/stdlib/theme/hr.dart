import 'package:flutter/cupertino.dart';

class Hr extends StatelessWidget {
  final Color color;

  const Hr({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: double.infinity,
      color: color,
    );
  }
}
