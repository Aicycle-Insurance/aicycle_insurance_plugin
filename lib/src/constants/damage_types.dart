import 'package:aicycle_insurance/src/extensions/hex_color_extension.dart';
import 'package:flutter/material.dart';

import '../../types/damage_type.dart';

class DamageTypeConstant {
  DamageTypeConstant._();
  static DamageTypes typeBreak = DamageTypes(
    damageTypeId: '1',
    damageTypeName: 'Vỡ, thủng, rách',
    damageTypeGuid: 'wMxucuruHBUupNOoVy2MF',
    colorHex: '#BD10E0',
  );

  static DamageTypes typeDent = DamageTypes(
    damageTypeId: '2',
    damageTypeName: 'Móp (bẹp)',
    damageTypeGuid: 'zmMJ5xgjmUpqmHd99UNq3',
    colorHex: '#A2FF43',
  );

  static DamageTypes typeCrack = DamageTypes(
    damageTypeId: '3',
    damageTypeName: 'Nứt (rạn)',
    damageTypeGuid: '5IfgehKG297bQPLkYoZTw',
    colorHex: '#0B7CFF',
  );

  static DamageTypes typeScratch = DamageTypes(
    damageTypeId: '4',
    damageTypeName: 'Trầy (xước)',
    damageTypeGuid: 'yfMzer07THdYoCI1SM2LN',
    colorHex: '#FFEC05',
  );

  static List<DamageTypes> listDamageType = [
    typeBreak,
    typeDent,
    typeCrack,
    typeScratch
  ];
}

final damageClassColors = <String, Color>{
  for (var type in DamageTypeConstant.listDamageType)
    type.damageTypeName: HexColor.fromHex(type.colorHex)
};
