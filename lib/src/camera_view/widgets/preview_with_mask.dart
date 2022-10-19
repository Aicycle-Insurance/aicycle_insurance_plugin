import 'dart:io';
import 'dart:typed_data';

import 'package:aicycle_insurance_non_null_safety/types/damage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../types/damage_assessment.dart';
import '../../constants/damage_types.dart';
import '../../constants/colors.dart';

class PreviewImageWithMask extends StatelessWidget {
  const PreviewImageWithMask({
    Key key,
    this.damageAssess,
    this.previewFile,
    this.previewUserMaskImagesBuffer,
    this.listDamageModelCallBack,
  }) : super(key: key);

  final Rx<PickedFile> previewFile;
  final Rx<DamageAssessmentModel> damageAssess;
  final RxList<Uint8List> previewUserMaskImagesBuffer;
  final Function(List<DamageModel>) listDamageModelCallBack;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var masks = <Widget>[];
      var cachedDamageType = <String>[];
      var listInitDamageModel = <DamageModel>[];
      if (damageAssess.value != null) {
        // duyệt hết các parts trả về
        for (var i = 0; i < damageAssess.value.carParts.length; i++) {
          var imWidth = damageAssess.value.imageSize[0].toDouble();
          var imHeight = damageAssess.value.imageSize[1].toDouble();
          // duyệt các damages của từng part
          // var colorPart =
          //     Colors.red.withOpacity(damageBaseOpacity) ?? Colors.transparent;
          // var boxPart = damageAssess.value.carParts[i].carPartBoxes;
          // masks.add(
          //   Positioned(
          //     left: boxPart[0].toDouble() * imWidth,
          //     top: boxPart[1].toDouble() * imHeight,
          //     child: SizedBox(
          //       width: imWidth * (boxPart[2] - boxPart[0]),
          //       height: imHeight * (boxPart[3] - boxPart[1]),
          //       child: CachedNetworkImage(
          //         imageUrl: damageAssess.value.carParts[i].carPartMaskUrl,
          //         fit: BoxFit.fill,
          //         color: colorPart,
          //         width: imWidth * (boxPart[2] - boxPart[0]),
          //         height: imHeight * (boxPart[3] - boxPart[1]),
          //       ),
          //     ),
          //   ),
          // );
          for (var j = 0;
              j < damageAssess.value.carParts[i].carPartDamages.length;
              j++) {
            var carPartDamage =
                damageAssess.value.carParts[i].carPartDamages[j];
            if (!cachedDamageType.contains(carPartDamage.uuid)) {
              cachedDamageType.add(carPartDamage.uuid);
              listInitDamageModel.add(carPartDamage);
              var color = damageClassColors[carPartDamage.className]
                      .withOpacity(damageBaseOpacity) ??
                  Colors.transparent;
              var box = carPartDamage.boxes;

              if (box != null && box.isNotEmpty) {
                masks.add(
                  Positioned(
                    left: box[0].toDouble() * imWidth,
                    top: box[1].toDouble() * imHeight,
                    child: SizedBox(
                      // width: imWidth * (box[2] - box[0]),
                      // height: imHeight * (box[3] - box[1]),
                      child: CachedNetworkImage(
                        imageUrl: carPartDamage.maskUrl,
                        fit: BoxFit.fill,
                        color: color,
                        // width: imWidth * (box[2] - box[0]),
                        // height: imHeight * (box[3] - box[1]),
                      ),
                    ),
                  ),
                );
              }
            }
          }
        }
      }
      if (listDamageModelCallBack != null)
        listDamageModelCallBack(listInitDamageModel);
      // if (previewUserMaskImagesBuffer != null) {
      //   for (var maskImageBuffer in previewUserMaskImagesBuffer) {
      //     masks.add(Image.memory(
      //       maskImageBuffer,
      //       fit: BoxFit.fill,
      //     ));
      //   }
      // }
      return Container(
        color: Colors.black,
        child: InteractiveViewer(
          maxScale: 3,
          minScale: 1,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Stack(
              children: [
                Image.file(
                  File(previewFile.value.path),
                  fit: BoxFit.cover,
                ),
                ...masks,
              ],
            ),
          ),
        ),
      );
    });
  }
}
