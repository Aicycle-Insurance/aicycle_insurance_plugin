import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../aicycle_insurance.dart';
import '../../types/part_direction.dart';
import '../../types/car_part.dart';
import '../../types/damage_assessment.dart';
import '../constants/shot_range.dart';
import '../common/snack_bar/snack_bar.dart';
import '../constants/endpoints.dart';
import '../utils/upload_image_to_s3.dart';
import '../modules/resful_module.dart';
import '../modules/resful_module_impl.dart';
import '../constants/colors.dart';
import '../utils/compress_image.dart';
import '../constants/strings.dart';
import '../common/dialog/process_dialog.dart';
import 'bottom_action_bar/bottom_action_bar.dart';
import 'camera_argument.dart';
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

  Rx<CameraArgument> _currentArg;
  TabController _tabController;
  Rx<File> _previewFile;
  Rx<DamageAssessmentModel> _damageAssessment;
  var listCarPartFromMiddleView = <String, CarPart>{}.obs;
  Rx<CarPart> _carPartOnSelected;

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
    _tabController = TabController(length: 3, vsync: this);
    _previewFile = Rx<File>(null);
    _damageAssessment = Rx<DamageAssessmentModel>(null);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.black,
            leadingWidth: 0,
            toolbarHeight: toolbarHeight,
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
                                        thumbColor: Colors.white,
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
                          if (_previewFile.value != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: RotatedBox(
                                quarterTurns: 0,
                                child: PreviewImageWithMask(
                                  damageAssess: _damageAssessment,
                                  previewFile: _previewFile,
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
                    onTap: () => Get.back(result: e),
                    minLeadingWidth: 30,
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
      CommonSnackbar.show(
        context,
        type: SnackbarType.error,
        message: StringKeys.noCameraPermission,
      );
    }
  }

  void _changeTab(int index) {
    if (index == 2 && listCarPartFromMiddleView.isEmpty) {
      CommonSnackbar.show(
        context,
        type: SnackbarType.warning,
        message: 'Bạn cần chụp ảnh trung cảnh hợp lệ trước.',
      );
      _changeTab(1);
    } else {
      _previewFile.value = null;
      currentTabIndex.value = index;
      _tabController.animateTo(index);
    }
  }

  void _galleryPicker() async {
    final ImagePicker _picker = ImagePicker();
    var pickedFile = await _picker.getImage(source: ImageSource.gallery);
    File file = File.fromRawPath(await pickedFile.readAsBytes());
    if (file != null) {
      /// Tạo đường dẫn tạm
      final Directory extDir = await getTemporaryDirectory();
      final appImageDir =
          await Directory('${extDir.path}/app_images').create(recursive: true);
      final String filePath =
          '${appImageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      /// compress ảnh -> full HD
      var _resizeFile = File(filePath);
      _resizeFile = await ImageUtils.compressImage(File(file.path));
      // _resizeFile.saveTo(filePath);
      _previewFile.value = _resizeFile;

      /// Call engine
      await _callAiEngine(_resizeFile.path);
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

    /// compress ảnh -> full HD
    var file = File(filePath);
    file = await ImageUtils.compressImage(File(filePath));
    // file.saveTo(filePath);
    _previewFile.value = file;

    /// Call engine
    await _callAiEngine(filePath);
  }

  Future<void> _callAiEngine(String imageFilePath) async {
    ProgressDialog.showWithCircleIndicator(context, isLandScape: true);
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
          _damageAssessment.value =
              DamageAssessmentModel.fromJson(callEngineResponse.body);

          /// gán ảnh cho part direction
          var temp = _currentArg.value.partDirection.imageFiles.toList();
          temp.add(
            XFileWithId(
              imageId: _damageAssessment.value.imageId,
              file: _previewFile.value,
            ),
          );
          _currentArg.value.partDirection.imageFiles = temp;

          /// gán chi tiết từng góc ảnh
          switch (currentTabIndex.value) {
            case 0:
              var temp =
                  _currentArg.value.partDirection.overViewImageFiles.toList();
              temp.assignAll([
                XFileWithId(
                  imageId: _damageAssessment.value.imageId,
                  file: _previewFile.value,
                )
              ]);
              _currentArg.value.partDirection.overViewImageFiles = temp;
              break;
            case 1:
              var temp =
                  _currentArg.value.partDirection.middleViewImageFiles.toList();
              temp.add(XFileWithId(
                imageId: _damageAssessment.value.imageId,
                file: _previewFile.value,
              ));
              _currentArg.value.partDirection.middleViewImageFiles = temp;

              /// thêm danh sách các bộ phận có hư hại để chụp cận cảnh
              for (CarPart obj in _damageAssessment.value.carParts ?? []) {
                if (obj.carPartDamages.isNotEmpty) {
                  listCarPartFromMiddleView[obj.uuid] = obj;
                }
              }
              if (listCarPartFromMiddleView.isNotEmpty) {
                _carPartOnSelected =
                    Rx<CarPart>(listCarPartFromMiddleView.values.first);
              }

              break;
            case 2:
              var temp =
                  _currentArg.value.partDirection.closeViewImageFiles.toList();
              temp.add(XFileWithId(
                imageId: _damageAssessment.value.imageId,
                file: _previewFile.value,
              ));
              _currentArg.value.partDirection.closeViewImageFiles = temp;
              break;
          }
        }
      }
      ProgressDialog.hide(context);
    } catch (e) {
      widget.onError('Package: System error!');
      ProgressDialog.hide(context);
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
