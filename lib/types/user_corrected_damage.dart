import 'dart:typed_data';

class UserCorrectedDamageItem {
  final Uint8List maskData;
  final String damageClass;
  final String maskImgName;

  UserCorrectedDamageItem({
    required this.maskData,
    required this.damageClass,
    required this.maskImgName,
  });
}

class UserCorrectedDamages {
  final String imageId;
  final List<UserCorrectedDamageItem> correctedData;

  UserCorrectedDamages({required this.imageId, required this.correctedData});
}
