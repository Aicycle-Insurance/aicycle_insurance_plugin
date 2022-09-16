import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';
import 'preview_image_container.dart';

class OverViewSection extends StatelessWidget {
  const OverViewSection({
    Key key,
    this.imageUrl,
    this.showDeleteAndRetake = true,
    this.onRetake,
    this.onDelete,
  }) : super(key: key);

  final String imageUrl;
  final bool showDeleteAndRetake;
  final Function() onRetake;
  final Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          StringKeys.overViewShot,
          style: TextStyle(
            color: DefaultColors.ink500,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? PreviewImageContainer(
                      imageUrl: imageUrl,
                      showDeleteAndRetake: showDeleteAndRetake,
                      onDelete: onDelete,
                      onRetake: onRetake,
                    )
                  : GestureDetector(
                      onTap: onRetake,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: DefaultColors.blue,
                            width: 2,
                          ),
                        ),
                        height: 120,
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 36,
                            color: DefaultColors.blue,
                          ),
                        ),
                      ),
                    ),
            ),
            const Expanded(child: SizedBox())
          ],
        )
      ],
    );
  }
}
