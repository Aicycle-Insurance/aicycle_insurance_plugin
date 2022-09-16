import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../src/constants/colors.dart';
import '../../../src/constants/strings.dart';
import '../../../src/utils/string_utils.dart';

class DamageResultBottomBar extends StatelessWidget {
  const DamageResultBottomBar({
    Key key,
    this.totalCost,
    this.onAddMoreImage,
    this.onSubmited,
  }) : super(key: key);
  final double totalCost;
  final Function() onAddMoreImage;
  final Function() onSubmited;

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
                  Text(
                    StringKeys.totalPrice,
                    style: TextStyle(fontSize: 14, color: DefaultColors.ink400),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _totalCost())
                ],
              ),
            ),
            Divider(
              thickness: 1,
              height: 1,
              color: DefaultColors.ink100,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _totalCost() {
    String _totalCost =
        StringUtils.formatPriceNumber(double.parse(totalCost.toString())) +
            ' đ';
    return Row(
      children: [
        const SizedBox(
          width: 16,
        ),
        Text(
          _totalCost,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DefaultColors.ink500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
