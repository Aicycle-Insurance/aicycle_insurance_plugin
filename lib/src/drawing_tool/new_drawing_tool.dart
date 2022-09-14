import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as imageplugin;
import 'package:mime/mime.dart' as mime;
import 'package:http/http.dart' as http;
import 'package:nanoid/nanoid.dart';

import '../../types/user_corrected_damage.dart';
import '../../src/flutter_painter/flutter_painter.dart';
import '../../types/damage_type.dart';
import '../../types/damage_assessment.dart';
import '../common/dialog/process_dialog.dart';
import '../constants/endpoints.dart';
import '../modules/resful_module.dart';
import '../modules/resful_module_impl.dart';
import '../constants/colors.dart';
import '../constants/damage_types.dart';
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
  }) : super(key: key);

  final String imageUrl;
  final String token;
  final Rx<DamageAssessmentModel> damageAssess;
  final Function() onCancelCallBack;
  final Function(List<Uint8List>) onSaveCallBack;

  @override
  State<NewDrawingToolLayer> createState() => _NewDrawingToolLayerState();
}

class _NewDrawingToolLayerState extends State<NewDrawingToolLayer> {
  /// painter controller
  final PainterController paintController = PainterController(
    settings: PainterSettings(
      freeStyle: FreeStyleSettings(
        color: HexColor.fromHex(DamageTypeConstant.typeDent.colorHex)
            .withOpacity(damageBaseOpacity),
        strokeWidth: 10,
        mode: FreeStyleMode.draw,
      ),
      scale: const ScaleSettings(
        enabled: true,
        minScale: 0.8,
        maxScale: 5,
      ),
    ),
  );

  /// Trạng thái thay đổi độ rộng bút
  var isStrokeWidthChanged = false.obs;

  Rx<DamageTypes> currentDamageType;
  Rx<ui.Image> backgroundImage;
  Rx<DrawStatus> drawStatus;

  /// map mask url với dữ liệu mask tương ứng
  var initNetworkMask = <String, ui.Image>{};
  var damageMaskDrawables = <String, Drawable>{};

  /// lưu mask vừa vẽ để hiển thị preview
  var previewUserMaskImagesBuffer = <Uint8List>[].obs;
  Size painterSize;

  /// painter key để lấy kích thước vùng vẽ
  final GlobalKey painterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.damageAssess.value.carDamages.isNotEmpty) {
      var currentType = DamageTypeConstant.listDamageType.firstWhere(
          (element) =>
              element.damageTypeGuid ==
              widget.damageAssess.value.carDamages.first.uuid);
      currentDamageType = Rx<DamageTypes>(currentType);
      paintController.freeStyleColor =
          HexColor.fromHex(currentType.colorHex).withOpacity(damageBaseOpacity);
    } else {
      currentDamageType = Rx<DamageTypes>(DamageTypeConstant.typeDent);
    }
    currentDamageType.listen((p0) {
      paintController.freeStyleColor =
          HexColor.fromHex(p0.colorHex).withOpacity(damageBaseOpacity);
    });
    drawStatus = Rx<DrawStatus>(DrawStatus.none);
  }

  /// Khởi tạo background vẽ
  Future<void> initBackground() async {
    backgroundImage =
        Rx<ui.Image>(await (FileImage(File(widget.imageUrl)).image));
    paintController.background = backgroundImage.value.backgroundDrawable;
    await initMask();
  }

  /// Khởi tạo mask đã có
  Future<void> initMask() async {
    for (var part in widget.damageAssess.value.carParts) {
      for (var mask in part.carPartDamages) {
        var img = await CachedNetworkImageProvider(mask.maskUrl).image;
        initNetworkMask[mask.maskUrl] = img;
      }
    }
  }

  /// Tạo mask
  Future<void> setDamageMask() async {
    var drawables = <ImageDrawable>[];
    var currentDamageClass = currentDamageType.value;
    paintController.freeStyleMode = FreeStyleMode.draw;

    paintController.performedActions.clear();
    paintController.unperformedActions.clear();

    if (damageMaskDrawables.containsKey(currentDamageClass.damageTypeName)) {
      // Get the existing mask
      paintController.value = paintController.value.copyWith(
          drawables: [damageMaskDrawables[currentDamageClass.damageTypeName]]);
      return;
    }

    // Init mask
    var viewWidth = painterSize.width;
    var viewHeight = painterSize.height;
    for (var part in widget.damageAssess.value.carParts) {
      for (var mask in part.carPartDamages) {
        if (mask.uuid != currentDamageClass.damageTypeGuid) continue;
        var img = initNetworkMask[mask.maskUrl];
        var tImg = imageplugin.decodePng(
            (await img.toByteData(format: ui.ImageByteFormat.png))
                .buffer
                .asUint8List());

        var _color = HexColor.fromHex(currentDamageClass.colorHex)
            .withOpacity(damageBaseOpacity);
        tImg = imageplugin.colorOffset(
          tImg,
          alpha: -256 + _color.alpha,
          red: -255 + _color.red,
          blue: -255 + _color.blue,
          green: -255 + _color.green,
        );

        var maskW = mask.boxes[2] - mask.boxes[0];
        var maskH = mask.boxes[3] - mask.boxes[1];

        var finalImg =
            await MemoryImage(Uint8List.fromList(imageplugin.encodePng(tImg)))
                .image;

        var drawable = ImageDrawable.fittedToSize(
            image: finalImg,
            position: Offset(viewWidth * (mask.boxes[0] + maskW / 2),
                viewHeight * (mask.boxes[1] + maskH / 2)),
            size: Size(viewWidth * maskW, viewHeight * maskH));
        drawables.add(drawable);
      }
    }
    paintController.value =
        paintController.value.copyWith(drawables: drawables);
    await saveDamageMask();
  }

  Future<void> saveDamageMask() async {
    var currentDamageClass = currentDamageType.value;
    paintController.groupDrawables(newAction: false);
    paintController.performedActions.removeLast();
    var groupedDrawable = paintController.drawables[0];
    damageMaskDrawables[currentDamageClass.damageTypeName] = groupedDrawable;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: initBackground(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            /// Cbi vẽ
            drawStatus.value = DrawStatus.ready;
            return Obx(() {
              return Stack(
                children: [
                  if (drawStatus.value == DrawStatus.drawing)
                    Container(
                      color: Colors.black,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: backgroundImage.value.width /
                                backgroundImage.value.height,
                            child: FlutterPainter(
                              key: painterKey,
                              controller: paintController,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (drawStatus.value == DrawStatus.ready ||
                      drawStatus.value == DrawStatus.end)
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
                                      onPressed: () {
                                        drawStatus.value = DrawStatus.drawing;
                                        WidgetsBinding.instance
                                            ?.addPostFrameCallback((timeStamp) {
                                          var renderObj = painterKey
                                              .currentContext
                                              ?.findRenderObject() as RenderBox;
                                          painterSize = renderObj.size;
                                          setDamageMask();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (drawStatus.value == DrawStatus.drawing)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: ValueListenableBuilder<PainterControllerValue>(
                          valueListenable: paintController,
                          builder: (context, _, __) => Stack(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 1, color: Colors.white),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: toggleDrawing,
                                            child: Container(
                                              height: 32,
                                              width: 48,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: isDrawing()
                                                    ? Colors.white
                                                    : Colors.black54,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.gesture,
                                                  color: isDrawing()
                                                      ? DefaultColors.blue
                                                      : Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: toggleEraser,
                                            child: Container(
                                              height: 32,
                                              width: 48,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: isErasing()
                                                    ? Colors.white
                                                    : Colors.black54,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  PhosphorIcons.eraser,
                                                  color: isErasing()
                                                      ? DefaultColors.blue
                                                      : Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: toggleScale,
                                            child: Container(
                                              height: 32,
                                              width: 48,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: isScaling()
                                                    ? Colors.white
                                                    : Colors.black54,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  PhosphorIcons.arrows_out,
                                                  color: isScaling()
                                                      ? DefaultColors.blue
                                                      : Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: changeDamageType,
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
                                                  currentDamageType
                                                      .value.colorHex),
                                              radius: 4,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              currentDamageType
                                                  .value.damageTypeName,
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
                              if (paintController.freeStyleMode !=
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
                                            value: paintController
                                                .freeStyleStrokeWidth,
                                            onChangeStart: (value) =>
                                                isStrokeWidthChanged.value =
                                                    true,
                                            onChangeEnd: (value) =>
                                                isStrokeWidthChanged.value =
                                                    false,
                                            onChanged: setFreeStyleStrokeWidth,
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
                                    if (paintController.freeStyleMode !=
                                        FreeStyleMode.none) ...[
                                      Visibility(
                                        visible: undoable(),
                                        child: GestureDetector(
                                          onTap: undo,
                                          child: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.replay_rounded,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Visibility(
                                        visible: redoable(),
                                        child: GestureDetector(
                                          onTap: redo,
                                          child: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Transform(
                                                alignment: Alignment.center,
                                                transform:
                                                    Matrix4.rotationY(math.pi),
                                                child: const Icon(
                                                  Icons.replay_rounded,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const Expanded(child: SizedBox()),
                                    Container(
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: Colors.white),
                                              ),
                                              child: const Text(
                                                StringKeys.cancel,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            onPressed: () {
                                              drawStatus.value = DrawStatus.end;
                                              paintController.clearDrawables();
                                              widget.onCancelCallBack();
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            minSize: 0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                StringKeys.save,
                                                style: TextStyle(
                                                    color: DefaultColors.blue),
                                              ),
                                            ),
                                            onPressed: finishAnnotate,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Visibility(
                                  visible: isStrokeWidthChanged.value,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: CircleAvatar(
                                      radius:
                                          paintController.freeStyleStrokeWidth /
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

  void changeDamageType() async {
    var result = await showDialog(
      context: context,
      builder: (context) => RotatedBox(
        quarterTurns: 1,
        child: AlertDialog(
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: DamageTypeConstant.listDamageType
                .map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.pop(context, e),
                    // minLeadingWidth: 0,
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: HexColor.fromHex(e.colorHex),
                          radius: 4,
                        ),
                        const SizedBox(width: 16),
                        Text(e.damageTypeName),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      useSafeArea: true,
      barrierDismissible: true,
    );
    if (result != null) {
      await saveDamageMask();
      currentDamageType.value = result;
      await setDamageMask();
    }
  }

  void finishAnnotate() async {
    paintController.freeStyleMode = FreeStyleMode.none;
    ProgressDialog.showWithCircleIndicator(context, isLandScape: true);
    await saveDamageMask();

    final size = Size(backgroundImage.value.width.toDouble(),
        backgroundImage.value.height.toDouble());

    List<UserCorrectedDamageItem> correctedItems = [];
    for (var drawableItem in damageMaskDrawables.entries) {
      var renderedImage = await renderDamageMask(
          drawableItem.value, size, damageClassColors[drawableItem.key]);
      var pngImageBuffer = (await renderedImage.pngBytes);
      correctedItems.add(
        UserCorrectedDamageItem(
            maskData: pngImageBuffer,
            damageClass: drawableItem.key,
            maskImgName: nanoid() + '.png'),
      );
      previewUserMaskImagesBuffer.add(pngImageBuffer);
    }
    await userCorrectDamage(
      UserCorrectedDamages(
        imageId: widget.damageAssess.value.imageId.toString(),
        correctedData: correctedItems,
      ),
      isReAssessment: true,
    );
    ProgressDialog.hide(context);
    widget.onSaveCallBack(previewUserMaskImagesBuffer);
    drawStatus.value = DrawStatus.end;
  }

  Future userCorrectDamage(UserCorrectedDamages userCorrectedDamages,
      {bool isReAssessment = false}) async {
    try {
      RestfulModule restfulModule = RestfulModuleImpl();

      /// upload ảnh mask
      List<dynamic> filePaths =
          userCorrectedDamages.correctedData.map((imageData) {
        return 'INSURANCE_RESULT/${imageData.maskImgName}';
      }).toList();

      var response = await restfulModule.post(
        Endpoints.getUploadUrl,
        {'filePaths': filePaths},
        token: widget.token,
      );
      var uploadUrls = response.body['urls'];

      for (int idx = 0; idx < filePaths.length; idx++) {
        List<int> imageData = userCorrectedDamages.correctedData[idx].maskData;
        var url = Uri.parse(uploadUrls[idx]['uploadUrl']);
        var uploadRes = await http.put(
          url,
          body: imageData,
          headers: {
            'Content-Type': mime.lookupMimeType(
                userCorrectedDamages.correctedData[idx].maskImgName)
          },
        );
        if (uploadRes.statusCode != 200) {
          throw Exception(
              "Upload failed. Got status code ${uploadRes.statusCode}");
        }
      }

      ///
      /// call process the new result
      List<Map<String, String>> damagePayload = [];
      for (var correctedData in userCorrectedDamages.correctedData) {
        int idx = DamageTypeConstant.listDamageType.indexWhere(
            (element) => element.damageTypeName == correctedData.damageClass);

        damagePayload.add({
          "class": DamageTypeConstant.listDamageType[idx].damageTypeGuid,
          "maskPath": correctedData.maskImgName,
        });
      }
      if (!isReAssessment) {
        await restfulModule.post(
          Endpoints.runEnginePercent,
          {
            "images": [
              {
                "imageId": userCorrectedDamages.imageId,
                "damages": damagePayload,
              }
            ]
          },
          token: widget.token,
        );
      } else {
        await restfulModule.post(
          Endpoints.callEngineAfterUserEdit(userCorrectedDamages.imageId),
          {"damages": damagePayload},
          token: widget.token,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ui.Image> renderDamageMask(
      Drawable maskDrawable, Size size, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.save();

    var _scale = paintController.painterKey.currentContext?.size ?? size;

    canvas.transform(Matrix4.identity()
        .scaled(size.width / _scale.width, size.height / _scale.height)
        .storage);
    canvas.drawColor(color, ui.BlendMode.clear);
    canvas.saveLayer(Rect.largest, Paint());

    maskDrawable.draw(canvas, size);
    canvas.restore();

    var renderedImage = await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
    return renderedImage;
  }

  void setFreeStyleStrokeWidth(double value) {
    paintController.freeStyleStrokeWidth = value;
  }

  void startDrawing() {
    updateFreeStyle(FreeStyleMode.draw);
  }

  bool isDrawing() {
    return paintController.freeStyleMode == FreeStyleMode.draw;
  }

  void toggleEraser() {
    startEraser();
  }

  void toggleScale() {
    updateFreeStyle(FreeStyleMode.none);
  }

  void toggleDrawing() {
    startDrawing();
  }

  void startEraser() {
    updateFreeStyle(FreeStyleMode.erase);
  }

  void stopFreeStyle() {
    updateFreeStyle(FreeStyleMode.none);
  }

  bool isErasing() {
    return paintController.freeStyleMode == FreeStyleMode.erase;
  }

  bool isScaling() {
    return paintController.freeStyleMode == FreeStyleMode.none;
  }

  void updateFreeStyle(FreeStyleMode value) {
    paintController.freeStyleMode = value;
  }

  void undo() {
    paintController.undo();
  }

  void redo() {
    paintController.redo();
  }

  bool undoable() => paintController.canUndo;

  bool redoable() => paintController.canRedo;
}
