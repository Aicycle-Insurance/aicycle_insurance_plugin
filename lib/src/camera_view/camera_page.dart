import 'dart:io';
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../aicycle_insurance.dart';
import '../../types/car_part.dart';
import '../../types/damage_assessment.dart';
import '../../src/common/dialog/notification_dialog.dart';
import '../../src/drawing_tool/new_drawing_tool.dart';
// import 'package:gallery_saver/gallery_saver.dart';

import '../../types/part_direction.dart';
import '../common/dialog/process_dialog.dart';
// import '../common/snack_bar/snack_bar.dart';
import '../constants/colors.dart';
import '../constants/endpoints.dart';
import '../constants/shot_range.dart';
import '../constants/strings.dart';
import '../modules/resful_module.dart';
import '../modules/resful_module_impl.dart';
import '../utils/compress_image.dart';
import '../utils/upload_image_to_s3.dart';
import 'bottom_action_bar/bottom_action_bar.dart';
import 'camera_argument.dart';
// import 'widgets/drawing_tool_layer.dart';
import 'widgets/preview_with_mask.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    Key key,
    this.cameraArgument,
    this.token,
    this.onError,
  }) : super(key: key);

  final CameraArgument cameraArgument;
  final String token;
  final Function(String message) onError;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  final double toolbarHeight = 80.0;

  var currentTabIndex = 0.obs;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Rx<CameraArgument> _currentArg;
  TabController _tabController;
  Rx<PickedFile> _previewFile;
  Rx<DamageAssessmentModel> _damageAssessment;
  var listCarPartFromMiddleView = <String, CarPart>{}.obs;
  Rx<CarPart> _carPartOnSelected;
  var previewUserMaskImagesBuffer = <Uint8List>[].obs;

  /// camera
  final flashMode = ValueNotifier(CameraFlashes.NONE);
  final sensor = ValueNotifier(Sensors.BACK);
  final captureMode = ValueNotifier(CaptureModes.PHOTO);
  final photoSize = ValueNotifier(const Size(1080, 1920));
  final PictureController pictureController = PictureController();

  /// khung chụp
  var scaleImageValue = 1.0.obs;

  @override
  void initState() {
    super.initState();
    _currentArg = Rx<CameraArgument>(widget.cameraArgument);
    currentTabIndex.value = widget.cameraArgument.imageRangeId - 1;
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: currentTabIndex.value);
    _previewFile = Rx<PickedFile>(null);
    _damageAssessment = Rx<DamageAssessmentModel>(null);
    _checkInitCarPart();
  }

  @override
  dispose() {
    super.dispose();
  }

  _checkInitCarPart() {
    for (var image in _currentArg.value.partDirection.middleViewImages) {
      if (image.damageParts.isNotEmpty ?? false) {
        for (var part in image.damageParts) {
          var _part = CarPart(
            uuid: part.vehiclePartExcelId,
            carPartBoxes: [0, 0, 0, 0],
            carPartClassName: part.vehiclePartNamge ?? '',
            carPartDamages: [],
            carPartIsPart: true,
            carPartMaskPath: '',
            carPartMaskUrl: '',
            color: Colors.amber,
            carPartLocation: '',
            carPartScore: 1,
          );
          listCarPartFromMiddleView[part.vehiclePartExcelId] = _part;
        }
      }
    }
    if (listCarPartFromMiddleView.isNotEmpty) {
      _carPartOnSelected = Rx<CarPart>(listCarPartFromMiddleView.values.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.black,
            leadingWidth: 0,
            toolbarHeight: toolbarHeight + MediaQuery.of(context).padding.top,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  // minSize: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                        StringKeys.close.toUpperCase(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  onPressed: _onWillPop,
                ),
                Center(
                  child: Obx(
                    () => Text(
                      _currentArg.value.partDirection.partDirectionName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DefaultColors.ink100,
                      border: Border.all(width: 1, color: DefaultColors.ink100),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      CupertinoIcons.photo_on_rectangle,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: _galleryPicker,
                )
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              onTap: _changeTab,
              tabs: const <Widget>[
                Tab(
                  text: StringKeys.overViewShot,
                ),
                Tab(
                  text: StringKeys.middleViewShot,
                ),
                Tab(
                  text: StringKeys.closeUpViewShot,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    /// Camera view
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: CameraAwesome(
                        onPermissionsResult: (result) =>
                            _handleCameraDoNotHavePermission(result),
                        selectDefaultSize: (List<Size> availableSizes) =>
                            availableSizes[1],
                        sensor: sensor,
                        photoSize: photoSize,
                        switchFlashMode: flashMode,
                        captureMode: captureMode,
                      ),
                    ),

                    /// Các widgets bổ trợ
                    Obx(() {
                      return Stack(
                        children: [
                          /// Khung xe gợi ý
                          if (_previewFile.value == null &&
                              currentTabIndex.value == 0)
                            Obx(
                              () => SafeArea(
                                child: Center(
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Transform.scale(
                                      scale: scaleImageValue.value,
                                      child: Image.asset(
                                        _loadImageByVehicleBrand(),
                                        fit: BoxFit.cover,
                                        package: packageName,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          /// Thanh chỉnh độ zoom khung xe
                          if (_previewFile.value == null &&
                              currentTabIndex.value == 0)
                            SafeArea(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: SizedBox(
                                      height: 32,
                                      width: Get.width / 2,
                                      child: Slider.adaptive(
                                        min: 0.5,
                                        max: 1,
                                        activeColor: Colors.white,
                                        // thumbColor: Colors.white,
                                        inactiveColor: Colors.white38,
                                        value: scaleImageValue.value,
                                        onChanged: (value) {
                                          scaleImageValue.value = value;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          /// Preview file kèm mask thiệt hại
                          if (_previewFile.value != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: PreviewImageWithMask(
                                  damageAssess: _damageAssessment,
                                  previewFile: _previewFile,
                                  previewUserMaskImagesBuffer:
                                      previewUserMaskImagesBuffer,
                                ),
                              ),
                            ),

                          /// Tên tab
                          SafeArea(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, right: 16),
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  // child: CarImage3DContainer(),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Obx(
                                        () => Text(
                                          imageRangeIds.keys
                                              .toList()[currentTabIndex.value],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// Chọn bộ phận tab cận cảnh
                          if (currentTabIndex.value == 2 &&
                              listCarPartFromMiddleView.isNotEmpty)
                            SafeArea(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16, right: 16),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    // child: CarImage3DContainer(),
                                    child: GestureDetector(
                                      onTap: _selectCarPart,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Obx(
                                            () => Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _carPartOnSelected
                                                      .value.carPartClassName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: Colors.white,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // if (_damageAssessment.value != null &&
                          //     _previewFile.value != null &&
                          //     currentTabIndex.value != 2)
                          //   RotatedBox(
                          //     quarterTurns: 1,
                          //     child: DrawingToolLayer(
                          //       damageAssess: Rx<DamageAssessmentModel>(
                          //           _damageAssessment.value),
                          //       imageUrl: _previewFile.value.path,
                          //       onCancelCallBack: () {
                          //         _damageAssessment.value = null;
                          //         _previewFile.value = null;
                          //         _autoSwitchTab();
                          //       },
                          //       onSaveCallBack: (buffer) {
                          //         _damageAssessment.value = null;
                          //         previewUserMaskImagesBuffer.assignAll(buffer);
                          //       },
                          //       token: widget.token,
                          //     ),
                          //   )
                          if (_damageAssessment.value != null &&
                              _previewFile.value != null &&
                              currentTabIndex.value != 2)
                            NewDrawingToolLayer(
                              damageAssess: Rx<DamageAssessmentModel>(
                                  _damageAssessment.value),
                              imageUrl: _previewFile.value.path,
                              onCancelCallBack: () {
                                _damageAssessment.value = null;
                                _previewFile.value = null;
                                _autoSwitchTab();
                              },
                              onSaveCallBack: (buffer, reDamageAssessment) {
                                _damageAssessment.value = reDamageAssessment;
                                previewUserMaskImagesBuffer.assignAll(buffer);
                                checkDamageCarPart();
                              },
                              token: widget.token,
                            )
                        ],
                      );
                    }),
                  ],
                ),
              ),
              BottomActionBar(
                currentArg: _currentArg,
                currentTabIndex: currentTabIndex,
                previewFile: _previewFile,
                onTakePicture: _takePicture,
                flashMode: flashMode,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _autoSwitchTab() {
    switch (currentTabIndex.value) {
      case 0:
        _changeTab(1);
        break;
      case 1:
        _changeTab(2);
        break;
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pop<CameraArgument>(context, _currentArg.value);
    return false;
  }

  void _selectCarPart() async {
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
                      child: e.uuid == _carPartOnSelected.value.uuid
                          ? const Icon(
                              Icons.check,
                              color: DefaultColors.green400,
                            )
                          : null,
                    ),
                    title: Text(e.carPartClassName),
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
      _carPartOnSelected.value = result;
    }
  }

  void _handleCameraDoNotHavePermission(bool value) {
    if (value == null || value == false) {
      Navigator.pop(context);
      // CommonSnackbar.show(
      //   context,
      //   type: SnackbarType.error,
      //   message: StringKeys.noCameraPermission,
      // );
      NotificationDialog.show(
        context,
        type: NotiType.error,
        content: StringKeys.noCameraPermission,
        confirmCallBack: () {},
      );
    }
  }

  void _changeTab(int index) {
    ///clear previous mask
    previewUserMaskImagesBuffer.clear();
    if (index == 2 && listCarPartFromMiddleView.isEmpty) {
      // CommonSnackbar.show(
      //   context,
      //   type: SnackbarType.warning,
      //   message: 'Bạn cần chụp ảnh trung cảnh hợp lệ trước.',
      // );
      NotificationDialog.show(
        context,
        type: NotiType.warning,
        content: 'Bạn cần chụp ảnh toàn cảnh hoặc trung cảnh hợp lệ trước.',
        confirmCallBack: () {
          _changeTab(1);
        },
      );
    } else {
      _previewFile.value = null;
      currentTabIndex.value = index;
      _tabController.animateTo(index);
    }
  }

  void _galleryPicker() async {
    final ImagePicker _picker = ImagePicker();
    PickedFile file = await _picker.getImage(source: ImageSource.gallery);
    if (file != null) {
      /// Tạo đường dẫn tạm
      // final Directory extDir = await getTemporaryDirectory();
      // final appImageDir =
      //     await Directory('${extDir.path}/app_images').create(recursive: true);
      // final String filePath =
      //     '${appImageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      /// compress ảnh -> 1600x1200
      var _resizeFile = await ImageUtils.compressImage(File(file.path));
      // _resizeFile.saveTo(filePath);  todo
      _previewFile.value = _resizeFile;

      ///clear previous mask
      previewUserMaskImagesBuffer.clear();

      /// Call engine
      await _callAiEngine(_resizeFile.path);
      if (currentTabIndex == 2) {
        _changeTab(2);
      }
    }
  }

  void _takePicture() async {
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
    _previewFile.value = PickedFile(file.path);

    ///clear previous mask
    previewUserMaskImagesBuffer.clear();

    /// Call engine
    await _callAiEngine(file.path);
    if (currentTabIndex == 2) {
      _changeTab(2);
    }
  }

  Future<void> _callAiEngine(String imageFilePath,
      [bool hasLoading = true]) async {
    if (hasLoading) {
      ProgressDialog.showWithCircleIndicator(context, isLandScape: true);
    }
    try {
      /// upload ảnh lên server AICycle
      var uploadResponse =
          await upLoadImageToS3(token: widget.token, imageFiles: imageFilePath);

      if (uploadResponse != null) {
        /// call AI engine detect vết hỏng
        RestfulModule restfulModule = RestfulModuleImpl();
        var callEngineResponse = await restfulModule.post(
          Endpoints.callEngineAfterTakePhoto,
          {
            "claimId": _currentArg.value.claimId,
            "imageName": uploadResponse.imageName,
            "filePath": uploadResponse.filePath,
            "imageRangeId": currentTabIndex.value + 1,
            "partDirectionId": _currentArg.value.partDirection.partDirectionId,
            "vehiclePartExcelId":
                currentTabIndex.value == 2 ? _carPartOnSelected.value.uuid : '',
          },
          token: widget.token,
        );
        if (callEngineResponse.statusCode == 200) {
          if (currentTabIndex.value != 2) {
            _damageAssessment.value =
                DamageAssessmentModel.fromJson(callEngineResponse.body);
          } else {
            _damageAssessment.value = DamageAssessmentModel(
              carDamages: [],
              carParts: [],
              imageId: int.parse(callEngineResponse.body['imageId'].toString()),
              imageSize: [],
              imgUrl: '',
            );
          }

          /// gán ảnh cho part direction
          var temp = _currentArg.value.partDirection.imageFiles.toList();
          temp.add(
            PickedFileWithId(
              imageId: _damageAssessment.value.imageId,
              file: _previewFile.value,
            ),
          );
          _currentArg.value.partDirection =
              _currentArg.value.partDirection.copyWith(imageFiles: temp);

          /// gán chi tiết từng góc ảnh
          switch (currentTabIndex.value) {
            case 0:
              var temp =
                  _currentArg.value.partDirection.overViewImageFiles.toList();
              temp.assignAll([
                PickedFileWithId(
                  imageId: _damageAssessment.value.imageId,
                  file: _previewFile.value,
                )
              ]);
              _currentArg.value.partDirection = _currentArg.value.partDirection
                  .copyWith(overViewImageFiles: temp);
              // _currentArg.value.partDirection.overViewImageFiles = temp;
              break;
            case 1:
              var temp =
                  _currentArg.value.partDirection.middleViewImageFiles.toList();
              temp.add(PickedFileWithId(
                imageId: _damageAssessment.value.imageId,
                file: _previewFile.value,
              ));
              _currentArg.value.partDirection = _currentArg.value.partDirection
                  .copyWith(middleViewImageFiles: temp);
              // _currentArg.value.partDirection.middleViewImageFiles = temp;

              /// thêm danh sách các bộ phận có hư hại để chụp cận cảnh
              checkDamageCarPart();
              break;
            case 2:
              var temp =
                  _currentArg.value.partDirection.closeViewImageFiles.toList();
              temp.add(PickedFileWithId(
                imageId: _damageAssessment.value.imageId,
                file: _previewFile.value,
              ));
              _currentArg.value.partDirection = _currentArg.value.partDirection
                  .copyWith(closeViewImageFiles: temp);
              break;
          }
        }
      }
      if (hasLoading) ProgressDialog.hide(context);
    } catch (e) {
      widget.onError('Package error: $e');
      if (hasLoading) ProgressDialog.hide(context);
    }
  }

  void checkDamageCarPart() {
    // listCarPartFromMiddleView.clear();

    /// thêm danh sách các bộ phận có hư hại để chụp cận cảnh
    for (CarPart obj in _damageAssessment.value.carParts ?? []) {
      if (obj.carPartDamages.isNotEmpty) {
        print(obj.uuid);
        listCarPartFromMiddleView[obj.uuid] = obj;
      }
    }
    if (listCarPartFromMiddleView.isNotEmpty) {
      _carPartOnSelected = Rx<CarPart>(listCarPartFromMiddleView.values.first);
    }
  }

  String _loadImageByVehicleBrand() {
    String imagePath;
    switch (_currentArg.value.carBrand) {
      //Check loại xe để lấy khung tương ứng với ảnh
      case CarBrandType.kiaMorning:
        imagePath = _currentArg.value.partDirection.meta.kiaChassisPath;
        break;
      case CarBrandType.toyotaInnova:
        imagePath = _currentArg.value.partDirection.meta.innovaChassisPath;
        break;
      case CarBrandType.toyotaCross:
        imagePath = _currentArg.value.partDirection.meta.chassisPath;
        break;
      case CarBrandType.mazdaCX5:
        imagePath = _currentArg.value.partDirection.meta.chassisPath;
        break;
      case CarBrandType.toyotaVios:
        imagePath = _currentArg.value.partDirection.meta.viosChassisPath;
        break;
      default:
        imagePath = _currentArg.value.partDirection.meta.kiaChassisPath;
        break;
    }
    return imagePath;
  }
}
