import 'package:fe/stdlib/theme/tile.dart';
import 'package:flutter/material.dart';

import 'loader.dart';

class LoadableTileButton extends StatelessWidget {
  final void Function() onClick;
  final String text;
  final Color color;
  final bool loading;

  const LoadableTileButton(
      {required this.text,
      this.color = Colors.grey,
      required this.onClick,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Tile(
        child: TextButton(
      onPressed: loading ? () {} : onClick,
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading
            ? const Loader(size: 12)
            : Text(
                text,
                style: TextStyle(color: color),
              ),
      ),
    ));
  }
}
