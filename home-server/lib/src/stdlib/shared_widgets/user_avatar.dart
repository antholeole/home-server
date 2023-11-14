import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  late final String _initals;
  final String? _profileUrl;
  final double? _radius;

  UserAvatar({required String name, String? profileUrl, double? radius})
      : _radius = radius,
        _profileUrl = profileUrl {
    _initals = name.split(' ').map((e) {
      if (e.isNotEmpty) {
        return e[0];
      } else {
        return '';
      }
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      maxRadius: _radius,
      minRadius: _radius,
      foregroundImage: _profileUrl != null ? NetworkImage(_profileUrl!) : null,
      child: _profileUrl == null
          ? Text(
              _initals,
              style: TextStyle(fontSize: _radius != null ? _radius! / 2 : null),
            )
          : null,
    );
  }
}
