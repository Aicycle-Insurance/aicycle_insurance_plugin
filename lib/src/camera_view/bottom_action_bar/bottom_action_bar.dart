import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../camera_view/camera_argument.dart';
import '../../constants/colors.dart';
import '../../../types/image.dart';
import '../../../types/part_direction.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    Key? key,
    required this.previewFile,
    required this.currentTabIndex,
    required this.currentArg,
    required this.flashMode,
    required this.onTakePicture,
  }) : super(key: key);

  final barHeight = 108.0;

  final Rx<XFile?> previewFile;
  final RxInt currentTabIndex;
  final Rx<CameraArgument> currentArg;
  final ValueNotifier<CameraFlashes> flashMode;
  final Function()? onTakePicture;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (previewFile.value == null) ...[
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
                        border:
                            Border.all(width: 1, color: DefaultColors.ink100),
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
                var imageFileList = <XFileWithId>[];
                var imageNetworkList = <AiImage>[];
                switch (currentTabIndex.value) {
                  case 0:
                    imageFileList.assignAll(
                        currentArg.value.partDirection.overViewImageFiles);
                    imageNetworkList.assignAll(
                        currentArg.value.partDirection.overViewImages);
                    break;
                  case 1:
                    imageFileList.assignAll(
                        currentArg.value.partDirection.middleViewImageFiles);
                    imageNetworkList.assignAll(
                        currentArg.value.partDirection.middleViewImages);
                    break;
                  case 2:
                    imageFileList.assignAll(
                        currentArg.value.partDirection.closeViewImageFiles);
                    imageNetworkList.assignAll(
                        currentArg.value.partDirection.closeViewImages);
                    break;
                }
                return Container(
                  height: 60,
                  width: 60,
                  margin: const EdgeInsets.only(right: 16.0),
                  child: imageFileList.length + imageNetworkList.length != 0
                      ? GestureDetector(
                          onTap: () {
                            // => controller.onPreviewImageTapped(context)
                          },
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: imageFileList.isNotEmpty
                                    ? Image.file(
                                        File(imageFileList.last.file.path),
                                        fit: BoxFit.cover,
                                      )
                                    : imageNetworkList.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: imageNetworkList.last.url)
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
                                    (imageFileList.length +
                                            imageNetworkList.length)
                                        .toString(),
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
          ]
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
