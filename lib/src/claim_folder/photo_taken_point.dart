import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoTakenPoint extends StatelessWidget {
  const PhotoTakenPoint({
    Key key,
    this.isTaken = false,
    this.onTap,
  }) : super(key: key);

  final double size = 24;
  final bool isTaken;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      minSize: 0,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isTaken
              ? null
              : Border.all(width: 2, color: const Color(0xFFB4B2BC)),
          color: isTaken ? const Color(0xFF4BDDA0) : const Color(0xFFF2F3F4),
        ),
        child: isTaken
            ? const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
            : null,
      ),
    );
  }
}
