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
    Key key,
    this.cameraArgument,
    this.token,
    this.sessionId,
    this.onError,
  }) : super(key: key);

  final CameraArgument cameraArgument;
  final String token;
  final String sessionId;
  final Function(String) onError;

  @override
  State<PreviewAllImagePage> createState() => _PreviewAllImagePageState();
}

class _PreviewAllImagePageState extends State<PreviewAllImagePage> {
  final _toolbarHeight = 64.0;
  Rx<CameraArgument> currentArg;
  var isSubmited = false.obs;

  @override
  void initState() {
    super.initState();
    currentArg = Rx<CameraArgument>(widget.cameraArgument);
  }

  @override
  Widget build(BuildContext context) {
    checkAssessmentSubmited();
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
            Obx(
              () => isSubmited.isFalse
                  ? CupertinoButton(
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: DefaultColors.red400,
                      ),
                      onPressed: _deleteAllImages,
                    )
                  : Container(),
            ),
          ],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Obx(
            () {
              // image server
              var imageList = <AiImage>[];
              imageList.addAll(currentArg.value.partDirection.middleViewImages);
              imageList.addAll(currentArg.value.partDirection.closeViewImages);
              // image file
              var imageFiles = <PickedFileWithId>[];
              imageFiles
                  .addAll(currentArg.value.partDirection.middleViewImageFiles);
              imageFiles
                  .addAll(currentArg.value.partDirection.closeViewImageFiles);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OverViewSection(
                    showDeleteAndRetake: !isSubmited.value,
                    imageUrl: currentArg
                            .value.partDirection.overViewImageFiles.isNotEmpty
                        ? currentArg.value.partDirection.overViewImageFiles
                            .first.file.path
                        : currentArg
                                .value.partDirection.overViewImages.isNotEmpty
                            ? currentArg
                                .value.partDirection.overViewImages.first.url
                            : '',
                    onRetake: () => _goToCameraPage(1),
                    onDelete: () => _deleteImageById(
                      currentArg
                              .value.partDirection.overViewImageFiles.isNotEmpty
                          ? currentArg.value.partDirection.overViewImageFiles
                              .first.imageId
                              .toString()
                          : currentArg
                              .value.partDirection.overViewImages.first.imageId,
                      rangeId: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CloseViewSection(
                      showDeleteAndRetake: !isSubmited.value,
                      imageFromServers: imageList,
                      imageFiles: imageFiles,
                      onRetake: () => _goToCameraPage(2),
                      onDelete: (imageId) =>
                          _deleteImageById(imageId, rangeId: 2),
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
    Navigator.pop<PartDirection>(context, currentArg.value.partDirection);
    return false;
  }

  void _deleteImageById(String imageId, {int rangeId}) async {
    var _partDirection = currentArg.value.partDirection;
    try {
      _partDirection.images
          .removeWhere((element) => element.imageId == imageId);
      _partDirection.imageFiles
          .removeWhere((element) => element.imageId.toString() == imageId);
      if (rangeId == 1) {
        // over view
        _partDirection.overViewImages
            .removeWhere((element) => element.imageId == imageId);
        _partDirection.overViewImageFiles
            .removeWhere((element) => element.imageId.toString() == imageId);
      }
      if (rangeId == 2) {
        // middle view
        _partDirection.middleViewImages
            .removeWhere((element) => element.imageId == imageId);
        _partDirection.middleViewImageFiles
            .removeWhere((element) => element.imageId.toString() == imageId);
        // close up view
        _partDirection.closeViewImages
            .removeWhere((element) => element.imageId == imageId);
        _partDirection.closeViewImageFiles
            .removeWhere((element) => element.imageId.toString() == imageId);
      }
      setState(() {
        currentArg.value.partDirection = _partDirection;
      });
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
      if (response.statusCode != 200) {
        widget.onError(response.statusMessage ?? 'Package error');
      }
    } catch (e) {
      widget.onError(e.toString());
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
          Endpoints.deleteAllImageInClaim(currentArg.value.claimId),
          token: widget.token,
          query: {
            'partDirectionId':
                currentArg.value.partDirection.partDirectionId.toString(),
          },
        );
        if (response.statusCode != 200) {
          widget.onError(response.statusMessage ?? 'Package error');
        } else {
          setState(() {
            currentArg.value.partDirection =
                currentArg.value.partDirection.copyWith(
              images: [],
              imageFiles: [],
              closeViewImageFiles: [],
              closeViewImages: [],
              imagesCount: 0,
              middleViewImageFiles: [],
              middleViewImages: [],
              overViewImageFiles: [],
              overViewImages: [],
            );
          });
        }
      } catch (e) {
        widget.onError(e.toString());
        rethrow;
      }
    }
  }

  void _goToCameraPage(int rangeId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          token: widget.token,
          onError: widget.onError,
          cameraArgument: CameraArgument(
            partDirection: currentArg.value.partDirection,
            claimId: currentArg.value.claimId,
            imageRangeId: rangeId,
            carBrand: currentArg.value.carBrand,
          ),
        ),
      ),
    ).then((value) {
      if (value is CameraArgument) {
        setState(() {
          currentArg.value.partDirection = value.partDirection;
        });
      }
    });
  }

  Future<void> checkAssessmentSubmited() async {
    try {
      RestfulModule restfulModule = RestfulModuleImpl();
      var response = await restfulModule.get(
        Endpoints.checkDamageAssessmentSubmited(widget.sessionId),
        token: widget.token,
      );
      if (response.statusCode == 200) {
        if (response.body['isSendData'] == true) {
          isSubmited(true);
        } else {
          isSubmited(false);
        }
      } else {
        isSubmited(false);
        widget.onError(response.statusMessage ?? 'Package error');
      }
    } catch (e) {
      isSubmited(false);
      widget.onError(e.toString());
      rethrow;
    }
  }
}
