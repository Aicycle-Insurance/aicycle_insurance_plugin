import '../../gen/assets.gen.dart';
import 'strings.dart';

class CarPartConstant {
  CarPartConstant._();

  ///relative position of taken point
  /// Point gồm padding left và padding bottom được lấy theo giá trị tương đối thông qua các kích thước trên figma
  /// Để tính giá trị padding tuyệt đối thì nhân với kích thước.
  static final directionMetas = <int, Map<String, dynamic>>{
    // 1: {
    //   'title': StringKeys.carHead,
    //   '3d_image_path': Assets.images.visionFrontStraight.path,
    //   'type': 'overview_front_straight',
    //   'relative_position': [154 / 759, 265 / 555],
    //   'vertical_relative_position': [125 / 274, 400 / 448],
    //   'chassis_path': Assets.images.chassisFrontStraight.path,
    //   'chassis_path_kia': Assets.images.kiaChassisFrontStraight.path,
    //   'chassis_path_innova': Assets.images.innovaChassisFrontStraight.path,
    //   'chassis_path_vios': Assets.images.viosChassisFrontStraight.path,
    //   'chassis_path_cerato': Assets.images.viosChassisFrontStraight.path,
    // },
    2: {
      'title': StringKeys.carHead,
      '3d_image_path': Assets.images.visionFrontStraight.path,
      'type': 'overview_front_straight',
      'relative_position': [154 / 759, 265 / 555],
      'vertical_relative_position': [125 / 274, 400 / 448],
      'chassis_path': Assets.images.chassisFrontStraight.path,
      'chassis_path_kia': Assets.images.kiaChassisFrontStraight.path,
      'chassis_path_innova': Assets.images.innovaChassisFrontStraight.path,
      'chassis_path_vios': Assets.images.viosChassisFrontStraight.path,
      'chassis_path_cerato': Assets.images.viosChassisFrontStraight.path,
    },
    3: {
      'title': StringKeys.rightHead45,
      '3d_image_path': Assets.images.visionFront45Right.path,
      'type': 'overview_front_45_right',
      'relative_position': [182 / 759, 349 / 555],
      'vertical_relative_position': [226 / 274, 314.5 / 448],
      'chassis_path': Assets.images.chassisFront45Right.path,
      'chassis_path_kia': Assets.images.kiaChassisFront45Right.path,
      'chassis_path_innova': Assets.images.innovaChassisFront45Right.path,
      'chassis_path_vios': Assets.images.viosChassisFront45Right.path,
      'chassis_path_cerato': Assets.images.ceratoChassisFront45Right.path,
    },
    4: {
      'title': StringKeys.leftHead45,
      '3d_image_path': Assets.images.visionFront45Left.path,
      'type': 'overview_front_45_left',
      'relative_position': [182 / 759, 178 / 555],
      'vertical_relative_position': [24 / 274, 314.5 / 448],
      'chassis_path': Assets.images.chassisFront45Left.path,
      'chassis_path_kia': Assets.images.kiaChassisFront45Left.path,
      'chassis_path_innova': Assets.images.innovaChassisFront45Left.path,
      'chassis_path_vios': Assets.images.viosChassisFront45Left.path,
      'chassis_path_cerato': Assets.images.ceratoChassisFront45Left.path,
    },
    5: {
      'title': StringKeys.carTail,
      '3d_image_path': Assets.images.visionBackStraight.path,
      'type': 'overview_back_straight',
      'relative_position': [581 / 759, 265 / 555],
      'vertical_relative_position': [125 / 274, 24 / 448],
      'chassis_path': Assets.images.chassisBackStraight.path,
      'chassis_path_kia': Assets.images.kiaChassisBackStraight.path,
      'chassis_path_innova': Assets.images.innovaChassisBackStraight.path,
      'chassis_path_vios': Assets.images.viosChassisBackStraight.path,
      'chassis_path_cerato': Assets.images.ceratoChassisBackStraight.path,
    },
    6: {
      'title': StringKeys.rightTail45,
      '3d_image_path': Assets.images.visionBack45Right.path,
      'type': 'overview_back_45_right',
      'relative_position': [553 / 759, 349 / 555],
      'vertical_relative_position': [226 / 274, 106.8 / 448],
      'chassis_path': Assets.images.chassisBack45Right.path,
      'chassis_path_kia': Assets.images.kiaChassisBack45Right.path,
      'chassis_path_innova': Assets.images.innovaChassisBack45Right.path,
      'chassis_path_vios': Assets.images.viosChassisBack45Right.path,
      'chassis_path_cerato': Assets.images.ceratoChassisBack45Right.path,
    },
    7: {
      'title': StringKeys.leftTail45,
      // '${LocalizationKeys.behindCarShort.tr} - ${LocalizationKeys.left45.tr}',
      '3d_image_path': Assets.images.visionBack45Left.path,
      'type': 'overview_back_45_left',
      'relative_position': [553 / 759, 178 / 555],
      'vertical_relative_position': [24 / 274, 106.8 / 448],
      'chassis_path': Assets.images.chassisBack45Left.path,
      'chassis_path_kia': Assets.images.kiaChassisBack45Left.path,
      'chassis_path_innova': Assets.images.innovaChassisBack45Left.path,
      'chassis_path_vios': Assets.images.viosChassisBack45Left.path,
      'chassis_path_cerato': Assets.images.ceratoChassisBack45Left.path,
    },
    // 8: {
    //   'title': LocalizationKeys.rightHead.tr,
    //   '3d_image_path': Assets.images.visionRightHead.path,
    //   'type': 'overview_right_upper',
    //   'relative_position': [287 / 759, 378 / 555],
    //   'vertical_relative_position': [154 / 759, 265 / 555],
    //   'chassis_path': Assets.images.chassisRightHead.path,
    //   'chassis_path_kia': Assets.images.kiaChassisRightHead.path,
    //   'chassis_path_innova': Assets.images.innovaChassisRightHead.path,
    //   'chassis_path_vios': Assets.images.viosChassisRightHead.path,
    //   'chassis_path_cerato': Assets.images.ceratoChassisRightHead.path,
    // },
    // 9: {
    //   'title': LocalizationKeys.leftHead.tr,
    //   '3d_image_path': Assets.images.visionLeftHead.path,
    //   'type': 'overview_left_upper',
    //   'relative_position': [287 / 759, 153 / 555],
    //   'vertical_relative_position': [154 / 759, 265 / 555],
    //   'chassis_path': Assets.images.chassisLeftHead.path,
    //   'chassis_path_kia': Assets.images.kiaChassisLeftHead.path,
    //   'chassis_path_innova': Assets.images.innovaChassisLeftHead.path,
    //   'chassis_path_vios': Assets.images.viosChassisLeftHead.path,
    //   'chassis_path_cerato': Assets.images.ceratoChassisLeftHead.path,
    // },
    // 10: {
    //   'title': LocalizationKeys.rightTail.tr,
    //   '3d_image_path': Assets.images.vidionRightTail.path,
    //   'type': 'overview_right_lower',
    //   'relative_position': [449 / 759, 378 / 555],
    //   'vertical_relative_position': [154 / 759, 265 / 555],
    //   'chassis_path': Assets.images.chassisRightTail.path,
    //   'chassis_path_kia': Assets.images.kiaChassisRightTail.path,
    //   'chassis_path_innova': Assets.images.innovaChassisRightTail.path,
    //   'chassis_path_vios': Assets.images.viosChassisRightTail.path,
    //   'chassis_path_cerato': Assets.images.ceratoChassisRightTail.path,
    // },
    // 11: {
    //   'title': LocalizationKeys.leftTail.tr,
    //   '3d_image_path': Assets.images.visionLeftTail.path,
    //   'type': 'overview_left_lower',
    //   'relative_position': [449 / 759, 153 / 555],
    //   'vertical_relative_position': [154 / 759, 265 / 555],
    //   'chassis_path': Assets.images.chassisLeftTail.path,
    //   'chassis_path_kia': Assets.images.kiaChassisLeftTail.path,
    //   'chassis_path_innova': Assets.images.innovaChassisLeftTail.path,
    //   'chassis_path_vios': Assets.images.viosChassisLeftTail.path,
    //   'chassis_path_cerato': Assets.images.ceratoChassisLeftTail.path,
    // },
  };

  Map<String, int> carPartDirectionIds = {
    // LocalizationKeys.carHead: 1,
    StringKeys.carHead: 2,
    StringKeys.rightHead45: 3,
    StringKeys.leftHead45: 4,
    StringKeys.carTail: 5,
    StringKeys.rightTail45: 6,
    StringKeys.leftTail45: 7,
    // StringKeys.rightHead: 8,
    // StringKeys.leftHead: 9,
    // StringKeys.rightTail: 10,
    // StringKeys.leftTail: 11,
  };
}
