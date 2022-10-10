import 'package:aicycle_insurance_non_null_safety/src/common/button/common_button.dart';
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
                    child: CommonButton.text(
                      StringKeys.addImage,
                      color: DefaultColors.primaryA200,
                      textColor: DefaultColors.primaryA500,
                      onPressed: onAddMoreImage,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (disableSaveButton == false)
                    Expanded(
                      child: CommonButton.text(
                        StringKeys.submitResult,
                        color: DefaultColors.primaryA500,
                        textColor: Colors.white,
                        onPressed: onSubmited,
                      ),
                    ),
                  if (disableSaveButton == true)
                    Expanded(
                      child: CommonButton.text(
                        'Kiểm tra hồ sơ',
                        color: DefaultColors.primaryA500,
                        textColor: Colors.white,
                        onPressed: onChecked,
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
