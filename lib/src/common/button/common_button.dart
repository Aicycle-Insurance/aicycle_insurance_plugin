import 'package:flutter/cupertino.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    Key key,
    this.text,
    this.color,
    this.textColor,
    this.onPressed,
    this.child,
  }) : super(key: key);
  final String text;
  final Color color;
  final Color textColor;
  final Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      borderRadius: BorderRadius.circular(8),
      color: color,
      child: child != null
          ? child
          : Text(
              text,
              style: TextStyle(color: textColor),
            ),
      onPressed: onPressed,
    );
  }

  factory CommonButton.text(
    String text, {
    Color color,
    Color textColor,
    Function() onPressed,
  }) =>
      CommonButton(
        text: text,
        color: color,
        textColor: textColor,
        onPressed: onPressed,
      );
}
