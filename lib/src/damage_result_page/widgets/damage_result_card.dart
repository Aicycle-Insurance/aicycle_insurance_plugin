import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../types/damage_result_model.dart';
import '../../../src/constants/strings.dart';
// import '../../../src/utils/string_utils.dart';

class DamageResultCard extends StatelessWidget {
  const DamageResultCard({Key key, this.damageResult}) : super(key: key);

  final PTIDamageResult damageResult;
  static const String lengthUnit = 'dm²';

  @override
  Widget build(BuildContext context) {
    String partArea = damageResult.area != null
        ? '  (${(damageResult.area ?? 0).toStringAsFixed(2)} $lengthUnit)'
        : '';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _tableRow(
              title: '${StringKeys.position}:',
              damages: [damageResult.location]),
          _tableRow(
            title: '${StringKeys.tabCarPart}:',
            damages: [damageResult.vehiclePartName + partArea],
          ),
          _tableRow(
            title: '${StringKeys.damageLevel}:',
            damages: damageResult.damages.isEmpty
                ? [StringKeys.noDamage]
                : damageResult.damages.map((e) => e).toList(),
          ),
          _tableRow(
            title: '${StringKeys.plan}:',
            damages: [damageResult.repairPlan],
          ),
          // _tableRow(
          //   title: StringKeys.repaintPrice,
          //   damages: [
          //     StringUtils.formatPriceNumber(
          //             double.parse(damageResult.price.toString())) +
          //         ' đ'
          //   ],
          // ),
          // _tableRow(
          //   title: StringKeys.effortPrice,
          //   damages: [
          //     StringUtils.formatPriceNumber(
          //             double.parse(damageResult.laborCost.toString())) +
          //         ' đ'
          //   ],
          // ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: damageResult.images.length,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _imageContainer(context, damageResult.images[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageContainer(BuildContext context, PTIImage image) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: CachedNetworkImage(
            cacheKey: image.imageUrl,
            imageUrl: image.imageUrl,
            height: 72,
            width: 116,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _tableRow({
    String title,
    List<dynamic> damages,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...damages.map((damage) {
                  if (damage is String) {
                    return Text(
                      damage,
                      style: const TextStyle(
                        height: 1.3,
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  } else if (damage is PTIDamage) {
                    String damageArea =
                        '  (${damage.damageArea.toStringAsFixed(2)} $lengthUnit)';
                    return Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          height: 1.3,
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                        children: [
                          TextSpan(text: damage.damageTypeName + damageArea),
                          TextSpan(
                            text:
                                '  •  ${(damage.damagePercentage * 100).toStringAsFixed(2)}%',
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 14,
                              // color: damage.damageColor,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.start,
                    );
                  } else {
                    return const SizedBox();
                  }
                }).toList()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
