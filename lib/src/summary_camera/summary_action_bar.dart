import 'dart:io';

import '../../src/constants/colors.dart';
import '../../types/summary_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SummaryActionBar extends StatelessWidget {
  const SummaryActionBar({
    Key key,
    this.flashMode,
    this.networkImages,
    this.onTakePicture,
  }) : super(key: key);

  final barHeight = 108.0;

  final ValueNotifier<CameraFlashes> flashMode;
  final RxList<SummaryImage> networkImages;
  final Function() onTakePicture;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ValueListenableBuilder<CameraFlashes>(
              valueListenable: flashMode,
              builder: (context, value, child) {
                return CupertinoButton(
                  padding: const EdgeInsets.only(left: 16.0),
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
                    child: Icon(
                      value == CameraFlashes.NONE
                          ? Icons.flash_off
                          : Icons.flash_on,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  onPressed: _switchFlashMode,
                );
              }),
          Center(
            child: CupertinoButton(
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              onPressed: onTakePicture,
            ),
          ),
          Obx(
            () {
              return Container(
                height: 60,
                width: 60,
                margin: const EdgeInsets.only(right: 16.0),
                child: networkImages.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          // => controller.onPreviewImageTapped(context)
                        },
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: networkImages.isNotEmpty &&
                                      networkImages.last.localFilePath !=
                                          null &&
                                      networkImages
                                          .last.localFilePath.isNotEmpty
                                  ? Image.file(
                                      File(networkImages.last.localFilePath),
                                      fit: BoxFit.cover,
                                    )
                                  : networkImages.isNotEmpty &&
                                          networkImages.last.url != null &&
                                          networkImages.last.url.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: networkImages.last.url)
                                      : const SizedBox(),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: Text(
                                  networkImages.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _switchFlashMode() {
    if (flashMode.value == CameraFlashes.NONE) {
      flashMode.value = CameraFlashes.ON;
    } else {
      flashMode.value = CameraFlashes.NONE;
    }
  }
}
