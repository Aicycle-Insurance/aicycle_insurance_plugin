import 'package:flutter/material.dart';

import '../src/extensions/hex_color_extension.dart';
import 'damage.dart';

class CarPart {
  final String uuid;
  final String carPartClassName;
  final String? carPartLocation;
  final num? carPartScore;
  final List<dynamic> carPartBoxes;
  final String carPartMaskPath;
  final String carPartMaskUrl;
  final bool carPartIsPart;
  final List<DamageModel> carPartDamages;
  final Color color;

  CarPart({
    required this.carPartClassName,
    required this.carPartLocation,
    required this.carPartScore,
    required this.carPartBoxes,
    required this.carPartMaskPath,
    required this.carPartMaskUrl,
    required this.carPartIsPart,
    required this.carPartDamages,
    required this.color,
    required this.uuid,
  });

  factory CarPart.fromJson(Map<String, dynamic> json) => CarPart(
        uuid: json['class_uuid'] ?? '',
        carPartClassName: json['car_part_name'] ?? '',
        carPartLocation: json['location'],
        carPartScore: json['score'],
        carPartBoxes: json['box'],
        carPartMaskPath: json['mask_path'],
        carPartMaskUrl: json['mask_url'],
        carPartIsPart: json['is_part'],
        carPartDamages: List<DamageModel>.from(
            json['damages'].map((e) => DamageModel.fromJson(e))),
        color: json['car_part_color'] != null
            ? HexColor.fromHex(json['car_part_color'])
            : Colors.transparent,
      );
}
