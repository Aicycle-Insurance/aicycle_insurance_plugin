import 'package:flutter/material.dart';
import '../src/extensions/hex_color_extension.dart';

class PTIDamageResult {
  PTIDamageResult({
    this.vehiclePartExcelId,
    this.vehiclePartName,
    this.location,
    this.createdDate,
    this.damages,
    this.images,
    this.price,
    this.laborCost,
    this.totalCost,
    this.claimResultIds,
    this.area,
    this.repairPlan,
  });

  final String vehiclePartExcelId;
  final String vehiclePartName;
  final String location;
  final String createdDate;
  final List<PTIDamage> damages;
  final List<PTIImage> images;
  final num price;
  final num laborCost;
  final num totalCost;
  final List<int> claimResultIds;
  final num area;
  final String repairPlan;

  PTIDamageResult copyWith({
    String vehiclePartExcelId,
    String vehiclePartName,
    String location,
    String createdDate,
    List<PTIDamage> damages,
    List<PTIImage> images,
    num price,
    num laborCost,
    num totalCost,
    List<int> claimResultIds,
    num area,
    String repairPlan,
  }) =>
      PTIDamageResult(
        vehiclePartExcelId: vehiclePartExcelId ?? this.vehiclePartExcelId,
        vehiclePartName: vehiclePartName ?? this.vehiclePartName,
        location: location ?? this.location,
        createdDate: createdDate ?? this.createdDate,
        damages: damages ?? this.damages,
        images: images ?? this.images,
        price: price ?? this.price,
        laborCost: laborCost ?? this.laborCost,
        totalCost: totalCost ?? this.totalCost,
        claimResultIds: claimResultIds ?? this.claimResultIds,
        area: area ?? this.area,
        repairPlan: repairPlan ?? this.repairPlan,
      );

  factory PTIDamageResult.fromJson(Map<String, dynamic> json) =>
      PTIDamageResult(
        vehiclePartExcelId: json["vehiclePartExcelId"],
        vehiclePartName: json["vehiclePartName"],
        location: json["location"],
        createdDate: json["createdDate"],
        damages: List<PTIDamage>.from(
            json["damages"].map((x) => PTIDamage.fromJson(x))),
        images: List<PTIImage>.from(
            json["images"].map((x) => PTIImage.fromJson(x))),
        price: json["price"],
        laborCost: json["laborCost"],
        totalCost: json["totalCost"],
        claimResultIds: List<int>.from(json["claimResultIds"].map((x) => x)),
        area: json["area"],
        repairPlan: json["repairPlan"],
      );
}

class PTIDamage {
  PTIDamage({
    this.damageTypeName,
    this.damagePercentage,
    this.damageArea,
    this.damageColor,
  });

  final String damageTypeName;
  final double damagePercentage;
  final double damageArea;
  final Color damageColor;

  PTIDamage copyWith({
    String damageTypeName,
    double damagePercentage,
    double damageArea,
    Color damageColor,
  }) =>
      PTIDamage(
        damageTypeName: damageTypeName ?? this.damageTypeName,
        damagePercentage: damagePercentage ?? this.damagePercentage,
        damageArea: damageArea ?? this.damageArea,
        damageColor: damageColor ?? this.damageColor,
      );

  factory PTIDamage.fromJson(Map<String, dynamic> json) => PTIDamage(
        damageTypeName: json["damageTypeName"],
        damagePercentage: json["damagePercentage"].toDouble(),
        damageArea: json["damageArea"].toDouble(),
        damageColor: json["damageColor"] != null
            ? HexColor.fromHex(json["damageColor"])
            : Colors.amberAccent,
      );
}

class PTIImage {
  PTIImage({
    this.imageId,
    this.imageUrl,
    this.imageRange,
  });

  final int imageId;
  final String imageUrl;
  final String imageRange;

  PTIImage copyWith({
    int imageId,
    String imageUrl,
    String imageRange,
  }) =>
      PTIImage(
        imageId: imageId ?? this.imageId,
        imageUrl: imageUrl ?? this.imageUrl,
        imageRange: imageRange ?? this.imageRange,
      );

  factory PTIImage.fromJson(Map<String, dynamic> json) => PTIImage(
        imageId: json["imageId"],
        imageUrl: json["imageUrl"],
        imageRange: json["imageRange"],
      );
}
