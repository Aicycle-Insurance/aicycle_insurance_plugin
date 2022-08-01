import 'dart:typed_data';

class UserCorrectedDamageItem {
  final Uint8List maskData;
  final String damageClass;
  final String maskImgName;

  UserCorrectedDamageItem({
    this.maskData,
    this.damageClass,
    this.maskImgName,
  });
}

class UserCorrectedDamages {
  final String imageId;
  final List<UserCorrectedDamageItem> correctedData;

  UserCorrectedDamages({this.imageId, this.correctedData});
}
