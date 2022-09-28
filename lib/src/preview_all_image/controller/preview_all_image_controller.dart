import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/camera_view/camera_argument.dart';
import '../../../src/camera_view/camera_page.dart';
import '../../../src/common/dialog/confirm_dialog.dart';
import '../../../src/common/dialog/process_dialog.dart';
import '../../../src/constants/endpoints.dart';
import '../../../src/constants/strings.dart';
import '../../../src/modules/resful_module.dart';
import '../../../src/modules/resful_module_impl.dart';
import '../../../types/image.dart';
import '../../../types/image_range.dart';
import '../../../types/part_direction.dart';

class PreviewAllImageController extends GetxController {
  final CameraArgument pageArg;
  PreviewAllImageController(this.pageArg);

  Rx<CameraArgument> currentArg;
  var isSubmited = true.obs;
  final GlobalKey pageKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    currentArg = Rx<CameraArgument>(pageArg);
    isSubmited.value = currentArg.value.partDirection.value.images
        .every((element) => element.isSendToPti == true);
  }

  Future<bool> willPop(BuildContext context) async {
    Navigator.pop<PartDirection>(context, currentArg.value.partDirection.value);
    return false;
  }

  void deleteImageById(
    String imageId, {
    int rangeId,
  }) async {
    var _partDirection = currentArg.value.partDirection;
    try {
      _partDirection.value.images
          .removeWhere((element) => element.imageId == imageId);
      _partDirection.value.imageFiles
          .removeWhere((element) => element.imageId.toString() == imageId);
      if (rangeId == 1) {
        // over view
        _partDirection.value.overViewImages
            .removeWhere((element) => element.imageId == imageId);
        _partDirection.value.overViewImageFiles
            .removeWhere((element) => element.imageId.toString() == imageId);
      }
      if (rangeId == 2) {
        // middle view
        _partDirection.value.middleViewImages
            .removeWhere((element) => element.imageId == imageId);
        _partDirection.value.middleViewImageFiles
            .removeWhere((element) => element.imageId.toString() == imageId);
        // close up view
        _partDirection.value.closeViewImages
            .removeWhere((element) => element.imageId == imageId);
        _partDirection.value.closeViewImageFiles
            .removeWhere((element) => element.imageId.toString() == imageId);
      }
      // setState(() {
      currentArg.value.partDirection.value = _partDirection.value;
      update(['previewAllImage']);

      // });
    } catch (e) {
      currentArg.value.onError('Package: Removing image gets error!');
    }

    // delete on server
    try {
      RestfulModule restfulModule = RestfulModuleImpl();
      var response = await restfulModule.delete(
        Endpoints.deleteImageInCLaim(imageId),
        token: currentArg.value.token,
      );
      if (response.statusCode != 200) {
        currentArg.value.onError(response.statusMessage ?? 'Package error');
      }
    } catch (e) {
      currentArg.value.onError(e.toString());
      rethrow;
    }
  }

  void deleteAllImages(BuildContext context) async {
    var confirm = await ConfirmDialog.show(
      context,
      content: StringKeys.areYouSureToDeleteImage,
      cancelButtonLabel: StringKeys.dialogCancel,
      confirmButtonLabel: StringKeys.delete,
    );

    if (confirm != null && confirm) {
      try {
        ProgressDialog.showWithCircleIndicator(context);
        RestfulModule restfulModule = RestfulModuleImpl();
        var response = await restfulModule.delete(
          Endpoints.deleteAllImageInClaim(currentArg.value.sessionId),
          token: currentArg.value.token,
          query: {
            'partDirectionId':
                currentArg.value.partDirection.value.partDirectionId.toString(),
          },
        );
        if (response.statusCode != 204) {
          currentArg.value.onError(response.statusMessage ?? 'Package error');
        } else {
          await geImageInPartDirection();
          update(['previewAllImage']);
        }
        ProgressDialog.hide(context);
      } catch (e) {
        currentArg.value.onError(e.toString());
        rethrow;
      }
    }
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

  void goToCameraPage(
    BuildContext context,
    int rangeId, {
    int oldImageId,
  }) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          cameraArgument: CameraArgument(
            partDirection: currentArg.value.partDirection,
            claimId: currentArg.value.claimId,
            imageRangeId: rangeId,
            oldImageId: oldImageId,
            carBrand: currentArg.value.carBrand,
            token: currentArg.value.token,
            onError: currentArg.value.onError,
            sessionId: currentArg.value.sessionId,
          ),
        ),
      ),
    ).then((value) {
      if (value is CameraArgument) {
        currentArg.value.partDirection.value = value.partDirection.value;
        update(['previewAllImage']);
      }
    });
  }

  void overViewImageDelete() {
    deleteImageById(
      currentArg.value.partDirection.value.overViewImageFiles.isNotEmpty
          ? currentArg
              .value.partDirection.value.overViewImageFiles.first.imageId
              .toString()
          : currentArg.value.partDirection.value.overViewImages.first.imageId,
      rangeId: 1,
    );
  }
}
