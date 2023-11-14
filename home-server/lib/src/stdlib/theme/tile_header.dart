import 'package:flutter/material.dart';

class TileHeader extends StatelessWidget {
  final String? _text;

  const TileHeader({String? text}) : _text = text;

  @override
  Widget build(BuildContext context) {
    if (_text != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
        child: Container(
          width: double.infinity,
          child: Text(
            _text!.toUpperCase(),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: 'IBM Plex Mono', color: Colors.grey.shade700),
          ),
        ),
      );
    } else {
      return Container(
        height: 20,
      );
    }
  }
}
