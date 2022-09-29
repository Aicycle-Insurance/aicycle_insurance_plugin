import 'dart:io';

// import 'package:aicycle_insurance_non_null_safety/src/utils/compress_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../../src/summary_camera/summary_camera.dart';
import '../../common/image_view/image_view.dart';
import '../../constants/colors.dart';
import '../../constants/endpoints.dart';
import '../../constants/strings.dart';
import '../../modules/resful_module.dart';
import '../../modules/resful_module_impl.dart';
import '../../utils/upload_image_to_s3.dart';
import '../../../types/summary_image.dart';

class SummaryImagesSection extends StatefulWidget {
  const SummaryImagesSection({
    Key key,
    this.images,
    this.imagesOnChanged,
    this.token,
    this.sessionId,
    this.claimId,
    this.onError,
  }) : super(key: key);

  final String token;
  final String claimId;
  final String sessionId;
  final List<SummaryImage> images;
  final Function(List<SummaryImage>) imagesOnChanged;
  final Function(String) onError;

  @override
  State<SummaryImagesSection> createState() => _SummaryImagesSectionState();
}

class _SummaryImagesSectionState extends State<SummaryImagesSection> {
  final _images = <SummaryImage>[].obs;
  final isLoadingImage = false.obs;
  var imagesAreDeleting = <int>[].obs;
  var imagesAreUploading = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _images.assignAll(widget.images);
    _getSummaryImages();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  '${StringKeys.overView} (${_images.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: const [
                      Icon(
                        // CupertinoIcons.camera,
                        FontAwesomeIcons.camera,
                        size: 18,
                        color: DefaultColors.blue,
                      ),
                      SizedBox(width: 4),
                      Material(
                        child: Text(
                          StringKeys.takePicture,
                          style: TextStyle(
                            color: DefaultColors.blue,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // onPressed: _takePicture,
                onPressed: _goToSummaryCamera,
              )
            ],
          ),
          const SizedBox(height: 16),
          _overViewImageSection(),
        ],
      ),
    );
  }

  void _goToSummaryCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryCameraPage(
          images: _images,
        ),
      ),
    ).then((value) {
      if (value is List<SummaryImage>) {
        _images.assignAll(value);
        for (var image in value) {
          if (image.localFilePath != null && image.url == null) {
            imagesAreUploading.add(image.localFilePath);
            _addSummaryImage(File(image.localFilePath)).then((imageId) {
              // image.copyWith(imageId: value);
              int index = _images.indexOf(image);
              if (index != -1) {
                _images[index] = _images[index].copyWith(imageId: imageId);
              }
              imagesAreUploading.remove(image.localFilePath);
            });
          }
        }
      }
    });
  }

  Widget _overViewImageSection() {
    return Obx(() {
      if (isLoadingImage.value) {
        return const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (_images.isEmpty) {
        return const Text(
          StringKeys.noImages,
        );
      } else {
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          children: _images.reversed.map((element) {
            Widget child;
            String imageUrl;
            if (element.localFilePath != null && element.localFilePath != '') {
              child = Image.file(
                File(element.localFilePath),
                fit: BoxFit.cover,
              );
              imageUrl = element.localFilePath;
            } else {
              child = CachedNetworkImage(
                imageUrl: element.url ?? '',
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) {
                  return SizedBox(
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.progress,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.primaries[5]),
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return const SizedBox(
                    child: Icon(
                      Icons.error,
                    ),
                  );
                },
              );
              imageUrl = element.url;
            }
            if (imagesAreDeleting.contains(element.imageId)) {
              return Container(
                height: 72,
                width: double.maxFinite,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CupertinoActivityIndicator(),
                      SizedBox(height: 4),
                      Text(
                        'Đang xoá...',
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  ),
                ),
              );
            }
            if (imagesAreUploading.contains(element.localFilePath)) {
              return Container(
                height: 72,
                width: double.maxFinite,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CupertinoActivityIndicator(),
                      SizedBox(height: 4),
                      Text(
                        'Đang tải lên...',
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  ),
                ),
              );
            }
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageView(imageUrl: imageUrl)),
                  ),
                  child: Hero(
                    tag: imageUrl,
                    child: Container(
                      height: 72,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: child,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.black54,
                      child: Center(
                        child: Icon(
                          Icons.clear_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    onPressed: () => _deleteImage(element),
                  ),
                )
              ],
            );
          }).toList(),
        );
      }
    });
  }

  Future<void> _deleteImage(SummaryImage image) async {
    if (image.imageId != null) {
      imagesAreDeleting.add(image.imageId);
      // _images.removeWhere((element) => element.imageId == image.imageId);
      // call api
      final RestfulModule restfulModule = RestfulModuleImpl();
      try {
        await restfulModule.delete(
          Endpoints.deleteSummaryImage(image.imageId.toString()),
          token: widget.token,
        );
        imagesAreDeleting.remove(image.imageId);
        _images.removeWhere((element) => element.imageId == image.imageId);
      } catch (e) {
        imagesAreDeleting.remove(image.imageId);
        rethrow;
      }
    } else {
      _images.remove(image);
    }
    widget.imagesOnChanged(_images);
  }

  // Thêm ảnh toàn cảnh (summary images)
  Future<int> _addSummaryImage(File file) async {
    final RestfulModule restfulModule = RestfulModuleImpl();
    try {
      var result =
          await upLoadImageToS3(imageFiles: file.path, token: widget.token);
      if (result is UploadResponse) {
        var response = await restfulModule.post(
          Endpoints.addSummaryImageToClaim,
          {
            "claimId": widget.claimId,
            "imageName": result.imageName,
            "filePath": result.filePath,
          },
          token: widget.token,
        );
        if (response.statusCode == 200) {
          return response.body['imageId'];
        } else {
          widget.onError(response.statusMessage ?? 'Package error');
        }
      }
      return null;
    } catch (e) {
      widget.onError(e.toString());
      rethrow;
    }
  }

  Future<void> _getSummaryImages() async {
    try {
      isLoadingImage(true);
      final RestfulModule restfulModule = RestfulModuleImpl();
      var response = await restfulModule.get(
          Endpoints.getSummaryImages(widget.sessionId),
          token: widget.token);
      if (response.statusCode == 200) {
        List result = response.body['results'];
        _images.assignAll(result.map((e) => SummaryImage.fromJson(e)).toList());
      }
      isLoadingImage(false);
    } catch (e) {
      isLoadingImage(false);
      rethrow;
    }
  }
}
