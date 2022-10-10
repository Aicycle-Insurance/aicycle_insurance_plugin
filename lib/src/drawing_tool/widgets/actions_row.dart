import 'package:aicycle_insurance_non_null_safety/src/constants/colors.dart';
import 'package:aicycle_insurance_non_null_safety/src/flutter_painter/flutter_painter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActionsRow extends StatelessWidget {
  const ActionsRow({Key key, this.paintController}) : super(key: key);
  final PainterController paintController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.transparent,
        border: Border.all(width: 1, color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: toggleDrawing,
            child: Container(
              height: 32,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isDrawing() ? Colors.white : Colors.black54,
              ),
              child: Center(
                child: Icon(
                  Icons.gesture,
                  color: isDrawing() ? DefaultColors.blue : Colors.white54,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: toggleEraser,
            child: Container(
              height: 32,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isErasing() ? Colors.white : Colors.black54,
              ),
              child: Center(
                child: Icon(
                  FontAwesomeIcons.eraser,
                  // PhosphorIcons.eraser,
                  color: isErasing() ? DefaultColors.blue : Colors.white54,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: toggleScale,
            child: Container(
              height: 32,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isScaling() ? Colors.white : Colors.black54,
              ),
              child: Center(
                child: Icon(
                  Icons.zoom_out_map_rounded,
                  // PhosphorIcons.arrows_out,
                  color: isScaling() ? DefaultColors.blue : Colors.white54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleDrawing() {
    updateFreeStyle(FreeStyleMode.draw);
  }

  void toggleEraser() {
    updateFreeStyle(FreeStyleMode.erase);
  }

  void toggleScale() {
    updateFreeStyle(FreeStyleMode.none);
  }

  bool isErasing() {
    return paintController.freeStyleMode == FreeStyleMode.erase;
  }

  bool isScaling() {
    return paintController.freeStyleMode == FreeStyleMode.none;
  }

  bool isDrawing() {
    return paintController.freeStyleMode == FreeStyleMode.draw;
  }

  void updateFreeStyle(FreeStyleMode value) {
    paintController.freeStyleMode = value;
  }
}
