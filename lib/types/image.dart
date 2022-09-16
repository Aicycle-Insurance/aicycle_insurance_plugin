import 'package:flutter/material.dart';

import '../src/extensions/hex_color_extension.dart';
import 'mask_data.dart';

class AiImage {
  AiImage({
    this.imageId,
    this.imageName,
    this.claimId,
    this.url,
    this.imageSize,
    this.partDirectionName,
    this.imageRangeName,
    this.totalItem,
    this.damageExist,
    this.damageMasks,
    this.partsMasks,
    this.deletedFlag,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.timeProcess,
    this.errorNote,
    this.errorType,
    this.damageParts,
  });

  final String imageId;
  final String imageName;
  final String claimId;
  final String url;
  final List<double> imageSize;
  final String partDirectionName;
  final String imageRangeName;
  final String totalItem;
  final bool damageExist;
  final List<MaskData> damageMasks;
  final List<PartsMask> partsMasks;
  final List<DamagePart> damageParts;
  final bool deletedFlag;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String createdBy;
  final double timeProcess;
  final List<String> errorType;
  final String errorNote;

  AiImage copyWith({
    String imageId,
    String imageName,
    String claimId,
    String url,
    List<double> imageSize,
    String partDirectionName,
    String imageRangeName,
    String totalItem,
    bool damageExist,
    List<MaskData> damageMasks,
    List<PartsMask> partsMasks,
    List<DamagePart> damageParts,
    bool deletedFlag,
    DateTime createdDate,
    DateTime updatedDate,
    String createdBy,
    double timeProcess,
    List<String> errorType,
    String errorNote,
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
        damageParts: damageParts ?? this.damageParts,
      );

  factory AiImage.fromJson(Map<String, dynamic> json) => AiImage(
        imageId: json["imageId"],
        imageName: json["imageName"],
        claimId: json["claimId"],
        url: json["url"],
        imageSize: json["imageSize"] != null
            ? List<double>.from(json["imageSize"].map((x) => x.toDouble()))
            : [],
        partDirectionName: json["partDirectionName"] ?? json["directionName"],
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
        damageParts: json["damageParts"] != null
            ? List<DamagePart>.from(
                json["damageParts"].map((x) => DamagePart.fromJson(x))).toList()
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

class DamagePart {
  final String vehiclePartNamge;
  final String vehiclePartExcelId;

  DamagePart({this.vehiclePartNamge, this.vehiclePartExcelId});
  DamagePart copyWith({
    String vehiclePartNamge,
    String vehiclePartExcelId,
  }) =>
      DamagePart(
        vehiclePartExcelId: vehiclePartExcelId ?? this.vehiclePartExcelId,
        vehiclePartNamge: vehiclePartNamge ?? this.vehiclePartNamge,
      );

  factory DamagePart.fromJson(Map<String, dynamic> json) => DamagePart(
        vehiclePartExcelId: json['vehiclePartExcelId'],
        vehiclePartNamge: json['vehiclePartNamge'],
      );
}

class PartsMask {
  PartsMask({
    this.masksPath,
    this.category,
    this.boxes,
    this.vehiclePartName,
    this.scores,
    this.maskUrl,
    this.isPart,
    this.color,
    this.vehiclePartExcelId,
  });

  final String masksPath;
  final String category;
  final List<double> boxes;
  final String vehiclePartName;
  final double scores;
  final String maskUrl;
  final bool isPart;
  final Color color;
  final String vehiclePartExcelId;

  PartsMask copyWith({
    String masksPath,
    String category,
    List<double> boxes,
    String vehiclePartName,
    String vehiclePartExcelId,
    double scores,
    String maskUrl,
    bool isPart,
    Color color,
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
        vehiclePartExcelId: vehiclePartExcelId ?? this.vehiclePartExcelId,
      );

  factory PartsMask.fromJson(Map<String, dynamic> json) => PartsMask(
        masksPath: json["masksPath"] ?? '',
        boxes: json["boxes"] != null
            ? List<double>.from(json["boxes"].map((x) => x.toDouble()))
            : [0, 0, 1, 1],
        vehiclePartName: json['car_part_name'] ??
            json["vehiclePartName"] ??
            json["class"] ??
            "Unknown",
        vehiclePartExcelId: json['vehiclePartExcelId'] ?? '',
        scores: json["scores"] != null ? json["scores"].toDouble() : 0.0,
        maskUrl: json["maskUrl"] ?? '',
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
