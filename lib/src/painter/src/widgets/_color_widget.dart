import 'package:aicycle_insurance/src/utils/functions.dart';
import 'package:flutter/material.dart';

class ColorItem extends StatelessWidget {
  const ColorItem({Key key, this.onTap, this.isSelected, this.color})
      : super(key: key);
  final VoidCallback onTap;
  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: isSelected ? Colors.white70 : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[200])),
              child: CircleAvatar(
                  radius: isSelected ? 8 : 6, backgroundColor: color),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(getTitleFromColor(color))
          ],
        ),
      ),
    );
  }
}

List<Color> editorColors = [
  Colors.black,
  Colors.white,
  Colors.red,
  Colors.grey,
  Colors.teal,
  Colors.cyan,
  Colors.blue,
  Colors.blueAccent,
  Colors.greenAccent,
  Colors.green,
  Colors.pink,
  Colors.yellow,
  Colors.orange,
  Colors.brown,
];
