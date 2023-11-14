import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onClick;

  const PillButton(
      {required this.text, required this.icon, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              Icon(
                icon,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
