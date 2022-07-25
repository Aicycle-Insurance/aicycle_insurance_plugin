import 'package:flutter/material.dart';

import '../src/extensions/hex_color_extension.dart';
import '../src/constants/damage_types.dart';

class MaskData {
  final String masksPath;
  final String maskUrl;
  final List<double> boxes;
  final String category;
  final String vehiclePartName;
  final Color color;
  final bool userCreated;

  MaskData({
    this.masksPath,
    this.maskUrl,
    this.boxes,
    this.category,
    this.vehiclePartName,
    this.color,
    this.userCreated,
  });

  factory MaskData.fromJson(Map<String, dynamic> json) {
    int damageIdx = DamageTypeConstant.listDamageType.indexWhere((element) =>
        element.damageTypeGuid == json['classes'] ||
        element.damageTypeGuid == json['class']);
    String _category = 'Unknown';
    if (damageIdx != -1) {
      _category = DamageTypeConstant.listDamageType[damageIdx].damageTypeName;
    }
    return MaskData(
      masksPath: json["masksPath"] ?? json['mask_path'] ?? '',
      maskUrl: json["maskUrl"] ?? json["mask_url"] ?? '',
      category: json['car_part_name'] ??
          json['damage_type_name'] ??
          json['carPartName'] ??
          json['damageTypeName'] ??
          _category,
      vehiclePartName: json["vehiclePartName"] ?? '',
      boxes: json['boxes'] != null
          ? List<double>.from(json['boxes'].map((e) => e.toDouble()))
          : List<double>.from(json['box'].map((e) => e.toDouble())),
      color: json['damageTypeColor'] != null
          ? HexColor.fromHex(json['damageTypeColor'])
          : Colors.transparent,
      userCreated: json['userCreated'] ?? false,
    );
  }
}
