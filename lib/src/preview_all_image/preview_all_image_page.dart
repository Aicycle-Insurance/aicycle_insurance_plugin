import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../camera_view/camera_argument.dart';
import '../camera_view/camera_page.dart';
import '../common/dialog/confirm_dialog.dart';
import '../constants/colors.dart';
import '../constants/endpoints.dart';
import '../constants/strings.dart';
import '../modules/resful_module.dart';
import '../modules/resful_module_impl.dart';
import '../preview_all_image/widgets/close_view_section.dart';
import '../../types/image.dart';
import '../../types/part_direction.dart';
import 'widgets/over_view_section.dart';

class PreviewAllImagePage extends StatefulWidget {
  const PreviewAllImagePage({
    Key? key,
    required this.cameraArgument,
    required this.token,
    required this.onError,
  }) : super(key: key);

  final CameraArgument cameraArgument;
  final String token;
  final Function(String) onError;

  @override
  State<PreviewAllImagePage> createState() => _PreviewAllImagePageState();
}

class _PreviewAllImagePageState extends State<PreviewAllImagePage> {
  final _toolbarHeight = 64.0;
  late Rx<CameraArgument> currentArg;

  @override
  void initState() {
    super.initState();
    currentArg = Rx<CameraArgument>(widget.cameraArgument);
  }

  RxList<AiImage> overviewImages = <AiImage>[].obs;
  RxList<XFileWithId> overviewImageFiles = <XFileWithId>[].obs;
  RxList<AiImage> middleAndCloseImages = <AiImage>[].obs;

  RxList<XFileWithId> middleAndCloseImageFiles = <XFileWithId>[].obs;
  //  {
  //   var imageList = <XFileWithId>[];
  //   imageList.addAll(currentArg.value.partDirection.middleViewImageFiles);
  //   imageList.addAll(currentArg.value.partDirection.closeViewImageFiles);
  //   return imageList;
  // }

  @override
  Widget build(BuildContext context) {
    overviewImages.assignAll(currentArg.value.partDirection.overViewImages);
    overviewImageFiles
        .assignAll(currentArg.value.partDirection.overViewImageFiles);
    middleAndCloseImages
        .addAll(currentArg.value.partDirection.middleViewImages);
    middleAndCloseImages.addAll(currentArg.value.partDirection.closeViewImages);
    middleAndCloseImageFiles
        .addAll(currentArg.value.partDirection.middleViewImageFiles);
    middleAndCloseImageFiles
        .addAll(currentArg.value.partDirection.closeViewImageFiles);

    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0.0,
          toolbarHeight: _toolbarHeight,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: DefaultColors.iconColor),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentArg.value.partDirection.partDirectionName,
                style: const TextStyle(
                    color: DefaultColors.ink500,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            CupertinoButton(
              child: const Icon(
                Icons.delete_outline_rounded,
                color: DefaultColors.red400,
              ),
              onPressed: _deleteAllImages,
            ),
          ],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Obx(
            () {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OverViewSection(
                    imageUrl: overviewImageFiles.isNotEmpty
                        ? overviewImageFiles.first.file.path
                        : overviewImages.isNotEmpty
                            ? overviewImages.first.url
                            : '',
                    onRetake: () => _goToCameraPage(1),
                    onDelete: () => _deleteImageById(
                        overviewImageFiles.isNotEmpty
                            ? overviewImageFiles.first.imageId.toString()
                            : overviewImages.first.imageId),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CloseViewSection(
                      imageFromServers: middleAndCloseImages,
                      imageFiles: middleAndCloseImageFiles,
                      onRetake: () => _goToCameraPage(2),
                      onDelete: (imageId) => _deleteImageById(imageId),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _willPop() async {
    Navigator.pop<CameraArgument>(context, currentArg.value);
    return false;
  }

  void _deleteImageById(String imageId) async {
    try {
      var temp = currentArg.value.partDirection;
      temp.images.removeWhere((element) => element.imageId == imageId);
      temp.imageFiles
          .removeWhere((element) => element.imageId.toString() == imageId);
      // over view
      temp.overViewImages.removeWhere((element) => element.imageId == imageId);
      temp.overViewImageFiles
          .removeWhere((element) => element.imageId.toString() == imageId);
      overviewImages.removeWhere((element) => element.imageId == imageId);
      overviewImageFiles
          .removeWhere((element) => element.imageId.toString() == imageId);
      // middle view
      temp.middleViewImages
          .removeWhere((element) => element.imageId == imageId);
      temp.middleViewImageFiles
          .removeWhere((element) => element.imageId.toString() == imageId);
      // close up view
      temp.closeViewImages.removeWhere((element) => element.imageId == imageId);
      temp.closeViewImageFiles
          .removeWhere((element) => element.imageId.toString() == imageId);
      middleAndCloseImages.removeWhere((element) => element.imageId == imageId);
      middleAndCloseImageFiles
          .removeWhere((element) => element.imageId.toString() == imageId);

      currentArg.value.partDirection = currentArg.value.partDirection.copyWith(
        imageFiles: temp.imageFiles,
        images: temp.images,
        closeViewImageFiles: temp.closeViewImageFiles,
        closeViewImages: temp.closeViewImages,
        middleViewImageFiles: temp.middleViewImageFiles,
        middleViewImages: temp.middleViewImages,
        overViewImageFiles: temp.overViewImageFiles,
        overViewImages: temp.overViewImages,
      );
    } catch (e) {
      widget.onError('Package: Removing image gets error!');
    }

    // delete on server
    try {
      RestfulModule restfulModule = RestfulModuleImpl();
      var response = await restfulModule.delete(
        Endpoints.deleteImageInCLaim(imageId),
        token: widget.token,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        widget.onError(response.statusMessage ?? 'Package error');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _deleteAllImages() async {
    var confirm = await ConfirmDialog.show(
      context,
      content: StringKeys.areYouSureToDeleteImage,
      cancelButtonLabel: StringKeys.dialogCancel,
      confirmButtonLabel: StringKeys.delete,
    );

    if (confirm != null && confirm) {
      try {
        RestfulModule restfulModule = RestfulModuleImpl();
        var response = await restfulModule.delete(
          Endpoints.deleteAllImageInClaim(currentArg.value.sessionId),
          token: widget.token,
          query: {
            'partDirectionId':
                currentArg.value.partDirection.partDirectionId.toString()
          },
        );
        if (response.statusCode != 200 && response.statusCode != 204) {
          widget.onError(response.statusMessage ?? 'Package error');
        } else {
          currentArg.value.partDirection =
              currentArg.value.partDirection.copyWith(
            imageFiles: [],
            images: [],
            closeViewImageFiles: [],
            closeViewImages: [],
            middleViewImageFiles: [],
            middleViewImages: [],
            overViewImageFiles: [],
            overViewImages: [],
          );
          overviewImageFiles.clear();
          overviewImages.clear();
          middleAndCloseImageFiles.clear();
          middleAndCloseImages.clear();
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  void _goToCameraPage(int rangeId) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraPage(
                token: widget.token,
                onError: widget.onError,
                cameraArgument: CameraArgument(
                  partDirection: currentArg.value.partDirection,
                  claimId: currentArg.value.claimId,
                  sessionId: currentArg.value.sessionId,
                  imageRangeId: rangeId,
                  carBrand: currentArg.value.carBrand,
                )))).then((value) {
      if (value is CameraArgument) {
        currentArg.value.partDirection = value.partDirection;
      }
    });
  }
}
