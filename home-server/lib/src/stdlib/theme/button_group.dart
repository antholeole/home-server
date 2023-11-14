import 'package:fe/stdlib/theme/tile_header.dart';
import 'package:flutter/material.dart';

import 'loadable_tile_button.dart';

class ButtonGroup extends StatelessWidget {
  final String? _name;
  final List<LoadableTileButton> _buttons;

  const ButtonGroup({String? name, required List<LoadableTileButton> buttons})
      : _name = name,
        _buttons = buttons;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TileHeader(
          text: _name,
        ),
        ..._buttons
      ],
    );
  }
}
