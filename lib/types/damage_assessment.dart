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

  factory DamageAssessmentModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> _results = json['result']['results']['Results'];
    Map<String, dynamic> _result = _results.first;
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
