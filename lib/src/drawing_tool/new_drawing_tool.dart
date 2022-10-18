import 'dart:typed_data';

import 'package:aicycle_insurance_non_null_safety/types/damage.dart';

import '../../src/drawing_tool/controller/drawing_tool_controller.dart';
import '../../src/drawing_tool/widgets/actions_row.dart';
import '../../src/drawing_tool/widgets/save_discard_widget.dart';
import '../../src/drawing_tool/widgets/undo_redo_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../src/flutter_painter/flutter_painter.dart';
import '../../types/damage_assessment.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../extensions/hex_color_extension.dart';

enum DrawStatus {
  none,

  /// Chuẩn bị (chọn có hoặc không muốn sửa mask thiệt hại)
  ready,

  /// Bắt đầu vẽ
  start,

  /// Đang vẽ
  drawing,

  /// Kết thúc vẽ
  end
}

// ignore: must_be_immutable
class NewDrawingToolLayer extends StatefulWidget {
  const NewDrawingToolLayer({
    Key key,
    this.damageAssess,
    this.imageUrl,
    this.onCancelCallBack,
    this.onSaveCallBack,
    this.token,
    this.initDamageModelList,
  }) : super(key: key);

  final String imageUrl;
  final String token;
  final List<DamageModel> initDamageModelList;
  final Rx<DamageAssessmentModel> damageAssess;
  final Function() onCancelCallBack;
  final Function(List<Uint8List>, DamageAssessmentModel) onSaveCallBack;

  @override
  State<NewDrawingToolLayer> createState() => _NewDrawingToolLayerState();
}

class _NewDrawingToolLayerState extends State<NewDrawingToolLayer> {
  DrawingToolController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DrawingToolController>()) {
      controller = Get.find<DrawingToolController>();
    } else {
      controller = Get.put(
        DrawingToolController(
          damageAssess: widget.damageAssess,
          imageUrl: widget.imageUrl,
          token: widget.token,
          onSaveCallBack: widget.onSaveCallBack,
          onCancelCallBack: widget.onCancelCallBack,
          initDamageModelList: widget.initDamageModelList,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<DrawingToolController>();
    // paintController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: controller.initMask(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            /// Cbi vẽ
            controller.drawStatus.value = DrawStatus.ready;
            return Obx(() {
              return Stack(
                children: [
                  if (controller.drawStatus.value == DrawStatus.drawing)
                    Container(
                      color: Colors.black,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio:
                                controller.backgroundImage.value.width /
                                    controller.backgroundImage.value.height,
                            child: FlutterPainter(
                              key: controller.painterKey,
                              controller: controller.paintController,
                              onDrawableDeleted: (a) {},
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (controller.drawStatus.value == DrawStatus.ready ||
                      controller.drawStatus.value == DrawStatus.end)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16, left: 16),
                          child: RotatedBox(
                            quarterTurns: 1,
                            // child: CarImage3DContainer(),
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      StringKeys.missingDamage,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minSize: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border:
                                              Border.all(color: Colors.white),
                                        ),
                                        child: const Text(
                                          StringKeys.noWord,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      onPressed: widget.onCancelCallBack,
                                    ),
                                    const SizedBox(width: 8),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minSize: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: const [
                                            Text(
                                              StringKeys.yesWord,
                                              style: TextStyle(
                                                color: DefaultColors.blue,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.edit,
                                              color: DefaultColors.blue,
                                            )
                                          ],
                                        ),
                                      ),
                                      onPressed: controller.onYesTapped,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (controller.drawStatus.value == DrawStatus.drawing)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: ValueListenableBuilder<PainterControllerValue>(
                          valueListenable: controller.paintController,
                          builder: (context, _, __) => Stack(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ActionsRow(
                                      paintController:
                                          controller.paintController,
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () =>
                                          controller.changeDamageType(context),
                                      child: Container(
                                        height: 32,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.black54,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: HexColor.fromHex(
                                                  controller.currentDamageType
                                                      .value.colorHex),
                                              radius: 4,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              controller.currentDamageType.value
                                                  .damageTypeName,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.paintController.freeStyleMode !=
                                  FreeStyleMode.none)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: RotatedBox(
                                    quarterTurns: -1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: Get.width / 2,
                                          child: Slider.adaptive(
                                            min: 1,
                                            max: 50,
                                            activeColor: Colors.white,
                                            // thumbColor: Colors.white,
                                            inactiveColor: Colors.white38,
                                            value: controller.paintController
                                                .freeStyleStrokeWidth,
                                            onChangeStart: (value) => controller
                                                .isStrokeWidthChanged
                                                .value = true,
                                            onChangeEnd: (value) => controller
                                                .isStrokeWidthChanged
                                                .value = false,
                                            onChanged: controller
                                                .setFreeStyleStrokeWidth,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (controller
                                            .paintController.freeStyleMode !=
                                        FreeStyleMode.none)
                                      UndoRedoActionWidget(
                                        painterController:
                                            controller.paintController,
                                      ),
                                    const Expanded(child: SizedBox()),
                                    SaveOrDiscardWidget(
                                      onCancel: () {
                                        controller.drawStatus.value =
                                            DrawStatus.end;
                                        controller.paintController
                                            .clearDrawables();
                                        widget.onCancelCallBack();
                                      },
                                      onSave: () =>
                                          controller.finishAnnotate(context),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Visibility(
                                  visible:
                                      controller.isStrokeWidthChanged.value,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: CircleAvatar(
                                      radius: controller.paintController
                                              .freeStyleStrokeWidth /
                                          2,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            });
          } else {
            return const SizedBox();
          }
        });
  }
}
