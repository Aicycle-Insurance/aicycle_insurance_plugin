// Copyright © 2022 AICycle. All rights reserved.
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../types/image.dart';
import '../../types/image_range.dart';
import '../../types/summaty_image.dart';
import '../../types/part_direction.dart';
import '../../gen/assets.gen.dart';
import '../../types/part_direction_meta.dart';
import '../../aicycle_insurance.dart';
import '../constants/car_brand.dart';
import '../constants/colors.dart';
import '../constants/car_part_direction.dart';
import '../constants/strings.dart';
import '../camera_view/camera_argument.dart';
import '../constants/endpoints.dart';
import '../modules/resful_module.dart';
import '../modules/resful_module_impl.dart';
import '../preview_all_image/preview_all_image_page.dart';
import '../camera_view/camera_page.dart';
import 'photo_taken_point.dart';
import 'widgets/summary_image_section.dart';

class ClaimFolderView extends StatefulWidget {
  /// Hiển thị các góc chụp và thông tin liên quan.
  /// Khởi tạo hồ sơ bảo hiểm phía AICycle

  const ClaimFolderView({
    Key? key,
    required this.sessionId,
    required this.carBrand,
    required this.uTokenKey,
    this.loadingWidget,
    this.onError,
    this.onFrontLeftChanged,
    this.onFrontRightChanged,
    this.onFrontChanged,
    this.onLeftRearChanged,
    this.onRightRearChanged,
    this.onRearChanged,
  }) : super(key: key);

  /// ID hồ sơ
  final String sessionId;

  /// Hãng xe hỗ trợ
  final CarBrandType carBrand;

  /// Token key khi đăng nhập phía AICycle
  final String uTokenKey;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Khi xử lý lỗi
  final Function(String message)? onError;

  /// Hàm call back trả về danh sách ảnh Trái - Trước
  final Function(List<File>)? onFrontLeftChanged;

  /// Hàm call back trả về danh sách ảnh Phải - Trước
  final Function(List<File>)? onFrontRightChanged;

  /// Hàm call back trả về danh sách ảnh Trước
  final Function(List<File>)? onFrontChanged;

  /// Hàm call back trả về danh sách ảnh Trái - Sau
  final Function(List<File>)? onLeftRearChanged;

  /// Hàm call back trả về danh sách ảnh Phải - Sau
  final Function(List<File>)? onRightRearChanged;

  /// Hàm call back trả về danh sách ảnh Sau
  final Function(List<File>)? onRearChanged;

  @override
  State<ClaimFolderView> createState() => _ClaimFolderViewState();
}

class _ClaimFolderViewState extends State<ClaimFolderView> {
  // 3d car height
  final double _carHeight = 448.0;
  // 3d car width
  final double _carWidth = 274.0;
  late List<SummaryImage> _summaryImages;

  // Aicycle Claim id
  var claimId = ''.obs;

  /// 6 góc chụp
  /// trái trước
  late Rx<PartDirection> _front45Left;

  /// trước
  late Rx<PartDirection> _frontStraight;

  /// phải trước
  late Rx<PartDirection> _front45Right;

  /// phải sau
  late Rx<PartDirection> _leftRear;

  /// sau
  late Rx<PartDirection> _rear;

  /// phải sau
  late Rx<PartDirection> _rightRear;

  List<Rx<PartDirection>> get _listPartDirections {
    return [
      _front45Left,
      _frontStraight,
      _front45Right,
      _leftRear,
      _rightRear,
      _rear,
    ];
  }

  @override
  void initState() {
    super.initState();
    initPartDirection();
    _summaryImages = [];
    // _createClaimFolder();
  }

  void initPartDirection() {
    _front45Left = Rx<PartDirection>(PartDirection(
      partDirectionId: 4,
      partDirectionName: StringKeys.leftHead45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[4]!),
    ));
    _frontStraight = Rx<PartDirection>(PartDirection(
      partDirectionId: 2,
      partDirectionName: StringKeys.carHead,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[2]!),
    ));
    _front45Right = Rx<PartDirection>(PartDirection(
      partDirectionId: 3,
      partDirectionName: StringKeys.rightHead45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[3]!),
    ));
    _leftRear = Rx<PartDirection>(PartDirection(
      partDirectionId: 7,
      partDirectionName: StringKeys.leftTail45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[7]!),
    ));
    _rightRear = Rx<PartDirection>(PartDirection(
      partDirectionId: 6,
      partDirectionName: StringKeys.rightTail45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[6]!),
    ));
    _rear = Rx<PartDirection>(PartDirection(
      partDirectionId: 5,
      partDirectionName: StringKeys.carTail,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[5]!),
    ));
  }

  Future<String?> _createAndCallImage() async {
    var result = await _createClaimFolder().then((value) async {
      if (value != null) {
        await _getAllImageInClaimFolder();
        return value;
      }
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _createAndCallImage(),
        builder: (context, AsyncSnapshot<String?> snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    widget.loadingWidget ?? const CircularProgressIndicator());
          }
          if (snapShot.connectionState == ConnectionState.done) {
            if (snapShot.data == null) {
              return Container();
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryImagesSection(
                    claimId: snapShot.data!,
                    token: widget.uTokenKey,
                    sessionId: widget.sessionId,
                    images: _summaryImages,
                    onError: (message) {
                      if (widget.onError != null) {
                        widget.onError!(message);
                      }
                    },
                    imagesOnChanged: (images) {
                      _summaryImages = images;
                    },
                  ),
                  _partDirectionsSection(),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
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
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Obx(
                        () => Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            ..._listPartDirections.map((carDirection) {
                              int allImageLength =
                                  carDirection.value.images.length +
                                      carDirection.value.imageFiles.length;
                              return Positioned(
                                left: carDirection.value.meta
                                        .verticalRelativePosition[0] *
                                    constraints.maxWidth,
                                bottom: carDirection.value.meta
                                        .verticalRelativePosition[1] *
                                    constraints.maxHeight,
                                child: Obx(
                                  () => PhotoTakenPoint(
                                    onTap: allImageLength == 0
                                        ? () => _goToCameraPage(carDirection)
                                        : () => _goToPreviewPage(carDirection),
                                    isTaken:
                                        carDirection.value.images.isNotEmpty ||
                                            carDirection
                                                .value.imageFiles.isNotEmpty,
                                  ),
                                ),
                              );
                            }).toList(),
                            ..._listPartDirections.map((carDirection) {
                              bool isLeftPoint =
                                  carDirection.value.partDirectionId == 4 ||
                                      carDirection.value.partDirectionId == 7;
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

                              int allImageLength =
                                  carDirection.value.images.length +
                                      carDirection.value.imageFiles.length;

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
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        carDirection.value.partDirectionName,
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (allImageLength > 0)
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
                                                text: '$allImageLength',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
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
                                      )
                                  ],
                                ),
                              );
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

  // Tạo folder phía AICycle
  Future<String?> _createClaimFolder() async {
    RestfulModule restfulModule = RestfulModuleImpl();
    try {
      Map<String, dynamic> data = {
        'claimName': 'PTI folder - ${widget.sessionId}',
        'vehicleBrandId': CarBrand.carBrandIds[widget.carBrand].toString(),
        'externalSessionId': widget.sessionId,
      };

      var response = await restfulModule.post(
        Endpoints.createClaimFolder,
        data,
        token: widget.uTokenKey,
      );
      if (response.body != null) {
        claimId.value = response.body['data'][0]['claimId'].toString();
        return response.body['data'][0]['claimId'].toString();
      } else {
        if (widget.onError != null) {
          widget.onError!(response.statusMessage ?? 'Package error');
        }
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getAllImageInClaimFolder() async {
    try {
      RestfulModule restfulModule = RestfulModuleImpl();

      /// Gọi lấy ảnh từng góc chụp
      for (var _part in _listPartDirections) {
        var response = await restfulModule.get(
          Endpoints.getImageInCLaim(widget.sessionId),
          token: widget.uTokenKey,
          query: {
            "partDirectionId": _part.value.partDirectionId.toString(),
          },
        );
        if (response.body != null) {
          List result = response.body['data'];
          List<AiImage> _images =
              result.map((e) => AiImage.fromJson(e)).toList();

          /// Tạo list trung gian Gán ảnh vào part
          List<AiImage> _overViewImages = [];
          List<AiImage> _middleViewImages = [];
          List<AiImage> _closeImages = [];
          for (var _image in _images) {
            switch (imageRangeIds[_image.imageRangeName]) {
              case 1:
                _overViewImages.add(_image);
                break;
              case 2:
                _middleViewImages.add(_image);
                break;
              case 3:
                _closeImages.add(_image);
                break;
            }
          }

          /// Gán ảnh vào part
          _part.value = _part.value.copyWith(
            images: _images,
            overViewImages: _overViewImages,
            closeViewImages: _closeImages,
            middleViewImages: _middleViewImages,
            imageFiles: [],
            overViewImageFiles: [],
            closeViewImageFiles: [],
            middleViewImageFiles: [],
          );
        } else {
          if (widget.onError != null) {
            widget.onError!(response.statusMessage ?? 'Package error');
          }
        }
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!('Package get images error: $e');
      }
      rethrow;
    }
  }

  void _goToPreviewPage(Rx<PartDirection> partDirection) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewAllImagePage(
                  cameraArgument: CameraArgument(
                    carBrand: widget.carBrand,
                    partDirection: partDirection.value,
                    claimId: claimId.value,
                    imageRangeId: 1,
                  ),
                  token: widget.uTokenKey,
                  onError: (message) {
                    if (widget.onError != null) {
                      widget.onError!(message);
                    }
                  },
                ))).then((value) {
      if (value is CameraArgument) {
        partDirection.value = value.partDirection;
      }
    });
  }

  void _goToCameraPage(Rx<PartDirection> partDirection) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraPage(
                token: widget.uTokenKey,
                onError: widget.onError ?? (message) {},
                cameraArgument: CameraArgument(
                  partDirection: partDirection.value,
                  claimId: claimId.value,
                  imageRangeId: 1,
                  carBrand: widget.carBrand,
                )))).then((value) {
      if (value is CameraArgument) {
        partDirection.value = value.partDirection;
      }
    });
  }
}
