import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/camera_view/camera_argument.dart';
import '../../../src/camera_view/camera_page.dart';
import '../../../src/common/dialog/notification_dialog.dart';
import '../../../src/common/dialog/process_dialog.dart';
import '../../../src/constants/car_brand.dart';
import '../../../src/constants/car_part_direction.dart';
import '../../../src/constants/endpoints.dart';
import '../../../src/constants/strings.dart';
import '../../../src/damage_result_page/damage_result_page.dart';
import '../../../src/modules/module_types/common_response.dart';
import '../../../src/modules/resful_module.dart';
import '../../../src/modules/resful_module_impl.dart';
import '../../../src/preview_all_image/preview_all_image_page.dart';
import '../../../types/damage_summary_result.dart';
import '../../../types/image.dart';
import '../../../types/image_range.dart';
import '../../../types/part_direction.dart';
import '../../../types/part_direction_meta.dart';
import '../../../types/summary_image.dart';

class ClaimArgument {
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

  ClaimArgument({
    this.sessionId,
    this.uTokenKey,
    this.loadingWidget,
    this.onError,
    this.onGetResultCallBack,
    this.maDonVi,
    this.kieuCongViec,
    this.loaiCongViec,
    this.deviceId,
    this.hangXe,
    this.hieuXe,
    this.maDonViNguoiDangNhap,
    this.maGiamDinhVien,
    this.bienSoXe,
    this.phoneNumber,
  });
}

class ClaimFolderController extends GetxController {
  final ClaimArgument claimArgument;
  ClaimFolderController(this.claimArgument);

  final carBrand = CarBrandType.kiaMorning;
  var summaryImages = <SummaryImage>[];
  var claimID = ''.obs;
  var isCreatingClaim = false.obs;

  /// 6 góc chụp
  /// trái trước
  Rx<PartDirection> front45Left;

  /// trước
  Rx<PartDirection> frontStraight;

  /// phải trước
  Rx<PartDirection> front45Right;

  /// phải sau
  Rx<PartDirection> leftRear;

  /// sau
  Rx<PartDirection> rear;

  /// phải sau
  Rx<PartDirection> rightRear;

  List<Rx<PartDirection>> get listPartDirections {
    return [
      front45Left,
      frontStraight,
      front45Right,
      leftRear,
      rightRear,
      rear,
    ];
  }

  @override
  void onInit() {
    super.onInit();
    initPartDirection();
    createAndCallImage();
  }

  void initPartDirection() {
    front45Left = Rx<PartDirection>(PartDirection(
      partDirectionId: 9,
      partDirectionName: StringKeys.leftHead45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[9]),
    ));
    frontStraight = Rx<PartDirection>(PartDirection(
      partDirectionId: 2,
      partDirectionName: StringKeys.carHead,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[2]),
    ));
    front45Right = Rx<PartDirection>(PartDirection(
      partDirectionId: 8,
      partDirectionName: StringKeys.rightHead45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[8]),
    ));
    leftRear = Rx<PartDirection>(PartDirection(
      partDirectionId: 11,
      partDirectionName: StringKeys.leftTail45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[11]),
    ));
    rightRear = Rx<PartDirection>(PartDirection(
      partDirectionId: 10,
      partDirectionName: StringKeys.rightTail45,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[10]),
    ));
    rear = Rx<PartDirection>(PartDirection(
      partDirectionId: 5,
      partDirectionName: StringKeys.carTail,
      meta: PartDirectionMeta.fromJson(CarPartConstant.directionMetas[5]),
    ));
  }

  Future<void> createAndCallImage() async {
    isCreatingClaim(true);
    createClaimFolder().then((value) async {
      if (value != null) {
        claimID.value = value;
        await getAllImageInClaimFolder();
      }
    }).whenComplete(() => isCreatingClaim(false));
  }

  // Tạo folder phía AICycle
  Future<String> createClaimFolder() async {
    RestfulModule restfulModule = RestfulModuleImpl();
    try {
      Map<String, dynamic> data = {
        'claimName': 'PTI folder - ${claimArgument.sessionId}',
        'vehicleBrandId': CarBrand.carBrandIds[carBrand].toString(),
        'externalSessionId': claimArgument.sessionId,
        'isClaim': true,
      };

      var response = await restfulModule.post(
        Endpoints.createClaimFolder,
        data,
        token: claimArgument.uTokenKey,
      );
      if (response.body != null) {
        claimID.value = response.body['data'][0]['claimId'].toString();
        uploadPTIInfomation();
        return response.body['data'][0]['claimId'].toString();
      } else {
        if (claimArgument.onError != null) {
          claimArgument.onError(response.statusMessage ?? 'Package error');
        }
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cung cấp thông tin về phía BE
  Future<void> uploadPTIInfomation() async {
    RestfulModule restfulModule = RestfulModuleImpl();
    try {
      Map<String, dynamic> data = {
        "ma_dvi": claimArgument.maDonVi,
        "phone": claimArgument.phoneNumber,
        "KIEU_CV": claimArgument.kieuCongViec,
        "loai": claimArgument.loaiCongViec,
        "so_id": claimArgument.sessionId,
        "deviceId": claimArgument.deviceId,
        "ma_dvi_nh": claimArgument.maDonViNguoiDangNhap,
        "nsd_nh": claimArgument.maGiamDinhVien,
        "bien_xe": claimArgument.bienSoXe,
        "HANG_XE": claimArgument.hangXe,
        "HIEU_XE": claimArgument.hieuXe,
      };

      var response = await restfulModule.post(
        Endpoints.postPTIInformation,
        data,
        token: claimArgument.uTokenKey,
      );
      if (response.body != null) {
        return;
      } else {
        if (claimArgument.onError != null) {
          claimArgument.onError(response.statusMessage ?? 'Package error');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getAllImageInClaimFolder() async {
    try {
      RestfulModule restfulModule = RestfulModuleImpl();

      /// Gọi lấy ảnh từng góc chụp
      for (var _part in listPartDirections) {
        var response = await restfulModule.get(
          Endpoints.getImageInCLaim(claimArgument.sessionId),
          token: claimArgument.uTokenKey,
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
          if (claimArgument.onError != null) {
            claimArgument.onError(response.statusMessage ?? 'Package error');
          }
        }
      }
    } catch (e) {
      if (claimArgument.onError != null) {
        claimArgument.onError('Package get images error: $e');
      }
      rethrow;
    }
  }

  void goToDamageResultPage(BuildContext context, PTIDamageSumary data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DamageResultPage(
          damage: data,
          onError: claimArgument.onError,
          sessionId: claimArgument.sessionId,
          token: claimArgument.uTokenKey,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getDamageAssessment(BuildContext context) async {
    RestfulModule restfulModule = RestfulModuleImpl();
    try {
      ProgressDialog.showWithCircleIndicator(context);
      CommonResponse response = await restfulModule.get(
        Endpoints.getDamageAssessmentResult(claimArgument.sessionId),
        token: claimArgument.uTokenKey,
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
            if (claimArgument.onError != null) {
              claimArgument
                  .onError('Package error: http code ${response.statusCode}');
            }
          },
        );
        return null;
      }
    } catch (e) {
      // ProgressDialog.hide(context);
      if (claimArgument.onError != null) {
        claimArgument.onError('Package error: $e');
      }
      rethrow;
    }
  }

  void goToPreviewPage(
      BuildContext context, Rx<PartDirection> partDirection) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewAllImagePage(
          cameraArgument: CameraArgument(
            carBrand: carBrand,
            partDirection: partDirection.value,
            claimId: claimID.value,
            imageRangeId: 1,
          ),
          sessionId: claimArgument.sessionId,
          token: claimArgument.uTokenKey,
          onError: (message) {
            if (claimArgument.onError != null) {
              claimArgument.onError(message);
            }
          },
        ),
      ),
    ).then((value) {
      if (value is PartDirection) {
        // setState(() {
        partDirection.value = value;
        // });
        getAllImageInClaimFolder();
      }
    });
  }

  void goToCameraPage(
      BuildContext context, Rx<PartDirection> partDirection) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          cameraArgument: CameraArgument(
            partDirection: partDirection.value,
            claimId: claimID.value,
            imageRangeId: 1,
            carBrand: carBrand,
            token: claimArgument.uTokenKey,
            sessionId: claimArgument.sessionId,
            onError: claimArgument.onError ?? (message) {},
          ),
        ),
      ),
    ).then((value) {
      if (value is CameraArgument) {
        partDirection.value = value.partDirection;
      }
      getAllImageInClaimFolder();
    });
  }

  Future<void> sendDamageAssessmentResultToPTI(
      BuildContext context, Map<String, dynamic> result) async {
    RestfulModule restfulModule = RestfulModuleImpl();
    ProgressDialog.showWithCircleIndicator(context);
    try {
      CommonResponse response = await restfulModule.post(
        Endpoints.sendDamageAssessmentResultToPTI(claimArgument.sessionId),
        {},
        token: claimArgument.uTokenKey,
      );
      if (response.statusCode == 200 && response.body != null) {
        await getAllImageInClaimFolder();
        ProgressDialog.hide(context);
        NotificationDialog.show(
          context,
          type: NotiType.success,
          content: StringKeys.saveSuccessfuly,
          confirmCallBack: () {
            if (claimArgument.onGetResultCallBack != null) {
              claimArgument.onGetResultCallBack(result);
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
            if (claimArgument.onError != null) {
              claimArgument
                  .onError('Package error: http code ${response.statusCode}');
            }
          },
        );
        return null;
      }
    } catch (e) {
      if (claimArgument.onError != null) {
        claimArgument.onError('Package error: $e');
      }
      rethrow;
    }
  }

  void showResultTapped(BuildContext context) async {
    var result = await getDamageAssessment(context);
    if (claimArgument.onGetResultCallBack != null) {
      claimArgument.onGetResultCallBack(result);
    }
    // _goToDamageResultPage(
    //     PTIDamageSumary(results: [], sumaryPrice: 100));
    if (result != null) {
      var data = PTIDamageSumary.fromJson(result);
      goToDamageResultPage(context, data);
    }
  }

  void saveResultTapped(BuildContext context) async {
    var result = await getDamageAssessment(context);
    if (claimArgument.onGetResultCallBack != null) {
      claimArgument.onGetResultCallBack(result);
    }
    if (result != null) {
      sendDamageAssessmentResultToPTI(context, result);
    }
  }
}
