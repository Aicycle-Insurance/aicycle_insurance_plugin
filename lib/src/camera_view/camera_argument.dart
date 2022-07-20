import '../../types/part_direction.dart';

class CameraArgument {
  PartDirection partDirection;
  final String claimId;
  final int imageRangeId;

  CameraArgument({
    required this.partDirection,
    required this.claimId,
    required this.imageRangeId,
  });
}
