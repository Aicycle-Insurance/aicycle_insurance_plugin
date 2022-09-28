import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../../src/utils/compress_image.dart';
import '../../src/common/dialog/notification_dialog.dart';
import '../../src/summary_camera/summary_action_bar.dart';
import '../../types/summary_image.dart';
// import '../../src/constants/colors.dart';
import '../../src/constants/strings.dart';

class SummaryCameraPage extends StatefulWidget {
  SummaryCameraPage({Key key, this.images = const []}) : super(key: key);

  final List<SummaryImage> images;

  @override
  _SummaryCameraPageState createState() => _SummaryCameraPageState();
}

class _SummaryCameraPageState extends State<SummaryCameraPage> {
  final double toolbarHeight = 40.0;

  final flashMode = ValueNotifier(CameraFlashes.NONE);

  final sensor = ValueNotifier(Sensors.BACK);

  final captureMode = ValueNotifier(CaptureModes.PHOTO);

  final photoSize = ValueNotifier(const Size(1600, 1200));

  final PictureController pictureController = PictureController();

  var _images = <SummaryImage>[].obs;
  Rx<File> previewFile = Rx<File>(null);

  @override
  void initState() {
    super.initState();
    _images.assignAll(widget.images);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                child: Text(
                  StringKeys.overView,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                height: 60,
                width: 60,
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Flexible(
              child: Obx(() {
                return Stack(
                  children: [
                    CameraAwesome(
                      onPermissionsResult: (result) =>
                          _handleCameraDoNotHavePermission(result),
                      selectDefaultSize: (List<Size> availableSizes) {
                        return availableSizes[1];
                      },
                      sensor: sensor,
                      photoSize: photoSize,
                      switchFlashMode: flashMode,
                      captureMode: captureMode,
                    ),
                    if (previewFile.value != null &&
                        previewFile.value.path != null)
                      RotatedBox(
                        quarterTurns: 1,
                        child: Image.file(
                          previewFile.value,
                          fit: BoxFit.cover,
                        ),
                      )
                  ],
                );
              }),
            ),
            SummaryActionBar(
              networkImages: _images,
              flashMode: flashMode,
              onTakePicture: _takePicture,
            ),
          ],
        ),
      ),
    );
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
    previewFile.value = File(filePath);

    /// lưu ảnh
    // GallerySaver.saveImage(filePath);
    ImageGallerySaver.saveFile(filePath);

    /// compress ảnh -> full HD
    final file = await ImageUtils.compressImage(File(filePath));
    // file.saveTo(filePath); todo
    SummaryImage temp = SummaryImage(localFilePath: file.path);
    _images.add(temp);
    previewFile.value = null;
  }

  void _handleCameraDoNotHavePermission(bool value) {
    if (value == null || value == false) {
      Navigator.pop(context);
      NotificationDialog.show(
        context,
        type: NotiType.error,
        content: StringKeys.noCameraPermission,
        confirmCallBack: () {},
      );
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, _images);
    return false;
  }
}
