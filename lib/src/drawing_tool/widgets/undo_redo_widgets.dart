import 'dart:math' as math;
import '../../../src/flutter_painter/flutter_painter.dart';
import 'package:flutter/material.dart';

class UndoRedoActionWidget extends StatelessWidget {
  const UndoRedoActionWidget({Key key, this.painterController})
      : super(key: key);
  final PainterController painterController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Visibility(
          visible: undoable(),
          child: GestureDetector(
            onTap: undo,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.replay_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Visibility(
          visible: redoable(),
          child: GestureDetector(
            onTap: redo,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: const Icon(
                    Icons.replay_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void undo() {
    painterController.undo();
  }

  void redo() {
    painterController.redo();
  }

  bool undoable() => painterController.canUndo;

  bool redoable() => painterController.canRedo;
}
