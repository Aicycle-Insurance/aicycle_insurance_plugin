import 'package:aicycle_insurance/src/constants/car_brand.dart';

import '../../types/part_direction.dart';

class CameraArgument {
  PartDirection partDirection;
  final String claimId;
  final String sessionId;
  final int imageRangeId;
  final CarBrandType carBrand;

  CameraArgument({
    required this.partDirection,
    required this.claimId,
    required this.sessionId,
    required this.imageRangeId,
    required this.carBrand,
  });
}
