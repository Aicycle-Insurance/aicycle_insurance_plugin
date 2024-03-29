import 'dart:math';

import 'package:aicycle_insurance/aicycle_insurance.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';

class ProgressDialog {
  static show(BuildContext context, {bool isLandScape = false}) {
    showDialog(
      context: context,
      builder: (context) => RotatedBox(
        quarterTurns: isLandScape ? 1 : 0,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            StringKeys.isProcessing,
            style: TextStyle(color: DefaultColors.ink500, fontSize: 14),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          content: const LinearProgressIndicator(
            backgroundColor: DefaultColors.primaryA100,
            minHeight: 4,
            valueColor: AlwaysStoppedAnimation<Color>(DefaultColors.green400),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 24),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static showWithCircleIndicator(BuildContext context,
      {bool isLandScape = false}) {
    var _random = Random();
    var i = _random.nextInt(7);
    showDialog(
      context: context,
      builder: (context) => RotatedBox(
        quarterTurns: isLandScape ? 1 : 0,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            StringKeys.isProcessing,
            style: TextStyle(color: DefaultColors.ink500, fontSize: 14),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          // alignment: Alignment.center,
          titlePadding: const EdgeInsets.only(top: 24, bottom: 0),
          actions: [
            Center(
              child: SizedBox(
                height: 72,
                child: Image.asset(
                  'assets/icons/loading_$i.gif',
                  fit: BoxFit.cover,
                  height: 72,
                  package: packageName,
                ),
              ),
            )
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static hide(BuildContext context) {
    Navigator.pop(context);
  }
}
