import 'package:get/get.dart';
import '../../types/part_direction.dart';
import '../constants/car_brand.dart';

class CameraArgument {
  Rx<PartDirection> partDirection;
  final String claimId;
  final int imageRangeId;
  final int oldImageId;
  final CarBrandType carBrand;
  final String token;
  final String sessionId;
  final Function(String message) onError;

  CameraArgument({
    this.partDirection,
    this.claimId,
    this.imageRangeId,
    this.oldImageId,
    this.carBrand,
    this.token,
    this.sessionId,
    this.onError,
  });
}
