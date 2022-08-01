import 'package:aicycle_insurance/src/constants/car_brand.dart';

import '../../types/part_direction.dart';

class CameraArgument {
  PartDirection partDirection;
  final String claimId;
  final int imageRangeId;
  final CarBrandType carBrand;

  CameraArgument({
    this.partDirection,
    this.claimId,
    this.imageRangeId,
    this.carBrand,
  });
}
