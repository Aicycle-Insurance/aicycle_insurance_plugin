import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  const ImageView({Key? key, required this.imageUrl}) : super(key: key);
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    late ImageProvider image;
    if (imageUrl.startsWith('https')) {
      image = CachedNetworkImageProvider(imageUrl);
    } else {
      image = FileImage(File(imageUrl));
    }
    return SafeArea(
      child: Stack(
        children: [
          PhotoView(
            imageProvider: image,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.black54,
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
