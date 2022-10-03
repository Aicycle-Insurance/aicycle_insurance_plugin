import 'dart:io';
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../aicycle_insurance.dart';
import '../../../src/camera_view/camera_argument.dart';
import '../../../src/common/dialog/notification_dialog.dart';
import '../../../src/common/dialog/process_dialog.dart';
import '../../../src/constants/colors.dart';
import '../../../src/constants/endpoints.dart';
import '../../../src/modules/resful_module.dart';
import '../../../src/modules/resful_module_impl.dart';
import '../../../src/utils/compress_image.dart';
import '../../../src/utils/upload_image_to_s3.dart';
import '../../../types/damage_assessment.dart';
import '../../../types/image.dart';
import '../../../types/image_range.dart';

class CameraController extends GetxController
    with SingleGetTickerProviderMixin {
  final CameraArgument pageArg;
  CameraController({this.pageArg});
  // Tab
  TabController tabController;
  var currentTabIndex = 0.obs;
  Rx<CameraArgument> currentArg;

  Rx<PickedFile> previewFile = Rx<PickedFile>(null);
  Rx<DamageAssessmentModel> damageAssessment = Rx<DamageAssessmentModel>(null);

  var listCarPartFromMiddleView = <String, DamagePart>{}.obs;
  Rx<DamagePart> carPartOnSelected = Rx<DamagePart>(null);
  var previewUserMaskImagesBuffer = <Uint8List>[].obs;
  var isOverViewSubmited = false.obs;

  /// camera
  final flashMode = ValueNotifier(CameraFlashes.NONE);
  final sensor = ValueNotifier(Sensors.BACK);
  final captureMode = ValueNotifier(CaptureModes.PHOTO);
  final photoSize = ValueNotifier(const Size(1080, 1920));
  final PictureController pictureController = PictureController();

  /// khung chụp
  var scaleImageValue = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    currentArg = Rx<CameraArgument>(pageArg);
    currentTabIndex.value = currentArg.value.imageRangeId - 1;
    tabController = TabController(
        length: 3, vsync: this, initialIndex: currentTabIndex.value);
    checkInitCarPart();
    checkSubmited();
  }

  @override
  void onClose() {
    flashMode.dispose();
    sensor.dispose();
    captureMode.dispose();
    photoSize.dispose();
    super.onClose();
  }

  void checkInitCarPart() {
    listCarPartFromMiddleView.clear();
    for (var image in currentArg.value.partDirection.value.images) {
      if (image.damageParts.isNotEmpty ?? false) {
        for (var part in image.damageParts) {
          listCarPartFromMiddleView[part.vehiclePartExcelId] = part;
        }
      }
    }
    if (listCarPartFromMiddleView.isNotEmpty &&
        (carPartOnSelected == null || carPartOnSelected.value == null)) {
      carPartOnSelected =
          Rx<DamagePart>(listCarPartFromMiddleView.values.first);
    }
  }

  void checkSubmited() {
    if (currentArg.value.partDirection.value.overViewImages.isNotEmpty) {
      isOverViewSubmited.value = currentArg
              .value.partDirection.value.overViewImages.first.isSendToPti ??
          false;
    }
  }

  void autoSwitchTab(BuildContext context) {
    switch (currentTabIndex.value) {
      case 0:
        changeTab(context, 1);
        break;
      case 1:
        changeTab(context, 2);
        break;
    }
  }

  void changeTab(BuildContext context, int index) {
    ///clear previous mask
    previewUserMaskImagesBuffer.clear();
    if (index == 0 && isOverViewSubmited == true) {
      NotificationDialog.show(
        context,
        type: NotiType.warning,
        content: 'Bạn đã không thể thay đổi ảnh toàn cảnh khi đã Lưu kết quả.',
        confirmCallBack: () => changeTab(context, 1),
      );
    }
    if (index == 2 && listCarPartFromMiddleView.isEmpty) {
      NotificationDialog.show(
        context,
        type: NotiType.warning,
        content: 'Bạn cần chụp ảnh toàn cảnh hoặc trung cảnh hợp lệ trước.',
        confirmCallBack: () => changeTab(context, 1),
      );
    } else {
      previewFile.value = null;
      currentTabIndex.value = index;
      tabController.animateTo(index);
    }
  }

  Future<bool> onWillPop(BuildContext context) async {
    Navigator.pop<CameraArgument>(context, currentArg.value);
    return false;
  }

  void selectCarPart(BuildContext context) async {
    var result = await showDialog(
      context: context,
      builder: (context) => RotatedBox(
        quarterTurns: 1,
        child: AlertDialog(
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: listCarPartFromMiddleView.values
                .map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.pop(context, e),
                    // minLeadingWidth: 30,
                    leading: SizedBox(
                      width: 24,
                      child: e.vehiclePartExcelId ==
                              carPartOnSelected.value.vehiclePartExcelId
                          ? const Icon(
                              Icons.check,
                              color: DefaultColors.green400,
                            )
                          : null,
                    ),
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: e.vehiclePartNamge ?? '',
                          ),
                          TextSpan(
                            text: ' (${e.numOfCloseImage.toString()} ảnh)',
                            style: TextStyle(color: DefaultColors.ink400),
                          )
                        ],
                      ),
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
      carPartOnSelected.value = result;
    }
  }

  void galleryPicker(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    PickedFile file = await _picker.getImage(source: ImageSource.gallery);
    if (file != null) {
      /// compress ảnh -> 1600x1200
      var _resizeFile = await ImageUtils.compressImage(File(file.path));
      // _resizeFile.saveTo(filePath);  todo
      previewFile.value = _resizeFile;

      ///clear previous mask
      previewUserMaskImagesBuffer.clear();
      damageAssessment.value = null;

      /// Call engine
      await _callAiEngine(context, _resizeFile.path);
      if (currentTabIndex == 2) {
        changeTab(context, 2);
      }
    }
  }

  void takePicture(BuildContext context) async {
    /// Tạo đường dẫn tạm
    final Directory extDir = await getTemporaryDirectory();
    final appImageDir =
        await Directory('${extDir.path}/app_images').create(recursive: true);
    final String filePath =
        '${appImageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    /// chụp ảnh
    await pictureController.takePicture(filePath);

    /// lưu ảnh
    // GallerySaver.saveImage(filePath);
    ImageGallerySaver.saveFile(filePath);

    /// compress ảnh -> full HD
    final file = await ImageUtils.compressImage(File(filePath));
    // file.saveTo(filePath); todo
    previewFile.value = PickedFile(file.path);

    ///clear previous mask
    previewUserMaskImagesBuffer.clear();
    damageAssessment.value = null;

    /// Call engine
    await _callAiEngine(context, file.path);
    if (currentTabIndex == 2) {
      changeTab(context, 2);
    }
  }

  Future<void> _callAiEngine(BuildContext context, String imageFilePath,
      [bool hasLoading = true]) async {
    if (hasLoading) {
      ProgressDialog.showWithCircleIndicator(context, isLandScape: true);
    }
    try {
      /// upload ảnh lên server AICycle
      var uploadResponse = await upLoadImageToS3(
          token: currentArg.value.token, imageFiles: imageFilePath);

      if (uploadResponse != null) {
        /// call AI engine detect vết hỏng
        RestfulModule restfulModule = RestfulModuleImpl();
        var callEngineResponse = await restfulModule.post(
          Endpoints.callEngineAfterTakePhoto,
          {
            "claimId": currentArg.value.claimId,
            "imageName": uploadResponse.imageName,
            "filePath": uploadResponse.filePath,
            "imageRangeId": currentTabIndex.value + 1,
            "partDirectionId":
                currentArg.value.partDirection.value.partDirectionId,
            "vehiclePartExcelId": currentTabIndex.value == 2
                ? carPartOnSelected.value.vehiclePartExcelId
                : '',
            "oldImageId": currentArg.value.oldImageId
          },
          token: currentArg.value.token,
        );
        if (callEngineResponse.statusCode == 200) {
          geImageInPartDirection().whenComplete(() {
            switch (currentTabIndex.value) {
              case 0:
              case 1:
                damageAssessment.value =
                    DamageAssessmentModel.fromJson(callEngineResponse.body);
                break;
              case 2:
                damageAssessment.value = DamageAssessmentModel(
                  carDamages: [],
                  carParts: [],
                  imageId:
                      int.parse(callEngineResponse.body['imageId'].toString()),
                  imageSize: [],
                  imgUrl: '',
                );
                break;
            }
            checkInitCarPart();
            if (hasLoading) ProgressDialog.hide(context);
          });
        } else {
          if (hasLoading) ProgressDialog.hide(context);
          NotificationDialog.show(
            context,
            type: NotiType.error,
            content: 'Tải ảnh lên không thành công',
            confirmCallBack: () {
              previewFile.value = null;
            },
          );
        }
      } else {
        if (hasLoading) ProgressDialog.hide(context);
        NotificationDialog.show(
          context,
          type: NotiType.error,
          content: 'Tải ảnh lên không thành công',
          confirmCallBack: () {
            previewFile.value = null;
          },
        );
      }
    } catch (e) {
      if (hasLoading) ProgressDialog.hide(context);
      currentArg.value.onError('Package error: $e');
    }
  }

  String loadImageByVehicleBrand() {
    String imagePath;
    switch (currentArg.value.carBrand) {
      //Check loại xe để lấy khung tương ứng với ảnh
      case CarBrandType.kiaMorning:
        imagePath = currentArg.value.partDirection.value.meta.kiaChassisPath;
        break;
      case CarBrandType.toyotaInnova:
        imagePath = currentArg.value.partDirection.value.meta.innovaChassisPath;
        break;
      case CarBrandType.toyotaCross:
        imagePath = currentArg.value.partDirection.value.meta.chassisPath;
        break;
      case CarBrandType.mazdaCX5:
        imagePath = currentArg.value.partDirection.value.meta.chassisPath;
        break;
      case CarBrandType.toyotaVios:
        imagePath = currentArg.value.partDirection.value.meta.viosChassisPath;
        break;
      default:
        imagePath = currentArg.value.partDirection.value.meta.kiaChassisPath;
        break;
    }
    return imagePath;
  }

  Future<void> geImageInPartDirection() async {
    try {
      RestfulModule restfulModule = RestfulModuleImpl();

      /// Gọi lấy ảnh từng góc chụp
      var response = await restfulModule.get(
        Endpoints.getImageInCLaim(currentArg.value.sessionId),
        token: currentArg.value.token,
        query: {
          "partDirectionId":
              currentArg.value.partDirection.value.partDirectionId.toString(),
        },
      );
      if (response.body != null) {
        List result = response.body['data'];
        List<AiImage> _images = result.map((e) => AiImage.fromJson(e)).toList();

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
        currentArg.value.partDirection.value =
            currentArg.value.partDirection.value.copyWith(
          images: _images,
          overViewImages: _overViewImages,
          closeViewImages: _closeImages,
          middleViewImages: _middleViewImages,
          imageFiles: [],
          overViewImageFiles: [],
          closeViewImageFiles: [],
          middleViewImageFiles: [],
        );
        update(['camera-bottom-bar']);
      } else {
        if (currentArg.value.onError != null) {
          currentArg.value.onError(response.statusMessage ?? 'Package error');
        }
      }
    } catch (e) {
      if (currentArg.value.onError != null) {
        currentArg.value.onError('Package get images error: $e');
      }
      rethrow;
    }
  }

  void drawingToolSaveCallBack(
    BuildContext context,
    List<Uint8List> buffer,
    DamageAssessmentModel reDamageAssessment,
  ) {
    previewUserMaskImagesBuffer.clear();
    damageAssessment.value = reDamageAssessment;
    previewUserMaskImagesBuffer.assignAll(buffer);
    // checkDamageCarPart();
    ProgressDialog.showWithCircleIndicator(context, isLandScape: true);
    geImageInPartDirection().whenComplete(() {
      checkInitCarPart();
      ProgressDialog.hide(context);
    });
  }

  void drawingToolCancelCallBack(BuildContext context) {
    damageAssessment.value = null;
    previewFile.value = null;
    autoSwitchTab(context);
  }
}
