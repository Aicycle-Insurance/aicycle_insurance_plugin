class DamageTypes {
  DamageTypes({
    this.damageTypeId,
    this.damageTypeName,
    this.damageTypeGuid,
    this.colorHex,
  });

  String damageTypeId;
  String damageTypeName;
  String damageTypeGuid;
  String colorHex;

  factory DamageTypes.fromJson(Map<String, dynamic> json) => DamageTypes(
        damageTypeId: json["damageTypeId"],
        damageTypeName: json["damageTypeName"],
        damageTypeGuid: json["damageTypeGuid"],
        colorHex: json["damageTypeColor"],
      );

  Map<String, dynamic> toJson() => {
        "damageTypeId": damageTypeId,
        "damageTypeName": damageTypeName,
        "damageTypeGuid": damageTypeGuid,
        "damageTypeColor": colorHex,
      };
}
