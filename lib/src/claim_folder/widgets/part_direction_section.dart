import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../aicycle_insurance.dart';
import '../../../gen/assets.gen.dart';
import '../../../src/claim_folder/controller/claim_folder_controller.dart';
import '../../../src/claim_folder/photo_taken_point.dart';
import '../../../src/constants/colors.dart';
import '../../../src/constants/strings.dart';

class PartDirectionSection extends StatelessWidget {
  const PartDirectionSection({Key key, this.controller}) : super(key: key);
  final ClaimFolderController controller;

  // 3d car height
  final double _carHeight = 448.0;
  // 3d car width
  final double _carWidth = 274.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            StringKeys.detail,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: _carHeight,
                  width: _carWidth,
                  child: Center(
                    child: Image.asset(
                      Assets.images.vertical3dCar.path,
                      width: 204,
                      height: 303,
                      package: packageName,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Obx(
                        () => Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            ...controller.listPartDirections
                                .map((carDirection) {
                              var allImageLength =
                                  (carDirection.value.images.length +
                                          carDirection.value.imageFiles.length)
                                      .obs;
                              return Positioned(
                                left: carDirection.value.meta
                                        .verticalRelativePosition[0] *
                                    constraints.maxWidth,
                                bottom: carDirection.value.meta
                                        .verticalRelativePosition[1] *
                                    constraints.maxHeight,
                                child: Obx(
                                  () => PhotoTakenPoint(
                                    onTap: allImageLength.value == 0
                                        ? () => controller.goToCameraPage(
                                            context, carDirection)
                                        : () => controller.goToPreviewPage(
                                            context, carDirection),
                                    isTaken:
                                        carDirection.value.images.isNotEmpty ||
                                            carDirection
                                                .value.imageFiles.isNotEmpty,
                                  ),
                                ),
                              );
                            }).toList(),
                            ...controller.listPartDirections
                                .map((carDirection) {
                              bool isLeftPoint =
                                  carDirection.value.partDirectionId == 9 ||
                                      carDirection.value.partDirectionId == 11;
                              double paddingRight = (1 -
                                          carDirection.value.meta
                                              .verticalRelativePosition[0]) *
                                      constraints.maxWidth -
                                  24;
                              double paddingLeft = carDirection
                                      .value.meta.verticalRelativePosition[0] *
                                  constraints.maxWidth;
                              double paddingTop = (1 -
                                          carDirection.value.meta
                                              .verticalRelativePosition[1]) *
                                      constraints.maxHeight +
                                  4;

                              bool isCenterPoint =
                                  carDirection.value.partDirectionId == 2 ||
                                      carDirection.value.partDirectionId == 5;

                              return Obx(() {
                                var allImageLength = (carDirection
                                            .value.images.length +
                                        carDirection.value.imageFiles.length)
                                    .obs;
                                return Positioned(
                                  right: isCenterPoint
                                      ? null
                                      : isLeftPoint
                                          ? paddingRight
                                          : null,
                                  left: isCenterPoint
                                      ? paddingLeft - 8
                                      : isLeftPoint
                                          ? null
                                          : paddingLeft,
                                  top: paddingTop,
                                  child: GestureDetector(
                                    onTap: allImageLength.value == 0
                                        ? () => controller.goToCameraPage(
                                            context, carDirection)
                                        : () => controller.goToPreviewPage(
                                            context, carDirection),
                                    child: Column(
                                      crossAxisAlignment: isLeftPoint
                                          ? CrossAxisAlignment.end
                                          : isCenterPoint
                                              ? CrossAxisAlignment.center
                                              : CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            carDirection
                                                .value.partDirectionName,
                                            style:
                                                const TextStyle(fontSize: 12),
                                            maxLines: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (allImageLength.value > 0)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: DefaultColors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '${allImageLength.value}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text:
                                                        ' ${StringKeys.imageWord}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            }).toList()
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
