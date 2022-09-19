import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

enum NotiType { success, error, warning, informative }

class NotificationDialog {
  static Future<bool> show(
    BuildContext context, {
    String content,
    NotiType type = NotiType.success,
    Function() confirmCallBack,
  }) async {
    // final androidAlert = AlertDialog(
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //   // title: Text(
    //   //   _chooseTitle(type),
    //   // ),
    //   title: Icon(
    //     _chooseIcon(type),
    //     color: _chooseColor(type),
    //   ),
    //   content: Text(
    //     content,
    //     style: const TextStyle(color: DefaultColors.ink500, fontSize: 16),
    //   ),
    //   actions: [
    //     TextButton(
    //       onPressed: () {
    //         Navigator.pop(context, false);
    //         if (confirmCallBack != null) {
    //           confirmCallBack();
    //         }
    //       },
    //       child: Text(
    //         _chooseButtonTitle(type),
    //         style: const TextStyle(color: DefaultColors.blue, fontSize: 16),
    //       ),
    //     ),
    //   ],
    // );
    final iosAlert = CupertinoAlertDialog(
      title: Icon(
        _chooseIcon(type),
        color: _chooseColor(type),
        size: 48,
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          content,
          style: const TextStyle(color: DefaultColors.ink500, fontSize: 16),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context, false);
            if (confirmCallBack != null) {
              confirmCallBack();
            }
          },
          child: Text(
            _chooseButtonTitle(type),
            style: const TextStyle(color: DefaultColors.blue, fontSize: 16),
          ),
        ),
      ],
    );

    return await showDialog(
      context: context,
      barrierDismissible: false,
      // builder: (context) => Platform.isAndroid ? androidAlert : iosAlert,
      builder: (context) => iosAlert,
    );
  }

  static Color _chooseColor(NotiType type) {
    switch (type) {
      case NotiType.success:
        return DefaultColors.green400;
      case NotiType.error:
        return DefaultColors.red;
      case NotiType.warning:
        return DefaultColors.orange;
      case NotiType.informative:
        return DefaultColors.blue;
      default:
        return DefaultColors.green400;
    }
  }

  static IconData _chooseIcon(NotiType type) {
    switch (type) {
      case NotiType.success:
        return Icons.check_circle_outline;
      case NotiType.error:
        return Icons.error_outline;
      case NotiType.warning:
        return Icons.warning_amber_outlined;
      case NotiType.informative:
        return Icons.info_outline_rounded;
      default:
        return Icons.check_circle_outline;
    }
  }

  static String _chooseButtonTitle(NotiType type) {
    switch (type) {
      case NotiType.success:
        return "Xác nhận";
      case NotiType.error:
        return "Tôi đã hiểu";
      case NotiType.warning:
        return "Tôi đã hiểu";
      case NotiType.informative:
        return "Đồng ý";
      default:
        return "Xác nhận";
    }
  }
}
