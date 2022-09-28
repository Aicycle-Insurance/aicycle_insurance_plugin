import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../aicycle_insurance.dart';
import '../../src/common/dialog/notification_dialog.dart';
import '../../src/camera_view/controller/camera_controller.dart';
import '../../src/drawing_tool/new_drawing_tool.dart';
import '../constants/colors.dart';
import '../constants/shot_range.dart';
import '../constants/strings.dart';
import 'bottom_action_bar/bottom_action_bar.dart';
import 'camera_argument.dart';
import 'widgets/preview_with_mask.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    Key key,
    this.cameraArgument,
  }) : super(key: key);

  final CameraArgument cameraArgument;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  final double toolbarHeight = 80.0;
  CameraController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<CameraController>()) {
      controller = Get.find<CameraController>();
    } else {
      controller = Get.put(CameraController(pageArg: widget.cameraArgument));
    }
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<CameraController>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => controller.onWillPop(context),
      child: DefaultTabController(
        length: 3,
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
                  onPressed: () => controller.onWillPop(context),
                ),
                Center(
                  child: Obx(
                    () => Text(
                      controller.currentArg.value.partDirection.value
                          .partDirectionName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
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
                      // CupertinoIcons.photo_on_rectangle,
                      FontAwesomeIcons.images,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => controller.galleryPicker(context),
                )
              ],
            ),
            bottom: TabBar(
              controller: controller.tabController,
              onTap: (index) => controller.changeTab(context, index),
              tabs: const <Widget>[
                Tab(
                  text: StringKeys.overViewShot,
                ),
                Tab(
                  text: StringKeys.middleViewShot,
                ),
                Tab(
                  text: StringKeys.closeUpViewShot,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    /// Camera view
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: CameraAwesome(
                        onPermissionsResult: (result) =>
                            _handleCameraDoNotHavePermission(result),
                        selectDefaultSize: (List<Size> availableSizes) =>
                            availableSizes[1],
                        sensor: controller.sensor,
                        photoSize: controller.photoSize,
                        switchFlashMode: controller.flashMode,
                        captureMode: controller.captureMode,
                      ),
                    ),

                    /// Các widgets bổ trợ
                    Obx(() {
                      return Stack(
                        children: [
                          /// Khung xe gợi ý
                          if (controller.previewFile.value == null &&
                              controller.currentTabIndex.value == 0)
                            Obx(
                              () => SafeArea(
                                child: Center(
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Transform.scale(
                                      scale: controller.scaleImageValue.value,
                                      child: Image.asset(
                                        controller.loadImageByVehicleBrand(),
                                        fit: BoxFit.cover,
                                        package: packageName,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          /// Thanh chỉnh độ zoom khung xe
                          if (controller.previewFile.value == null &&
                              controller.currentTabIndex.value == 0)
                            SafeArea(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: SizedBox(
                                      height: 32,
                                      width: Get.width / 2,
                                      child: Slider.adaptive(
                                        min: 0.5,
                                        max: 1,
                                        activeColor: Colors.white,
                                        // thumbColor: Colors.white,
                                        inactiveColor: Colors.white38,
                                        value: controller.scaleImageValue.value,
                                        onChanged: (value) {
                                          controller.scaleImageValue.value =
                                              value;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          /// Preview file kèm mask thiệt hại
                          if (controller.previewFile.value != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: PreviewImageWithMask(
                                  damageAssess: controller.damageAssessment,
                                  previewFile: controller.previewFile,
                                  previewUserMaskImagesBuffer:
                                      controller.previewUserMaskImagesBuffer,
                                ),
                              ),
                            ),

                          /// Tên tab
                          SafeArea(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, right: 16),
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  // child: CarImage3DContainer(),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Obx(
                                        () => Text(
                                          imageRangeIds.keys.toList()[
                                              controller.currentTabIndex.value],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// Chọn bộ phận tab cận cảnh
                          if (controller.currentTabIndex.value == 2 &&
                              controller.listCarPartFromMiddleView.isNotEmpty)
                            SafeArea(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16, right: 16),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    // child: CarImage3DContainer(),
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.selectCarPart(context),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Obx(
                                            () => Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  controller
                                                          .carPartOnSelected
                                                          .value
                                                          .vehiclePartNamge ??
                                                      '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: Colors.white,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (controller.damageAssessment.value != null &&
                              controller.previewFile.value != null &&
                              controller.currentTabIndex.value != 2)
                            NewDrawingToolLayer(
                              damageAssess: controller.damageAssessment,
                              imageUrl: controller.previewFile.value.path,
                              onCancelCallBack: () =>
                                  controller.drawingToolCancelCallBack(context),
                              onSaveCallBack: (buffer, reDamageAssessment) =>
                                  controller.drawingToolSaveCallBack(
                                      context, buffer, reDamageAssessment),
                              token: controller.currentArg.value.token,
                            )
                        ],
                      );
                    }),
                  ],
                ),
              ),
              BottomActionBar(
                currentArg: controller.currentArg,
                currentTabIndex: controller.currentTabIndex,
                previewFile: controller.previewFile,
                onTakePicture: () => controller.takePicture(context),
                flashMode: controller.flashMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCameraDoNotHavePermission(bool value) {
    if (value == null || value == false) {
      Navigator.pop(context);
      NotificationDialog.show(
        context,
        type: NotiType.error,
        content: StringKeys.noCameraPermission,
        confirmCallBack: () {},
      );
    }
  }
}
