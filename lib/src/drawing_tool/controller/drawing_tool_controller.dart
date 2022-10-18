import 'dart:io';
import 'dart:typed_data';

import 'package:aicycle_insurance_non_null_safety/types/damage.dart';
import 'package:flutter/foundation.dart';

import '../../../src/common/dialog/process_dialog.dart';
import '../../../src/constants/endpoints.dart';
import '../../../src/modules/resful_module.dart';
import '../../../src/modules/resful_module_impl.dart';
import '../../../types/damage_assessment.dart';
import '../../../types/user_corrected_damage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nanoid/nanoid.dart';

import '../../../src/constants/colors.dart';
import '../../../src/constants/damage_types.dart';
import '../../../src/drawing_tool/new_drawing_tool.dart';
import '../../../src/extensions/hex_color_extension.dart';
import '../../../src/flutter_painter/flutter_painter.dart';
import '../../../types/damage_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as imageplugin;
import 'package:mime/mime.dart' as mime;
import 'package:http/http.dart' as http;

class DrawingToolController extends GetxController {
  final Rx<DamageAssessmentModel> damageAssess;
  final String imageUrl;
  final String token;
  final List<DamageModel> initDamageModelList;
  final Function() onCancelCallBack;
  final Function(List<Uint8List>, DamageAssessmentModel) onSaveCallBack;
  DrawingToolController({
    this.damageAssess,
    this.imageUrl,
    this.token,
    this.onCancelCallBack,
    this.onSaveCallBack,
    this.initDamageModelList,
  });

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
  void onInit() {
    super.onInit();
    if (damageAssess.value.carDamages.isNotEmpty) {
      var currentType = DamageTypeConstant.listDamageType.firstWhere(
          (element) =>
              element.damageTypeGuid ==
              damageAssess.value.carDamages.first.uuid);
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
    initBackground();
  }

  @override
  void onClose() {
    super.onClose();
    paintController.dispose();
  }

  /// Khởi tạo background vẽ
  Future<void> initBackground() async {
    backgroundImage = Rx<ui.Image>(await (FileImage(File(imageUrl)).image));
    paintController.background = backgroundImage.value.backgroundDrawable;
  }

  /// Khởi tạo mask đã có
  Future<void> initMask() async {
    for (var mask in initDamageModelList) {
      var img = await CachedNetworkImageProvider(mask.maskUrl).image;
      initNetworkMask[mask.maskUrl] = img;
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
    // for (var part in damageAssess.value.carParts) {
    for (var mask in initDamageModelList) {
      if (mask.uuid != currentDamageClass.damageTypeGuid) continue;
      var img = initNetworkMask[mask.maskUrl];
      var tImg = imageplugin.decodePng(
          (await img.toByteData(format: ui.ImageByteFormat.png))
              .buffer
              .asUint8List());
      // var _hexColor = currentDamageClass.colorHex;
      var _damageType = DamageTypeConstant.listDamageType
          .firstWhere((element) => element.damageTypeGuid == mask.uuid);
      var _color =
          HexColor.fromHex(_damageType.colorHex).withOpacity(damageBaseOpacity);
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

  void finishAnnotate(BuildContext context) async {
    previewUserMaskImagesBuffer.clear();
    paintController.freeStyleMode = FreeStyleMode.none;
    ProgressDialog.showWithCircleIndicator(context, isLandScape: true);
    await saveDamageMask();

    final size = Size(backgroundImage.value.width.toDouble(),
        backgroundImage.value.height.toDouble());

    List<UserCorrectedDamageItem> correctedItems = [];
    for (var drawableItem in damageMaskDrawables.entries) {
      var renderedImage = await renderDamageMask(
        drawableItem.value,
        size,
        damageClassColors[drawableItem.key].withOpacity(damageBaseOpacity),
      );
      var pngImageBuffer = (await renderedImage.pngBytes);
      correctedItems.add(
        UserCorrectedDamageItem(
            maskData: pngImageBuffer,
            damageClass: drawableItem.key,
            maskImgName: nanoid() + '.png'),
      );
      previewUserMaskImagesBuffer.add(pngImageBuffer);
    }
    var reAssessmentResult = await userCorrectDamage(
      UserCorrectedDamages(
        imageId: damageAssess.value.imageId.toString(),
        correctedData: correctedItems,
      ),
      isReAssessment: true,
    );
    ProgressDialog.hide(context);
    onSaveCallBack(previewUserMaskImagesBuffer, reAssessmentResult);
    drawStatus.value = DrawStatus.end;
  }

  Future<DamageAssessmentModel> userCorrectDamage(
      UserCorrectedDamages userCorrectedDamages,
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
        token: token,
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

        print(DamageTypeConstant.listDamageType[idx].damageTypeGuid);
        damagePayload.add({
          "class": DamageTypeConstant.listDamageType[idx].damageTypeGuid,
          "maskPath": correctedData.maskImgName,
        });
      }
      var editResponse = await restfulModule.post(
        Endpoints.callEngineAfterUserEdit(userCorrectedDamages.imageId),
        {"damages": damagePayload},
        token: token,
      );
      if (editResponse != null) {
        return DamageAssessmentModel.fromJson(editResponse.body)
            .copyWith(imageId: damageAssess.value.imageId);
      }
      return null;
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

  void changeDamageType(BuildContext context) async {
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

  void onYesTapped() async {
    drawStatus.value = DrawStatus.drawing;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      var renderObj =
          painterKey.currentContext?.findRenderObject() as RenderBox;
      painterSize = renderObj.size;
      // await imageMaskToDrawable();
      setDamageMask();
    });
  }
}
