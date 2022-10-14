import 'package:flutter/material.dart';

import '../src/constants/damage_types.dart';
import '../src/extensions/hex_color_extension.dart';

class DamageModel {
  final num overlapRate;
  final String className;
  final String uuid;
  final String maskUrl;
  final String location;
  final num score;
  final List<dynamic> boxes;
  final String maskPath;
  final bool isPart;
  final Color color;

  DamageModel({
    this.className,
    this.uuid,
    this.location,
    this.score,
    this.boxes,
    this.maskPath,
    this.maskUrl,
    this.isPart,
    this.color,
    this.overlapRate,
  });

  factory DamageModel.fromJson(Map<String, dynamic> json) {
    int damageIdx = DamageTypeConstant.listDamageType.indexWhere((element) =>
        element.damageTypeGuid == json['class_uuid'] ||
        element.damageTypeGuid == json['class_id_list']);
    String _name = 'Unknown';
    if (damageIdx != -1) {
      _name = DamageTypeConstant.listDamageType[damageIdx].damageTypeName;
    }
    return DamageModel(
      className: json['damage_type_name'] ?? json['class'] ?? _name,
      uuid: json['class_uuid'] ?? json['class_id_list'] ?? '',
      location: json['location'],
      score: json['score'],
      boxes: json['box'] ?? json['box_list'],
      maskPath: json['mask_path'] ?? json['mask_paths_list'],
      isPart: json['is_part'],
      overlapRate: json['overlap_rate'],
      maskUrl: json['mask_url_list'] ?? json['mask_url'] ?? '',
      color: json['damage_type_color'] != null
          ? HexColor.fromHex(json['damage_type_color'])
          : json['car_part_color'] != null
              ? HexColor.fromHex(json['car_part_color'])
              : Colors.red,
    );
  }
}
