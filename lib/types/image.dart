import 'package:flutter/material.dart';

import '../src/extensions/hex_color_extension.dart';
import 'mask_data.dart';

class AiImage {
  AiImage({
    required this.imageId,
    required this.imageName,
    required this.claimId,
    required this.url,
    required this.imageSize,
    required this.partDirectionName,
    required this.imageRangeName,
    required this.totalItem,
    required this.damageExist,
    required this.damageMasks,
    required this.partsMasks,
    required this.deletedFlag,
    required this.createdDate,
    required this.updatedDate,
    required this.createdBy,
    required this.timeProcess,
    required this.errorNote,
    required this.errorType,
  });

  final String imageId;
  final String imageName;
  final String claimId;
  final String url;
  final List<double> imageSize;
  final String partDirectionName;
  final String imageRangeName;
  final String? totalItem;
  final bool? damageExist;
  final List<MaskData> damageMasks;
  final List<PartsMask> partsMasks;
  final bool? deletedFlag;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String? createdBy;
  final double timeProcess;
  final List<String> errorType;
  final String? errorNote;

  AiImage copyWith({
    String? imageId,
    String? imageName,
    String? claimId,
    String? url,
    List<double>? imageSize,
    String? partDirectionName,
    String? imageRangeName,
    String? totalItem,
    bool? damageExist,
    List<MaskData>? damageMasks,
    List<PartsMask>? partsMasks,
    bool? deletedFlag,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? createdBy,
    double? timeProcess,
    List<String>? errorType,
    String? errorNote,
  }) =>
      AiImage(
        imageId: imageId ?? this.imageId,
        imageName: imageName ?? this.imageName,
        claimId: claimId ?? this.claimId,
        url: url ?? this.url,
        imageSize: imageSize ?? this.imageSize,
        partDirectionName: partDirectionName ?? this.partDirectionName,
        imageRangeName: imageRangeName ?? this.imageRangeName,
        totalItem: totalItem ?? this.totalItem,
        damageExist: damageExist ?? this.damageExist,
        damageMasks: damageMasks ?? this.damageMasks,
        partsMasks: partsMasks ?? this.partsMasks,
        deletedFlag: deletedFlag ?? this.deletedFlag,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        createdBy: createdBy ?? this.createdBy,
        errorNote: errorNote ?? this.errorNote,
        timeProcess: timeProcess ?? this.timeProcess,
        errorType: errorType ?? this.errorType,
      );

  factory AiImage.fromJson(Map<String, dynamic> json) => AiImage(
        imageId: json["imageId"],
        imageName: json["imageName"],
        claimId: json["claimId"],
        url: json["url"],
        imageSize: json["imageSize"] != null
            ? List<double>.from(json["imageSize"].map((x) => x.toDouble()))
            : [],
        partDirectionName: json["partDirectionName"],
        imageRangeName: json["imageRangeName"],
        totalItem: json["totalItem"],
        damageExist: json["damageExist"],
        damageMasks: json["damageMasks"] != null
            ? List<MaskData>.from(
                json["damageMasks"].map((e) => MaskData.fromJson(e))).toList()
            : [],
        partsMasks: json["partsMasks"] != null
            ? List<PartsMask>.from(
                json["partsMasks"].map((x) => PartsMask.fromJson(x))).toList()
            : [],
        deletedFlag: json["deletedFlag"],
        createdDate: json["createdDate"] != null
            ? DateTime.parse(json["createdDate"])
            : DateTime.now(),
        updatedDate: json["updatedDate"] != null
            ? DateTime.parse(json["updatedDate"])
            : DateTime.now(),
        createdBy: json["createdBy"],
        timeProcess:
            json['timeProcess'] != null ? json['timeProcess'].toDouble() : 0.0,
        errorNote: json['errorNote'],
        errorType: json['errorType'] != null
            ? List<String>.from(json['errorType'].map((e) => e.toString()))
                .toList()
            : [],
      );
}

class PartsMask {
  PartsMask({
    required this.masksPath,
    required this.category,
    required this.boxes,
    required this.vehiclePartName,
    required this.scores,
    required this.maskUrl,
    required this.isPart,
    required this.color,
  });

  final String masksPath;
  final String category;
  final List<double> boxes;
  final String vehiclePartName;
  final double scores;
  final String maskUrl;
  final bool isPart;
  final Color color;

  PartsMask copyWith({
    String? masksPath,
    String? category,
    List<double>? boxes,
    String? vehiclePartName,
    double? scores,
    String? maskUrl,
    bool? isPart,
    Color? color,
  }) =>
      PartsMask(
        masksPath: masksPath ?? this.masksPath,
        boxes: boxes ?? this.boxes,
        vehiclePartName: vehiclePartName ?? this.vehiclePartName,
        scores: scores ?? this.scores,
        maskUrl: maskUrl ?? this.maskUrl,
        isPart: isPart ?? this.isPart,
        category: category ?? this.category,
        color: color ?? this.color,
      );

  factory PartsMask.fromJson(Map<String, dynamic> json) => PartsMask(
        masksPath: json["masksPath"],
        boxes: json["boxes"] != null
            ? List<double>.from(json["boxes"].map((x) => x.toDouble()))
            : [0, 0, 1, 1],
        vehiclePartName: json['car_part_name'] ??
            json["vehiclePartName"] ??
            json["class"] ??
            "Unknown",
        scores: json["scores"] != null ? json["scores"].toDouble() : 0.0,
        maskUrl: json["maskUrl"],
        isPart: json["isPart"],
        color: json['vehicleColor'] != null
            ? HexColor.fromHex(json['vehicleColor'])
            : Colors.transparent,
        category: json['car_part_name'] ??
            json["vehiclePartName"] ??
            json["class"] ??
            "Unknown",
      );
}
