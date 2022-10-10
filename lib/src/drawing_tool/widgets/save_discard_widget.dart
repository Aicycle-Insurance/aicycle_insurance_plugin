import '../../../src/constants/colors.dart';
import '../../../src/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SaveOrDiscardWidget extends StatelessWidget {
  const SaveOrDiscardWidget({Key key, this.onCancel, this.onSave})
      : super(key: key);
  final Function() onCancel;
  final Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white),
              ),
              child: const Text(
                StringKeys.cancel,
                style: TextStyle(color: Colors.white),
              ),
            ),
            onPressed: onCancel,
            // onPressed: () {
            //   drawStatus.value = DrawStatus.end;
            //   paintController.clearDrawables();
            //   widget.onCancelCallBack();
            // },
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                StringKeys.save,
                style: TextStyle(color: DefaultColors.blue),
              ),
            ),
            onPressed: onSave,
            // onPressed: finishAnnotate,
          ),
        ],
      ),
    );
  }
}
