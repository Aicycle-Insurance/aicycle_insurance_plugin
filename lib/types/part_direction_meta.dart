class PartDirectionMeta {
  final String type;
  final String title;
  final dynamic image3DPath;
  final List<double> relativePosition;
  final List<double> verticalRelativePosition;
  final String chassisPath;
  final String kiaChassisPath;
  final String innovaChassisPath;
  final String viosChassisPath;
  final String ceratoChassisPath;

  const PartDirectionMeta({
    required this.type,
    required this.title,
    required this.image3DPath,
    required this.relativePosition,
    required this.verticalRelativePosition,
    required this.chassisPath,
    required this.kiaChassisPath,
    required this.innovaChassisPath,
    required this.viosChassisPath,
    required this.ceratoChassisPath,
  });

  factory PartDirectionMeta.fromJson(Map<String, dynamic> json) =>
      PartDirectionMeta(
        image3DPath: json['3d_image_path'],
        relativePosition: json['relative_position'],
        verticalRelativePosition: json['vertical_relative_position'],
        title: json['title'],
        type: json['type'],
        chassisPath: json['chassis_path'],
        kiaChassisPath: json['chassis_path_kia'],
        innovaChassisPath: json['chassis_path_innova'],
        viosChassisPath: json['chassis_path_vios'],
        ceratoChassisPath: json['chassis_path_cerato'],
      );
}
