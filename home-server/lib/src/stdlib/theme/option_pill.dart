import 'package:flutter/material.dart';

class OptionPill extends StatelessWidget {
  final int _total;
  final int _current;

  final double _dotSize = 8;

  const OptionPill({required int total, required int current})
      : _total = total,
        _current = current,
        assert(current >= 0),
        assert(current < total);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildDots(),
      ),
    );
  }

  Widget _buildDots() {
    List<Widget> dots = [];

    for (int i = 0; i < _total; i++) {
      Color color;
      if (i == _current) {
        color = Colors.white;
      } else {
        color = Colors.grey.shade600;
      }

      dots.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: dots,
    );
  }
}
