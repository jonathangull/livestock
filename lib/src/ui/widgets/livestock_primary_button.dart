import 'package:flutter/material.dart';
import 'package:livestock/src/ui/theming.dart';

class LivestockPrimaryButton extends StatelessWidget {
  final Icon _icon;
  final VoidCallback _onPressed;
  final String _text;

  LivestockPrimaryButton({
    Key key,
    Icon icon,
    String text,
    VoidCallback onPressed,
  })  : _icon = icon,
        _text = text,
        _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final label = Text(
      _text.toUpperCase(),
      style: Theme.of(context).textTheme.button.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
      textAlign: TextAlign.center,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    );

    final button = _icon != null
        ? RaisedButton.icon(
            shape: shape,
            onPressed: _onPressed,
            label: label,
            icon: _icon,
            color: kPrimaryColor,
          )
        : RaisedButton(
            shape: shape,
            onPressed: _onPressed,
            child: label,
            color: kPrimaryColor,
          );

    return SizedBox(
      child: button,
      height: 52,
    );
  }
}
