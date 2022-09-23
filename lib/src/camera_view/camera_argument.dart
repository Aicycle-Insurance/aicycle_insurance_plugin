import '../../types/part_direction.dart';
import '../constants/car_brand.dart';

class CameraArgument {
  PartDirection partDirection;
  final String claimId;
  final int imageRangeId;
  final int oldImageId;
  final CarBrandType carBrand;

  CameraArgument({
    this.partDirection,
    this.claimId,
    this.imageRangeId,
    this.oldImageId,
    this.carBrand,
  });
}
