import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../../types/image.dart';
import '../../../types/part_direction.dart';
import 'preview_image_container.dart';

class CloseViewSection extends StatelessWidget {
  const CloseViewSection({
    Key? key,
    this.imageFiles = const [],
    this.imageFromServers = const [],
    required this.onRetake,
    required this.onDelete,
  }) : super(key: key);

  final List<XFileWithId> imageFiles;
  final List<AiImage> imageFromServers;
  final Function()? onRetake;
  final Function(String imageId)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                StringKeys.middleAndCloseUpView,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: Row(
                  children: const [
                    Icon(
                      CupertinoIcons.camera,
                      size: 18,
                      color: DefaultColors.blue,
                    ),
                    SizedBox(width: 4),
                    Text(
                      StringKeys.takePicture,
                      style: TextStyle(
                          color: DefaultColors.blue,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              onPressed: onRetake,
            )
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              crossAxisCount: 2,
              children: [
                ...imageFromServers.map((e) {
                  return PreviewImageContainer(
                    imageUrl: e.url,
                    onDelete: () =>
                        onDelete != null ? onDelete!(e.imageId) : null,
                    onRetake: onRetake,
                  );
                }).toList(),
                ...imageFiles.map((e) {
                  return PreviewImageContainer(
                    imageUrl: e.file.path,
                    onDelete: () => onDelete != null
                        ? onDelete!(e.imageId.toString())
                        : null,
                    onRetake: onRetake,
                  );
                }).toList()
              ]),
        )
      ],
    );
  }
}
