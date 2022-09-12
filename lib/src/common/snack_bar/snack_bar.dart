import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

enum SnackbarType { informative, success, error, warning }
const textColor = Colors.white;

class CommonSnackbar {
  static show(
    BuildContext context, {
    SnackbarType type,
    String message,
  }) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: _chooseColor(type),
      duration: const Duration(seconds: 2),
      // margin: EdgeInsets.symmetric(horizontal: 16),
      // borderRadius: 8,
      messageText: Row(
        children: [
          Icon(_chooseIcon(type), color: textColor),
          SizedBox(width: 8),
          Text(
            '${_chooseTitle(type)}: $message',
            style: const TextStyle(color: textColor),
          ),
        ],
      ),
    )..show(context);
  }

  static String _chooseTitle(SnackbarType type) {
    if (type == SnackbarType.success) {
      return "Success";
    } else if (type == SnackbarType.error) {
      return "Error";
    } else if (type == SnackbarType.informative) {
      return 'Informative';
    } else {
      return "Warning";
    }
  }

  static Color _chooseColor(SnackbarType type) {
    if (type == SnackbarType.success) {
      return DefaultColors.green400;
    } else if (type == SnackbarType.error) {
      return DefaultColors.red;
    } else if (type == SnackbarType.informative) {
      return DefaultColors.blue;
    } else {
      return DefaultColors.orange;
    }
  }

  static IconData _chooseIcon(SnackbarType type) {
    if (type == SnackbarType.success) {
      return Icons.check_circle_outline;
    } else if (type == SnackbarType.error) {
      return Icons.error_outline;
    } else if (type == SnackbarType.informative) {
      return Icons.info_outline_rounded;
    } else {
      return Icons.warning_amber_outlined;
    }
  }

  static SnackBar snackBarWidget({
    SnackbarType type,
    String message,
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(_chooseIcon(type), color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_chooseTitle(type)}: $message',
              style: const TextStyle(color: textColor),
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: _chooseColor(type),
    );
  }
}
