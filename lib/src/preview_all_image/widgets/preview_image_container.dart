import 'dart:io';

import 'package:aicycle_insurance_non_null_safety/src/common/image_view/image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class PreviewImageContainer extends StatelessWidget {
  const PreviewImageContainer({
    Key key,
    this.imageUrl,
    this.showDeleteAndRetake = true,
    this.onDelete,
    this.isDeleting,
    this.onRetake,
  }) : super(key: key);

  final String imageUrl;
  final bool showDeleteAndRetake;
  final RxBool isDeleting;
  final Function() onDelete;
  final Function() onRetake;

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageView(imageUrl: imageUrl)),
          ),
          child: Hero(
            tag: imageUrl,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                image: isDeleting.value != null && isDeleting.value == true
                    ? null
                    : imageUrl.startsWith('https')
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(imageUrl,
                                cacheKey: imageUrl),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: FileImage(File(imageUrl)),
                            fit: BoxFit.cover,
                          ),
              ),
              child: isDeleting.value != null && isDeleting.value == true
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CupertinoActivityIndicator(),
                        SizedBox(height: 8),
                        Text(
                          'Đang xoá...',
                          style: TextStyle(fontSize: 10),
                        )
                      ],
                    )
                  : Stack(
                      children: [
                        if (showDeleteAndRetake)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: onDelete,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black54,
                                    ),
                                    child: const Icon(
                                      Icons.delete_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: onRetake,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black54,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ));
  }
}
