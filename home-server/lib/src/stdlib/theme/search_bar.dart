import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// updated ios_search_bar package!
class SearchBar extends AnimatedWidget {
  const SearchBar({
    Key? key,
    required this.animation,
    required this.controller,
    required this.focusNode,
    required this.onCancel,
    required this.text,
    this.onClear,
    this.onSubmit,
    this.onUpdate,
  }) : super(key: key, listenable: animation);

  final String text;

  final Animation<double> animation;

  /// The text editing controller to control the search field
  final TextEditingController controller;

  /// The focus node needed to manually unfocus on clear/cancel
  final FocusNode focusNode;

  /// The function to call when the "Cancel" button is pressed
  final void Function()? onCancel;

  /// The function to call when the "Clear" button is pressed
  final void Function()? onClear;

  /// The function to call when the text is updated
  final Function(String)? onUpdate;

  /// The function to call when the text field is submitted
  final Function(String)? onSubmit;

  static final _opacityTween = Tween(begin: 1.0, end: 0.0);
  static final _paddingTween = Tween(begin: 0.0, end: 60.0);
  static const _kFontSize = 13.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                border: Border.all(width: 0.0, color: CupertinoColors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                        color: CupertinoColors.systemGroupedBackground,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 1.0),
                            child: Icon(
                              CupertinoIcons.search,
                              color: CupertinoColors.inactiveGray,
                              size: _kFontSize + 2.0,
                            ),
                          ),
                          Text(
                            text,
                            style: TextStyle(
                              inherit: false,
                              color: CupertinoColors.inactiveGray.withOpacity(
                                  _opacityTween.evaluate(animation)),
                              fontSize: _kFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: EditableText(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: onUpdate,
                            onSubmitted: onSubmit,
                            style: const TextStyle(
                              color: CupertinoColors.black,
                              inherit: false,
                              fontSize: _kFontSize,
                            ),
                            cursorColor: CupertinoColors.black,
                            backgroundCursorColor: CupertinoColors.inactiveGray,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CupertinoButton(
                          minSize: 10.0,
                          padding: const EdgeInsets.all(1.0),
                          borderRadius: BorderRadius.circular(30.0),
                          color: CupertinoColors.inactiveGray.withOpacity(
                            1.0 - _opacityTween.evaluate(animation),
                          ),
                          onPressed: () {
                            if (animation.isDismissed) {
                              return;
                            } else if (onClear != null) {
                              onClear!();
                            }
                          },
                          child: const Icon(
                            Icons.close,
                            size: 8.0,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _paddingTween.evaluate(animation),
            child: CupertinoButton(
              padding: const EdgeInsets.only(left: 8.0),
              onPressed: onCancel,
              child: Text(
                'Cancel',
                softWrap: false,
                style: TextStyle(
                  inherit: false,
                  color: Theme.of(context).primaryColor,
                  fontSize: _kFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
