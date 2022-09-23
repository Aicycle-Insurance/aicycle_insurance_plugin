import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PreviewImageContainer extends StatelessWidget {
  const PreviewImageContainer({
    Key key,
    this.imageUrl,
    this.showDeleteAndRetake = true,
    this.onDelete,
    this.onRetake,
  }) : super(key: key);

  final String imageUrl;
  final bool showDeleteAndRetake;
  final Function() onDelete;
  final Function() onRetake;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        image: imageUrl.startsWith('https')
            ? DecorationImage(
                image: CachedNetworkImageProvider(imageUrl, cacheKey: imageUrl),
                fit: BoxFit.cover,
              )
            : DecorationImage(
                image: FileImage(File(imageUrl)),
                fit: BoxFit.cover,
              ),
      ),
      child: Stack(
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
    );
  }
}
