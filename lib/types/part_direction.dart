import 'dart:io';

import 'image.dart';
import 'part_direction_meta.dart';

class PartDirection {
  final int partDirectionId;
  final String partDirectionName;
  // final List<String> images;
  // final List<String> overViewImages;
  // final List<String> middleViewImages;
  // final List<String> closeViewImages;
  List<AiImage> images;
  List<AiImage> overViewImages;
  List<AiImage> middleViewImages;
  List<AiImage> closeViewImages;
  List<XFileWithId> imageFiles;
  List<XFileWithId> overViewImageFiles;
  List<XFileWithId> middleViewImageFiles;
  List<XFileWithId> closeViewImageFiles;
  int imagesCount;
  PartDirectionMeta meta;

  PartDirection({
    required this.partDirectionId,
    required this.partDirectionName,
    this.images = const [],
    this.overViewImages = const [],
    this.middleViewImages = const [],
    this.closeViewImages = const [],
    this.imageFiles = const [],
    this.overViewImageFiles = const [],
    this.middleViewImageFiles = const [],
    this.closeViewImageFiles = const [],
    required this.meta,
    this.imagesCount = 0,
  });

  PartDirection copyWith({
    int? partDirectionId,
    String? partDirectionName,
    List<AiImage>? images,
    List<AiImage>? overViewImages,
    List<AiImage>? middleViewImages,
    List<AiImage>? closeViewImages,
    List<XFileWithId>? imageFiles,
    List<XFileWithId>? overViewImageFiles,
    List<XFileWithId>? middleViewImageFiles,
    List<XFileWithId>? closeViewImageFiles,
    int? imagesCount,
    PartDirectionMeta? meta,
  }) =>
      PartDirection(
        closeViewImages: closeViewImages ?? this.closeViewImages,
        images: images ?? this.images,
        meta: meta ?? this.meta,
        middleViewImages: middleViewImages ?? this.middleViewImages,
        overViewImages: overViewImages ?? this.overViewImages,
        partDirectionId: partDirectionId ?? this.partDirectionId,
        partDirectionName: partDirectionName ?? this.partDirectionName,
        imageFiles: imageFiles ?? this.imageFiles,
        overViewImageFiles: overViewImageFiles ?? this.overViewImageFiles,
        middleViewImageFiles: middleViewImageFiles ?? this.middleViewImageFiles,
        closeViewImageFiles: closeViewImageFiles ?? this.closeViewImageFiles,
      );
}

class XFileWithId {
  final int? imageId;
  final File file;

  XFileWithId({required this.imageId, required this.file});
}
