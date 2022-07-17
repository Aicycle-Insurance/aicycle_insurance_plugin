// Copyright © 2022 AICycle. All rights reserved.
// found in the LICENSE file.

import 'package:aicycle_insurance/constants/colors.dart';
import 'package:aicycle_insurance/constants/strings.dart';
import 'package:aicycle_insurance/gen/assets.gen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../aicycle_insurance.dart';
// import 'package:get/get.dart';

class ClaimFolderView extends StatefulWidget {
  /// Hiển thị các góc chụp và thông tin liên quan.
  /// Khởi tạo hồ sơ bảo hiểm phía AICycle

  const ClaimFolderView({
    Key? key,
    required this.folderId,
  }) : super(key: key);

  /// ID hồ sơ
  final String folderId;

  @override
  State<ClaimFolderView> createState() => _ClaimFolderViewState();
}

class _ClaimFolderViewState extends State<ClaimFolderView> {
  // 3d car height
  final double _carHeight = 448.0;
  // 3d car width
  final double _carWidth = 274.0;
  late List overViewImages;
  final String _testUrl =
      'https://s3-sgn09.fptcloud.com/aicycle-dev/INSURANCE/1657685983338/1657685983301.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=0080fa5f9d06c7ad85c7%2F20220717%2Fsgn09%2Fs3%2Faws4_request&X-Amz-Date=20220717T161001Z&X-Amz-Expires=7200&X-Amz-Signature=d63d3c47ece4565f9a327ae09eae77ba810f578fee85b723da08c3e75f312be2&X-Amz-SignedHeaders=host';

  @override
  void initState() {
    super.initState();
    overViewImages = [1, 2, 3, 4];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16).copyWith(bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${StringKeys.overView} (${overViewImages.length})',
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          children: const [
                            Icon(
                              CupertinoIcons.camera,
                              size: 18,
                              color: DefaultColors.blue,
                            ),
                            SizedBox(width: 4),
                            Material(
                              child: Text(
                                StringKeys.takePicture,
                                style: TextStyle(
                                  color: DefaultColors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _overViewImageSection(),
              ],
            ),
          ),
          _partDirectionsSection(),
        ],
      ),
    );
  }

  Widget _overViewImageSection() {
    if (overViewImages.isEmpty) {
      return const Text(
        StringKeys.noImages,
        style: TextStyle(fontSize: 14),
      );
    } else {
      return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 8,
        shrinkWrap: true,
        children: overViewImages.map((element) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 72,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    // child: Image.network(
                    //   _testUrl,
                    //   fit: BoxFit.cover,
                    // ),
                    child: CachedNetworkImage(
                      imageUrl: _testUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.black54,
                    child: Center(
                      child: Icon(
                        Icons.clear_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  onPressed: () {},
                ),
              )
            ],
          );
        }).toList(),
      );
    }
  }

  Widget _partDirectionsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            StringKeys.detail,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
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
                    child: Assets.images.vertical3dCar.image(
                      width: 204,
                      height: 303,
                      package: packageName,
                    ),
                  ),
                ),
                // Positioned.fill(
                //   child: LayoutBuilder(
                //     builder: (context, constraints) {
                //       return Obx(
                //         () => Stack(
                //           clipBehavior: Clip.none,
                //           children: <Widget>[
                //             ...controller.listPTIPartDirections
                //                 .map((carDirection) {
                //               return Positioned(
                //                 left: carDirection.value.meta
                //                         .verticalRelativePosition[0] *
                //                     constraints.maxWidth,
                //                 bottom: carDirection.value.meta
                //                         .verticalRelativePosition[1] *
                //                     constraints.maxHeight,
                //                 child: Obx(
                //                   () => PhotoTakenPoint(
                //                     onTap: () => controller
                //                         .goToAIModeCamera(carDirection),
                //                     isTaken:
                //                         carDirection.value.images.isNotEmpty ||
                //                             carDirection
                //                                 .value.imageFiles.isNotEmpty,
                //                   ),
                //                 ),
                //               );
                //             }).toList(),
                //             ...controller.listPTIPartDirections
                //                 .map((carDirection) {
                //               bool isLeftPoint =
                //                   carDirection.value.partDirectionId == 4 ||
                //                       carDirection.value.partDirectionId == 7;
                //               double paddingRight = (1 -
                //                           carDirection.value.meta
                //                               .verticalRelativePosition[0]) *
                //                       constraints.maxWidth -
                //                   24;
                //               double paddingLeft = carDirection
                //                       .value.meta.verticalRelativePosition[0] *
                //                   constraints.maxWidth;
                //               double paddingTop = (1 -
                //                           carDirection.value.meta
                //                               .verticalRelativePosition[1]) *
                //                       constraints.maxHeight +
                //                   4;

                //               bool isCenterPoint =
                //                   carDirection.value.partDirectionId == 2 ||
                //                       carDirection.value.partDirectionId == 5;

                //               int allImageLength =
                //                   carDirection.value.images.length +
                //                       carDirection.value.imageFiles.length;

                //               return Positioned(
                //                 right: isCenterPoint
                //                     ? null
                //                     : isLeftPoint
                //                         ? paddingRight
                //                         : null,
                //                 left: isCenterPoint
                //                     ? paddingLeft - 8
                //                     : isLeftPoint
                //                         ? null
                //                         : paddingLeft,
                //                 top: paddingTop,
                //                 child: Column(
                //                   crossAxisAlignment: isLeftPoint
                //                       ? CrossAxisAlignment.end
                //                       : isCenterPoint
                //                           ? CrossAxisAlignment.center
                //                           : CrossAxisAlignment.start,
                //                   children: [
                //                     Container(
                //                       padding: const EdgeInsets.all(4),
                //                       decoration: BoxDecoration(
                //                         color: Colors.white,
                //                         borderRadius: BorderRadius.circular(4),
                //                       ),
                //                       child: Text(
                //                         carDirection
                //                             .value.partDirectionNameKey.tr,
                //                         style:
                //                             t12M.copyWith(color: Colors.black),
                //                         maxLines: 2,
                //                       ),
                //                     ),
                //                     const SizedBox(height: 4),
                //                     if (allImageLength > 0)
                //                       GestureDetector(
                //                         onTap: () => controller
                //                             .goToPartDetails(carDirection),
                //                         child: Container(
                //                           padding: const EdgeInsets.all(4),
                //                           decoration: BoxDecoration(
                //                             color: AppColors.blue[500],
                //                             borderRadius:
                //                                 BorderRadius.circular(4),
                //                           ),
                //                           child: Text.rich(
                //                             TextSpan(
                //                               children: [
                //                                 TextSpan(
                //                                   text: '$allImageLength',
                //                                   style: t12M.copyWith(
                //                                     color: Colors.white,
                //                                     fontWeight: FontWeight.bold,
                //                                   ),
                //                                 ),
                //                                 TextSpan(
                //                                   text:
                //                                       ' ${LocalizationKeys.imageWord.tr}',
                //                                   style: t12M.copyWith(
                //                                     color: Colors.white,
                //                                   ),
                //                                 ),
                //                               ],
                //                             ),
                //                           ),
                //                         ),
                //                       )
                //                   ],
                //                 ),
                //               );
                //             }).toList()
                //           ],
                //         ),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
