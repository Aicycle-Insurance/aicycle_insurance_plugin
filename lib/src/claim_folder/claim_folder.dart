// Copyright © 2022 AICycle. All rights reserved.
// found in the LICENSE file.

// import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../types/image.dart';
import '../../src/common/dialog/notification_dialog.dart';
import '../../types/damage_summary_result.dart';
// import '../../src/common/snack_bar/snack_bar.dart';
import '../../src/damage_result_page/damage_result_page.dart';
import '../../src/modules/module_types/common_response.dart';
import '../../types/image_range.dart';
import '../../types/summary_image.dart';
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
import '../common/dialog/process_dialog.dart';
import '../camera_view/camera_page.dart';
import 'photo_taken_point.dart';
import 'widgets/summary_image_section.dart';

class ClaimFolderView extends StatefulWidget {
  /// Hiển thị các góc chụp và thông tin liên quan.
  /// Khởi tạo hồ sơ bảo hiểm phía AICycle

  const ClaimFolderView({
    Key key,
    this.sessionId,
    // this.carBrand,
    this.uTokenKey,
    this.loadingWidget,
    this.onError,
    this.onGetResultCallBack,
    // this.onFrontLeftChanged,
    // this.onFrontRightChanged,
    // this.onFrontChanged,
    // this.onLeftRearChanged,
    // this.onRightRearChanged,
    // this.onRearChanged,
    this.maDonVi,
    this.kieuCongViec,
    this.loaiCongViec,
    this.deviceId,
    this.hangXe,
    this.hieuXe,
    // this.noiDungSuVu,
    this.maDonViNguoiDangNhap,
    this.maGiamDinhVien,
    this.phoneNumber,
    this.bienSoXe,
    // this.soIdCongViec,
  }) : super(key: key);

  /// ID hồ sơ
  /// PTI key: so_id
  final String sessionId;

  /// Hãng xe hỗ trợ
  // final CarBrandType carBrand;

  /// Token key khi đăng nhập phía AICycle
  final String uTokenKey;

  /// Custom loading widget
  final Widget loadingWidget;

  /// Khi xử lý lỗi
  final Function(String message) onError;

  /// Khi trả về kết quả
  final Function(Map<String, dynamic>) onGetResultCallBack;

  /// Hàm call back trả về danh sách ảnh Trái - Trước
  // final Function(List<File>) onFrontLeftChanged;

  /// Hàm call back trả về danh sách ảnh Phải - Trước
  // final Function(List<File>) onFrontRightChanged;

  /// Hàm call back trả về danh sách ảnh Trước
  // final Function(List<File>) onFrontChanged;

  /// Hàm call back trả về danh sách ảnh Trái - Sau
  // final Function(List<File>) onLeftRearChanged;

  /// Hàm call back trả về danh sách ảnh Phải - Sau
  // final Function(List<File>) onRightRearChanged;

  /// Hàm call back trả về danh sách ảnh Sau
  // final Function(List<File>) onRearChanged;

  /// Các thông tin cần cung cấp từ phía PTI
  /// PTI key: ma_id
  final String maDonVi;

  /// PTI key: KIEU_CV
  final String kieuCongViec;

  /// PTI key: loai
  final String loaiCongViec;

  /// PTI key: deviceId
  final String deviceId;

  /// PTI key: HANG_XE
  final String hangXe;

  /// PTI key: HIEU_XE
  final String hieuXe;

  /// PTI key: nd
  // final String noiDungSuVu;

  /// PTI key: ma_dvi_nh
  final String maDonViNguoiDangNhap;

  /// PTI key: nsd_nh
  final String maGiamDinhVien;

  /// PTI key: bien_xe
  final String bienSoXe;

  /// PTI key: so_id
  // final String soIdCongViec;

  /// PTI key: phone
  final String phoneNumber;

  @override
  State<ClaimFolderView> createState() => _ClaimFolderViewState();
}

class _ClaimFolderViewState extends State<ClaimFolderView> {
  final carBrand = CarBrandType.kiaMorning;
  // 3d car height
  final double _carHeight = 448.0;
  // 3d car width
  final double _carWidth = 274.0;
  List<SummaryImage> _summaryImages;

  // Aicycle Claim id
  var claimId = ''.obs;

  /// 6 góc chụp
  /// trái trước
  Rx<PartDirection> _front45Left;

  /// trước
  Rx<PartDirection> _frontStraight;

  /// phải trước
  Rx<PartDirection> _front45Right;

  /// phải sau
  Rx<PartDirection> _leftRear;

  /// sau
  Rx<PartDirection> _rear;

  /// phải sau
  Rx<PartDirection> _rightRear;

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
    _createAndCallImage();
  }

  void initPartDirection() {
    _front45Left = Rx<PartDirection>(PartDirection(
      partDirectionId: 4,
      partDirectionName: StringKeys.leftHead45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[4]),
    ));
    _frontStraight = Rx<PartDirection>(PartDirection(
      partDirectionId: 2,
      partDirectionName: StringKeys.carHead,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[2]),
    ));
    _front45Right = Rx<PartDirection>(PartDirection(
      partDirectionId: 3,
      partDirectionName: StringKeys.rightHead45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[3]),
    ));
    _leftRear = Rx<PartDirection>(PartDirection(
      partDirectionId: 7,
      partDirectionName: StringKeys.leftTail45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[7]),
    ));
    _rightRear = Rx<PartDirection>(PartDirection(
      partDirectionId: 6,
      partDirectionName: StringKeys.rightTail45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[6]),
    ));
    _rear = Rx<PartDirection>(PartDirection(
      partDirectionId: 5,
      partDirectionName: StringKeys.carTail,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[5]),
    ));
  }

  var claimID = ''.obs;
  var isCreatingClaim = false.obs;

  Future<void> _createAndCallImage() async {
    isCreatingClaim(true);
    // _createClaimFolder().whenComplete(() {
    //   isCreatingClaim(false);
    // });
    _createClaimFolder().then((value) async {
      if (value != null) {
        claimID.value = value;
        await _getAllImageInClaimFolder();
      }
    }).whenComplete(() => isCreatingClaim(false));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
        // future: _createAndCallImage(),
        // builder: (context, AsyncSnapshot<String> snapShot) {
        () {
      if (isCreatingClaim.isTrue) {
        return Center(
            child: widget.loadingWidget ?? const CircularProgressIndicator());
      }
      if (isCreatingClaim.isFalse) {
        if (claimID.isEmpty) {
          return Container();
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryImagesSection(
                      claimId: claimID.value,
                      token: widget.uTokenKey,
                      sessionId: widget.sessionId,
                      images: _summaryImages,
                      onError: (message) {
                        if (widget.onError != null) {
                          widget.onError(message);
                        }
                      },
                      imagesOnChanged: (images) {
                        _summaryImages = images;
                      },
                    ),
                    _partDirectionsSection(),
                  ],
                ),
              ),
            ),
            Obx(() {
              bool isHaveImage = _listPartDirections.any((element) {
                if (element.value.images.isNotEmpty ||
                    element.value.imageFiles.isNotEmpty) {
                  return true;
                } else {
                  return false;
                }
              });
              if (isHaveImage) {
                return SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          // minSize: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: DefaultColors.primaryA200,
                          child: Text(
                            'Lưu kết quả',
                            style: TextStyle(color: DefaultColors.primaryA500),
                          ),
                          onPressed: () async {
                            var result = await _getDamageAssessment();
                            if (widget.onGetResultCallBack != null) {
                              widget.onGetResultCallBack(result);
                            }
                            if (result != null) {
                              _sendDamageAssessmentResultToPTI(result);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CupertinoButton(
                          // minSize: 0,
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(8),
                          color: DefaultColors.primaryA500, //blue
                          child: Text(
                            'Xem kết quả',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            var result = await _getDamageAssessment();
                            if (widget.onGetResultCallBack != null) {
                              widget.onGetResultCallBack(result);
                            }
                            // _goToDamageResultPage(
                            //     PTIDamageSumary(results: [], sumaryPrice: 100));
                            if (result != null) {
                              var data = PTIDamageSumary.fromJson(result);
                              _goToDamageResultPage(data);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            }),
          ],
        );
      } else {
        return Container();
      }
    });
  }

  Widget _partDirectionsSection() {
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
                            ..._listPartDirections.map((carDirection) {
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
                                        ? () => _goToCameraPage(carDirection)
                                        : () => _goToPreviewPage(carDirection),
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

  // Tạo folder phía AICycle
  Future<String> _createClaimFolder() async {
    RestfulModule restfulModule = RestfulModuleImpl();
    try {
      Map<String, dynamic> data = {
        'claimName': 'PTI folder - ${widget.sessionId}',
        'vehicleBrandId': CarBrand.carBrandIds[carBrand].toString(),
        'externalSessionId': widget.sessionId,
        'isClaim': true,
      };

      var response = await restfulModule.post(
        Endpoints.createClaimFolder,
        data,
        token: widget.uTokenKey,
      );
      if (response.body != null) {
        claimId.value = response.body['data'][0]['claimId'].toString();
        _uploadPTIInfomation();
        return response.body['data'][0]['claimId'].toString();
      } else {
        if (widget.onError != null) {
          widget.onError(response.statusMessage ?? 'Package error');
        }
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cung cấp thông tin về phía BE
  Future<void> _uploadPTIInfomation() async {
    RestfulModule restfulModule = RestfulModuleImpl();
    try {
      Map<String, dynamic> data = {
        "ma_dvi": widget.maDonVi,
        "phone": widget.phoneNumber,
        "KIEU_CV": widget.kieuCongViec,
        "loai": widget.loaiCongViec,
        "so_id": widget.sessionId,
        "deviceId": widget.deviceId,
        "ma_dvi_nh": widget.maDonViNguoiDangNhap,
        "nsd_nh": widget.maGiamDinhVien,
        "bien_xe": widget.bienSoXe,
        "HANG_XE": widget.hangXe,
        "HIEU_XE": widget.hieuXe,
      };

      var response = await restfulModule.post(
        Endpoints.postPTIInformation,
        data,
        token: widget.uTokenKey,
      );
      if (response.body != null) {
        return;
      } else {
        if (widget.onError != null) {
          widget.onError(response.statusMessage ?? 'Package error');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getDamageAssessment() async {
    RestfulModule restfulModule = RestfulModuleImpl();
    try {
      ProgressDialog.showWithCircleIndicator(context);
      CommonResponse response = await restfulModule.get(
        Endpoints.getDamageAssessmentResult(widget.sessionId),
        token: widget.uTokenKey,
      );
      ProgressDialog.hide(context);
      if (response.body != null) {
        return response.body as Map<String, dynamic>;
      } else {
        NotificationDialog.show(
          context,
          type: NotiType.error,
          content: StringKeys.haveError,
          confirmCallBack: () {
            if (widget.onError != null) {
              widget.onError('Package error: http code ${response.statusCode}');
            }
          },
        );
        return null;
      }
    } catch (e) {
      // ProgressDialog.hide(context);
      if (widget.onError != null) {
        widget.onError('Package error: $e');
      }
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
            widget.onError(response.statusMessage ?? 'Package error');
          }
        }
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError('Package get images error: $e');
      }
      rethrow;
    }
  }

  void _goToDamageResultPage(PTIDamageSumary data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DamageResultPage(
          damage: data,
          onError: widget.onError,
          sessionId: widget.sessionId,
          token: widget.uTokenKey,
        ),
      ),
    );
  }

  void _goToPreviewPage(Rx<PartDirection> partDirection) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewAllImagePage(
          cameraArgument: CameraArgument(
            carBrand: carBrand,
            partDirection: partDirection.value,
            claimId: claimId.value,
            imageRangeId: 1,
          ),
          sessionId: widget.sessionId,
          token: widget.uTokenKey,
          onError: (message) {
            if (widget.onError != null) {
              widget.onError(message);
            }
          },
        ),
      ),
    ).then((value) {
      if (value is PartDirection) {
        setState(() {
          partDirection.value = value;
        });
        _getAllImageInClaimFolder();
      }
    });
  }

  void _goToCameraPage(Rx<PartDirection> partDirection) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          token: widget.uTokenKey,
          sessionId: widget.sessionId,
          onError: widget.onError ?? (message) {},
          cameraArgument: CameraArgument(
            partDirection: partDirection.value,
            claimId: claimId.value,
            imageRangeId: 1,
            carBrand: carBrand,
          ),
        ),
      ),
    ).then((value) {
      if (value is CameraArgument) {
        partDirection.value = value.partDirection;
      }
      _getAllImageInClaimFolder();
    });
  }

  Future<void> _sendDamageAssessmentResultToPTI(
      Map<String, dynamic> result) async {
    RestfulModule restfulModule = RestfulModuleImpl();
    ProgressDialog.showWithCircleIndicator(context);
    try {
      CommonResponse response = await restfulModule.post(
        Endpoints.sendDamageAssessmentResultToPTI(widget.sessionId),
        {},
        token: widget.uTokenKey,
      );
      if (response.statusCode == 200 && response.body != null) {
        await _getAllImageInClaimFolder();
        ProgressDialog.hide(context);
        NotificationDialog.show(
          context,
          type: NotiType.success,
          content: StringKeys.saveSuccessfuly,
          confirmCallBack: () {
            if (widget.onGetResultCallBack != null) {
              widget.onGetResultCallBack(result);
            }
          },
        );
      } else {
        ProgressDialog.hide(context);
        NotificationDialog.show(
          context,
          type: NotiType.error,
          content: StringKeys.haveError,
          confirmCallBack: () {
            if (widget.onError != null) {
              widget.onError('Package error: http code ${response.statusCode}');
            }
          },
        );
        return null;
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError('Package error: $e');
      }
      rethrow;
    }
  }
}
