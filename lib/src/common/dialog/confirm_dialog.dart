import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class ConfirmDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String content,
    required String cancelButtonLabel,
    required String confirmButtonLabel,
  }) async {
    final androidAlert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Text(
        content,
        style: const TextStyle(color: DefaultColors.ink500, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelButtonLabel,
            style: const TextStyle(color: DefaultColors.blue, fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmButtonLabel,
            style: const TextStyle(color: DefaultColors.blue, fontSize: 16),
          ),
        ),
      ],
    );
    final iosAlert = CupertinoAlertDialog(
      content: Text(
        content,
        style: const TextStyle(color: DefaultColors.ink500, fontSize: 16),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelButtonLabel,
            style: const TextStyle(color: DefaultColors.blue, fontSize: 16),
          ),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmButtonLabel,
            style: const TextStyle(color: DefaultColors.blue, fontSize: 16),
          ),
        ),
      ],
    );

    return await showDialog(
      context: context,
      builder: (context) => Platform.isAndroid ? androidAlert : iosAlert,
    );
  }
}
