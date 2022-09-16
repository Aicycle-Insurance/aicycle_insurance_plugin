import 'package:aicycle_insurance_non_null_safety/src/constants/colors.dart';
import 'package:aicycle_insurance_non_null_safety/src/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SummaryCameraPage extends StatelessWidget {
  const SummaryCameraPage({Key key}) : super(key: key);
  final double toolbarHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.black,
          leadingWidth: 0,
          toolbarHeight: toolbarHeight + MediaQuery.of(context).padding.top,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                padding: EdgeInsets.zero,
                // minSize: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      StringKeys.close.toUpperCase(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                onPressed: _onWillPop,
              ),
              Center(
                child: Text(
                  StringKeys.overView,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DefaultColors.ink100,
                    border: Border.all(width: 1, color: DefaultColors.ink100),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    CupertinoIcons.photo_on_rectangle,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
                onPressed: _galleryPicker,
              )
            ],
          ),
        ),
      ),
    );
  }

  _onWillPop() {}
  _galleryPicker() {}
}
