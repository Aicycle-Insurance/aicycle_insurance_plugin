import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../src/constants/colors.dart';
import '../../../src/constants/strings.dart';
// import '../../../src/utils/string_utils.dart';

class DamageResultBottomBar extends StatelessWidget {
  const DamageResultBottomBar({
    Key key,
    this.totalCost,
    this.onAddMoreImage,
    this.onSubmited,
    this.onChecked,
    this.disableSaveButton,
  }) : super(key: key);
  final double totalCost;
  final Function() onAddMoreImage;
  final Function() onSubmited;
  final Function() onChecked;
  final bool disableSaveButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 7,
            offset: Offset(0, 3),
            color: DefaultColors.shadowColor,
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: DefaultColors.primaryA200,
                      child: Text(
                        StringKeys.addImage,
                        style: TextStyle(
                          fontSize: 14,
                          color: DefaultColors.primaryA500,
                        ),
                      ),
                      onPressed: onAddMoreImage,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (disableSaveButton == false)
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: DefaultColors.primaryA500,
                        child: Text(
                          StringKeys.submitResult,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: onSubmited,
                      ),
                    ),
                  if (disableSaveButton == true)
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: DefaultColors.primaryA500,
                        child: Text(
                          'Kiểm tra hồ sơ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: onChecked ?? () {},
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
