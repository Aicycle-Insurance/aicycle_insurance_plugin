import 'car_part.dart';
import 'damage.dart';

class DamageAssessmentModel {
  final int imageId;
  final String imgUrl;
  final List<dynamic> imageSize;
  final List<DamageModel> carDamages;
  final List<CarPart> carParts;

  DamageAssessmentModel({
    this.imageId,
    this.imgUrl,
    this.imageSize,
    this.carDamages,
    this.carParts,
  });

  DamageAssessmentModel copyWith({
    int imageId,
    String imgUrl,
    List<dynamic> imageSize,
    List<DamageModel> carDamages,
    List<CarPart> carParts,
  }) =>
      DamageAssessmentModel(
        imageId: imageId ?? this.imageId,
        imgUrl: imgUrl ?? this.imgUrl,
        imageSize: imageSize ?? this.imageSize,
        carDamages: carDamages ?? this.carDamages,
        carParts: carParts ?? this.carParts,
      );

  factory DamageAssessmentModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> _result = json['result'][0] ?? json['result'];
    return DamageAssessmentModel(
      imageId: json['imageId'],
      imgUrl: _result['img_url'],
      imageSize: _result['img_size'],
      carDamages: List<DamageModel>.from(
          _result['car_damages'].map((e) => DamageModel.fromJson(e))),
      carParts: List<CarPart>.from(
          _result['car_parts'].map((e) => CarPart.fromJson(e))),
    );
  }
}

// class CarDamageModel {
//   final String className;
//   final String maskUrl;
//   final String? location;
//   final num score;
//   final List<dynamic> boxes;
//   final String maskPath;
//   final bool isPart;
//   final Color color;

//   CarDamageModel({
//      this.className,
//      this.location,
//      this.score,
//      this.boxes,
//      this.maskPath,
//      this.isPart,
//      this.maskUrl,
//      this.color,
//   });

//   factory CarDamageModel.fromJson(Map<String, dynamic> json) {
//     int damageIdx = LocalStorageService()
//         .damageTypes
//         .indexWhere((element) => element.damageTypeGuid == json['class_uuid']);
//     String _name = 'Unknown';
//     if (damageIdx != -1) {
//       _name = LocalStorageService().damageTypes[damageIdx].damageTypeName;
//     }
//     return CarDamageModel(
//       className: json['damage_type_name'] ?? _name,
//       location: json['location'],
//       score: json['score'],
//       boxes: json['box'],
//       maskPath: json['mask_path'],
//       isPart: json['is_part'],
//       maskUrl: json['mask_url'] ?? '',
//       color: json['damage_type_color'] != null
//           ? HexColor.fromHex(json['car_part_color'])
//           : Colors.transparent,
//     );
//   }
// }
