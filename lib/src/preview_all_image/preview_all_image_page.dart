import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../camera_view/camera_argument.dart';
import '../constants/colors.dart';
import '../preview_all_image/widgets/close_view_section.dart';
import '../../types/image.dart';
import '../../types/part_direction.dart';
import 'controller/preview_all_image_controller.dart';
import 'widgets/over_view_section.dart';

class PreviewAllImagePage extends StatefulWidget {
  const PreviewAllImagePage({
    Key key,
    this.cameraArgument,
    // this.token,
    // this.sessionId,
    // this.onError,
  }) : super(key: key);

  final CameraArgument cameraArgument;

  @override
  State<PreviewAllImagePage> createState() => _PreviewAllImagePageState();
}

class _PreviewAllImagePageState extends State<PreviewAllImagePage> {
  final _toolbarHeight = 64.0;
  PreviewAllImageController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<PreviewAllImageController>()) {
      controller = Get.find<PreviewAllImageController>();
    } else {
      controller = Get.put(PreviewAllImageController(widget.cameraArgument));
    }
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<PreviewAllImageController>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => controller.willPop(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0.0,
          toolbarHeight: _toolbarHeight,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: DefaultColors.iconColor),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller
                    .currentArg.value.partDirection.value.partDirectionName,
                style: const TextStyle(
                    color: DefaultColors.ink500,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            Obx(
              () => controller.isSubmited.isFalse
                  ? CupertinoButton(
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: DefaultColors.red400,
                      ),
                      onPressed: () => controller.deleteAllImages(context),
                    )
                  : Container(),
            ),
          ],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: GetBuilder(
            id: 'previewAllImage',
            builder: (PreviewAllImageController _) {
              var partDirection =
                  controller.currentArg.value.partDirection.value;
              // image server
              var imageList = <AiImage>[].obs;
              imageList.addAll(partDirection.middleViewImages);
              imageList.addAll(partDirection.closeViewImages);
              // image file
              var imageFiles = <PickedFileWithId>[].obs;
              imageFiles.addAll(partDirection.middleViewImageFiles);
              imageFiles.addAll(partDirection.closeViewImageFiles);
              int _oldImageId = partDirection.overViewImageFiles.isNotEmpty
                  ? partDirection.overViewImageFiles.first.imageId
                  : partDirection.overViewImages.isNotEmpty
                      ? int.parse(partDirection.overViewImages.first.imageId)
                      : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OverViewSection(
                    showDeleteAndRetake: !(partDirection
                            .overViewImages.isNotEmpty &&
                        partDirection.overViewImages.first.isSendToPti == true),
                    imageUrl: partDirection.overViewImageFiles.isNotEmpty
                        ? partDirection.overViewImageFiles.first.file.path
                        : partDirection.overViewImages.isNotEmpty
                            ? partDirection.overViewImages.first.url
                            : '',
                    onRetake: () => controller.goToCameraPage(
                      context,
                      1,
                      oldImageId: _oldImageId,
                    ),
                    onDelete: () => controller.overViewImageDelete(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CloseViewSection(
                      imageFromServers: imageList,
                      imageFiles: imageFiles,
                      onRetake: (rangeID, oldImageId) =>
                          controller.goToCameraPage(
                        context,
                        rangeID,
                        oldImageId: oldImageId,
                      ),
                      onDelete: (imageId) =>
                          controller.deleteImageById(imageId, rangeId: 2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
