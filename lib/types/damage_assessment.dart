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

// }
