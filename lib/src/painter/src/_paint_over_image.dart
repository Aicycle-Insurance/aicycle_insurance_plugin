// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart' hide Image;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

// // import 'package:flutter/services.dart';
// // import 'package:flutter_svg/flutter_svg.dart';

// import '../../../aicycle_insurance.dart';
// // import 'package:aicycle_insurance/gen/assets.gen.dart';
// import '../../../gen/assets.gen.dart';
// import '../../utils/functions.dart';
// import '_image_painter.dart';
// import '_ported_interactive_viewer.dart';
// import 'widgets/_color_widget.dart';
// // import 'widgets/_mode_widget.dart';
// import 'widgets/_range_slider.dart';

// export '_image_painter.dart';

// ///[ImagePainter] widget.
// @immutable
// class ImagePainter extends StatefulWidget {
//   ///Controller of the Painter
//   final PaintController controller;

//   ///List damages
//   final List<Uint8List> drawables;

//   ///Image url of car
//   final String backgroundUrl;

//   ///  Image background
//   final File backgroundImage;

//   ///Height of the Widget. Image is subjected to fit within the given height.
//   final double height;

//   ///Width of the widget. Image is subjected to fit within the given width.
//   final double width;

//   ///Widget to be shown during the conversion of provided image to [ui.Image].
//   final Widget placeHolder;

//   ///Defines whether the widget should be scaled or not. Defaults to [false].
//   final bool isScalable;

//   ///Flag to determine signature or image;
//   final bool isSignature;

//   ///Signature mode background color
//   final Color signatureBackgroundColor;

//   ///List of colors for color selection
//   ///If not provided, default colors are used.
//   final List<Color> colors;

//   ///Icon Widget of strokeWidth.
//   final Widget brushIcon;

//   ///Widget of Color Icon in control bar.
//   final Widget colorIcon;

//   ///Widget for Undo last action on control bar.
//   final Widget undoIcon;

//   ///Widget for clearing all actions on control bar.
//   final Widget clearAllIcon;

//   ///Define where the controls is located.
//   ///`true` represents top.
//   final bool controlsAtTop;

//   final Function() onCancelCallBack;

//   final Function(List<Uint8List>) onSaveCallBack;

//   const ImagePainter({
//     Key key,
//     this.controller,
//     this.drawables,
//     this.backgroundUrl,
//     this.backgroundImage,
//     this.height,
//     this.width,
//     this.placeHolder,
//     this.isScalable = true,
//     this.isSignature,
//     this.signatureBackgroundColor,
//     this.colors,
//     this.brushIcon,
//     this.colorIcon,
//     this.undoIcon,
//     this.clearAllIcon,
//     this.controlsAtTop,
//     this.onCancelCallBack,
//     this.onSaveCallBack,
//   }) : super(key: key);

//   @override
//   ImagePainterState createState() => ImagePainterState();
// }

// ///
// class ImagePainterState extends State<ImagePainter> {
//   ui.Image _image;
//   File _backgroundImage;
//   ui.Image _backgroundImageUI;
//   bool _inDrag = false;
//   final _controller = ValueNotifier<PaintController>(null);
//   final _isLoaded = ValueNotifier<bool>(false);
//   final _paintHistory = <PaintInfo>[];
//   var _points = <Offset>[];
//   TextEditingController _textController;
//   Offset _start, _end;
//   int _strokeMultiplier = 1;
//   int currentColorIndex = 0;

//   List<Uint8List> drawables;

//   @override
//   void initState() {
//     super.initState();
//     drawables = widget.drawables.toList();
//     _controller.value =
//         widget.controller ?? PaintController(color: widget.colors.first);
//     _resolveAndConvertBackgroundImage();
//     _resolveAndConvertImage();
//     _textController = TextEditingController();
//   }

//   @override
//   void didUpdateWidget(ImagePainter oldWidget) {
//     if (oldWidget.controller != widget.controller) {
//       setState(() {
//         _controller.value = widget.controller;
//       });
//     }
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _isLoaded.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   Paint get _painter => Paint()
//     ..color = _controller.value.color
//     ..strokeWidth = _controller.value.strokeWidth * _strokeMultiplier
//     ..style = _controller.value.mode == PaintMode.dashLine
//         ? PaintingStyle.stroke
//         : _controller.value.paintStyle;

//   Future<void> _resolveAndConvertBackgroundImage() async {
//     _backgroundImage = widget.backgroundImage;
//     final img = await widget.backgroundImage.readAsBytes();
//     _backgroundImageUI = await _convertImage(img);
//     if (_backgroundImageUI == null) {
//       throw ("_backgroundImage couldn't be resolved.");
//     }
//     _controller.value =
//         _controller.value.copyWith(backgroundImageUI: _backgroundImageUI);
//     _setStrokeMultiplier();
//   }

//   ///Converts the image from Controller
//   Future<void> _resolveAndConvertImage() async {
//     _image = await _convertImage(drawables[currentColorIndex]);

//     if (_image == null) {
//       throw ("${drawables[currentColorIndex]} couldn't be resolved.");
//     }
//     _controller.value = _controller.value.copyWith(image: _image);
//     _isLoaded.value = _image != null;
//   }

//   ///Dynamically sets stroke multiplier on the basis of widget size.
//   ///Implemented to avoid thin stroke on high res images.
//   _setStrokeMultiplier() {
//     if ((_backgroundImageUI.height + _backgroundImageUI.width) > 1000) {
//       _strokeMultiplier =
//           (_backgroundImageUI.height + _backgroundImageUI.width) ~/ 1000;
//     }
//   }

//   ///Completer function to convert asset or file image to [ui.Image] before drawing on custompainter.
//   Future<ui.Image> _convertImage(Uint8List img) async {
//     final completer = Completer<ui.Image>();
//     ui.decodeImageFromList(img, (image) {
//       _isLoaded.value = true;
//       return completer.complete(image);
//     });
//     return completer.future;
//   }

//   ///Completer function to convert network image to [ui.Image] before drawing on custompainter.
//   Future<ui.Image> loadNetworkImage(String path) async {
//     final completer = Completer<ImageInfo>();
//     var img = NetworkImage(path);
//     img.resolve(const ImageConfiguration()).addListener(
//         ImageStreamListener((info, _) => completer.complete(info)));
//     final imageInfo = await completer.future;
//     _isLoaded.value = true;
//     return imageInfo.image;
//   }

//   ///Generates [Uint8List] of the [ui.Image] generated by the [renderImage()] method.
//   ///Can be converted to image file by writing as bytes.
//   Future<Uint8List> exportImage() async {
//     ui.Image _convertedImage;

//     _convertedImage = await _renderImage();

//     final byteData =
//         await _convertedImage.toByteData(format: ui.ImageByteFormat.png);
//     return byteData.buffer.asUint8List();
//   }

//   ///Save current state to corresponding drawable of current color index
//   ///Then clear all paintHistory
//   Future<void> updateDrawable() async {
//     drawables[currentColorIndex] =
//         await exportImage().whenComplete(() => setState(_paintHistory.clear));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<bool>(
//       valueListenable: _isLoaded,
//       builder: (_, loaded, __) {
//         if (loaded) {
//           return _paintImage();
//         } else {
//           return Container(
//             height: widget.height ?? double.maxFinite,
//             width: widget.width ?? double.maxFinite,
//             child: Center(
//               child: widget.placeHolder ?? const CircularProgressIndicator(),
//             ),
//           );
//         }
//       },
//     );
//   }

//   ///paints image on given constrains for drawing if image is not null.
//   Widget _paintImage() {
//     return Stack(
//       alignment: Alignment.topCenter,
//       children: [
//         Container(
//           height: widget.height ?? double.maxFinite,
//           width: widget.width ?? double.maxFinite,
//           child: Column(
//             children: [
//               Expanded(
//                 child: FittedBox(
//                   alignment: FractionalOffset.center,
//                   child: ClipRect(
//                     child: ValueListenableBuilder<PaintController>(
//                       valueListenable: _controller,
//                       builder: (_, controller, __) {
//                         return controller.backgroundImageUI == null
//                             ? const SizedBox(
//                                 height: 200,
//                                 width: 200,
//                               )
//                             : ImagePainterTransformer(
//                                 maxScale: 2.4,
//                                 minScale: 1,
//                                 panEnabled: controller.mode == PaintMode.none,
//                                 scaleEnabled: widget.isScalable,
//                                 onInteractionUpdate: (details) =>
//                                     _scaleUpdateGesture(details, controller),
//                                 onInteractionEnd: (details) async =>
//                                     await _scaleEndGesture(details, controller),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     image: DecorationImage(
//                                       image: FileImage(_backgroundImage),
//                                       fit: BoxFit.fill,
//                                     ),
//                                   ),
//                                   child: Opacity(
//                                     opacity: 0.5,
//                                     child: CustomPaint(
//                                       size: Size(
//                                           controller.backgroundImageUI.width
//                                               .toDouble(),
//                                           controller.backgroundImageUI.height
//                                               .toDouble()),
//                                       willChange: true,
//                                       isComplex: true,
//                                       painter: DrawImage(
//                                         image: controller.image,
//                                         backgroundColor:
//                                             widget.colors[currentColorIndex],
//                                         points: _points,
//                                         paintHistory: _paintHistory,
//                                         isDragging: _inDrag,
//                                         update: UpdatePoints(
//                                             start: _start,
//                                             end: _end,
//                                             painter: _painter,
//                                             mode: controller.mode),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: MediaQuery.of(context).padding.bottom)
//             ],
//           ),
//         ),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _buildControls(),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4),
//                   color: Colors.black.withOpacity(0.5),
//                 ),
//                 margin: EdgeInsets.all(16),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         widget.onCancelCallBack();
//                       },
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(color: Colors.white),
//                         ),
//                         child: Text(
//                           "Hủy",
//                           style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 12,
//                     ),
//                     InkWell(
//                       onTap: () {
//                         widget.onSaveCallBack(drawables);
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 24, vertical: 6),
//                         child: Text(
//                           "Lưu",
//                           style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF5768FF),
//                               fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//         Align(
//           alignment: Alignment.centerRight,
//           child: RotatedBox(
//             quarterTurns: 3,
//             child: SizedBox(
//               height: 60,
//               width: MediaQuery.of(context).size.width / 2,
//               child: ValueListenableBuilder<PaintController>(
//                 valueListenable: _controller,
//                 builder: (_, ctrl, __) {
//                   return RangedSlider(
//                     value: ctrl.strokeWidth,
//                     onChanged: (value) =>
//                         _controller.value = ctrl.copyWith(strokeWidth: value),
//                   );
//                 },
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   ///Fires while user is interacting with the screen to record painting.
//   void _scaleUpdateGesture(ScaleUpdateDetails onUpdate, PaintController ctrl) {
//     setState(
//       () {
//         _inDrag = true;
//         _start ??= onUpdate.focalPoint;
//         _end = onUpdate.focalPoint;
//         if (ctrl.mode == PaintMode.freeStyle || ctrl.mode == PaintMode.erase) {
//           _points.add(_end);
//         }

//         if (ctrl.mode == PaintMode.text &&
//             _paintHistory
//                 .where((element) => element.mode == PaintMode.text)
//                 .isNotEmpty) {
//           _paintHistory
//               .lastWhere((element) => element.mode == PaintMode.text)
//               .offset = [_end];
//         }
//       },
//     );
//   }

//   ///Fires when user stops interacting with the screen.
//   Future<void> _scaleEndGesture(
//       ScaleEndDetails onEnd, PaintController controller) async {
//     setState(() {
//       _inDrag = false;
//       if (_start != null &&
//           _end != null &&
//           (controller.mode == PaintMode.freeStyle ||
//               controller.mode == PaintMode.erase)) {
//         _points.add(null);
//         _addFreeStylePoints();
//         _points.clear();
//       } else if (_start != null &&
//           _end != null &&
//           controller.mode != PaintMode.text) {
//         _addEndPoints();
//       }
//       _start = null;
//       _end = null;
//     });
//     ///clear paint history to increase performance
//     await updateDrawable();
//     await _resolveAndConvertImage();
//   }

//   void _addEndPoints() => _paintHistory.add(
//         PaintInfo(
//           offset: <Offset>[_start, _end],
//           painter: _painter,
//           mode: _controller.value.mode,
//         ),
//       );

//   void _addFreeStylePoints() => _paintHistory.add(
//         PaintInfo(
//           offset: <Offset>[..._points],
//           painter: _painter,
//           mode: _controller.value.mode,
//         ),
//       );

//   ///Provides [ui.Image] of the recorded canvas to perform action.
//   Future<ui.Image> _renderImage() async {
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     final painter = DrawImage(image: _image, paintHistory: _paintHistory);
//     final size = Size(_image.width.toDouble(), _image.height.toDouble());
//     painter.paint(canvas, size);
//     return recorder
//         .endRecording()
//         .toImage(size.width.floor(), size.height.floor());
//   }

//   PopupMenuItem _showColorPicker(PaintController controller) {
//     return PopupMenuItem(
//         enabled: false,
//         child: RotatedBox(
//           quarterTurns: 1,
//           child: Center(
//             child: Wrap(
//               // mainAxisSize: MainAxisSize.min,
//               // crossAxisAlignment: CrossAxisAlignment.start,
//               // mainAxisAlignment: MainAxisAlignment.spaceAround,
//               alignment: WrapAlignment.center,
//               spacing: 10,
//               runSpacing: 10,
//               direction: Axis.vertical,
//               children:
//                   (widget.colors ?? editorColors).asMap().entries.map((color) {
//                 return ColorItem(
//                   isSelected: color == controller.color,
//                   color: color.value,
//                   onTap: () async {
//                     await updateDrawable();
//                     _controller.value = controller.copyWith(
//                       color: color.value,
//                     );
//                     currentColorIndex = color.key;
//                     _resolveAndConvertImage(); //reload image
//                     Navigator.pop(context);
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//         ));
//   }

//   Widget _buildControls() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.transparent,
//       child: Row(
//         children: [
//           // PopupMenuButton(
//           //   tooltip: "Change Brush Size",
//           //   shape: ContinuousRectangleBorder(
//           //     borderRadius: BorderRadius.circular(20),
//           //   ),
//           //   icon:
//           //       widget.brushIcon ?? Icon(Icons.brush, color: Colors.grey[700]),
//           //   itemBuilder: (_) => [_showRangeSlider()],
//           // ),
//           // IconButton(icon: Icon(Icons.text_format), onPressed: _openTextDialog),

//           // IconButton(
//           //     tooltip: "Undo",
//           //     icon:
//           //         widget.undoIcon ?? Icon(Icons.reply, color: Colors.grey[700]),
//           //     onPressed: () {
//           //       if (_paintHistory.isNotEmpty) {
//           //         setState(_paintHistory.removeLast);
//           //       }
//           //     }),
//           // IconButton(
//           //   tooltip: "Clear all progress",
//           //   icon: widget.clearAllIcon ??
//           //       Icon(Icons.clear, color: Colors.grey[700]),
//           //   onPressed: () => setState(_paintHistory.clear),
//           // ),
//           const Spacer(),
//           ValueListenableBuilder<PaintController>(
//             valueListenable: _controller,
//             builder: (_, _ctrl, __) => Container(
//               decoration: BoxDecoration(
//                 color: Colors.transparent,
//                 border: Border.all(color: Colors.white, width: 2),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Row(
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       _controller.value =
//                           _ctrl.copyWith(mode: PaintMode.freeStyle);
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(2),
//                         color: _ctrl.mode == PaintMode.freeStyle
//                             ? Colors.white
//                             : Colors.transparent,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8, horizontal: 12),
//                       child: Assets.icons.icDraw.svg(
//                         package: packageName,
//                         color: _ctrl.mode == PaintMode.freeStyle
//                             ? Color(0xFF5768FF)
//                             : Colors.grey,
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       _controller.value = _ctrl.copyWith(mode: PaintMode.erase);
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(2),
//                         color: _ctrl.mode == PaintMode.erase
//                             ? Colors.white
//                             : Colors.transparent,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8, horizontal: 12),
//                       child: RotatedBox(
//                         quarterTurns: 3,
//                         child: Assets.icons.icErase.svg(
//                           package: packageName,
//                           color: _ctrl.mode == PaintMode.erase
//                               ? Color(0xFF5768FF)
//                               : Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(
//             width: 16,
//           ),
//           ValueListenableBuilder<PaintController>(
//               valueListenable: _controller,
//               builder: (_, controller, __) {
//                 return PopupMenuButton(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   shape: ContinuousRectangleBorder(
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                   tooltip: "Change color",
//                   child: Container(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.height * 0.3,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.75),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 16, vertical: 3.0),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           height: 10,
//                           width: 10,
//                           decoration: BoxDecoration(
//                             color: controller.color,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 8,
//                         ),
//                         Text(
//                           getTitleFromColor(controller.color),
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         const SizedBox(
//                           width: 16,
//                         ),
//                         Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           color: Colors.white,
//                         )
//                       ],
//                     ),
//                   ),
//                   itemBuilder: (_) => [_showColorPicker(controller)],
//                 );
//               }),
//         ],
//       ),
//     );
//   }
// }

// ///Gives access to manipulate the essential components like [strokeWidth], [Color] and [PaintMode].
// @immutable
// class PaintController {
//   ///Tracks [strokeWidth] of the [Paint] method.
//   final double strokeWidth;

//   ///Tracks [Color] of the [Paint] method.
//   final Color color;

//   ///Tracks [PaintingStyle] of the [Paint] method.
//   final PaintingStyle paintStyle;

//   ///Tracks [PaintMode] of the current [Paint] method.
//   final PaintMode mode;

//   ///Any text.
//   final String text;

//   ///Repaint image url
//   final ui.Image image;
//   final ui.Image backgroundImageUI;

//   ///Constructor of the [PaintController] class.
//   const PaintController(
//       {this.strokeWidth = 4.0,
//       this.color = Colors.red,
//       this.image,
//       this.backgroundImageUI,
//       this.mode = PaintMode.freeStyle,
//       this.paintStyle = PaintingStyle.stroke,
//       this.text = ""});

//   @override
//   bool operator ==(Object o) {
//     if (identical(this, o)) return true;

//     return o is PaintController &&
//         o.strokeWidth == strokeWidth &&
//         o.color == color &&
//         o.image == image &&
//         o.backgroundImageUI == backgroundImageUI &&
//         o.paintStyle == paintStyle &&
//         o.mode == mode &&
//         o.text == text;
//   }

//   @override
//   int get hashCode {
//     return strokeWidth.hashCode ^
//         color.hashCode ^
//         paintStyle.hashCode ^
//         mode.hashCode ^
//         text.hashCode;
//   }

//   ///copyWith Method to access immutable controller.
//   PaintController copyWith(
//       {double strokeWidth,
//       ui.Image image,
//       ui.Image backgroundImageUI,
//       Color color,
//       PaintMode mode,
//       PaintingStyle paintingStyle,
//       String text}) {
//     return PaintController(
//         strokeWidth: strokeWidth ?? this.strokeWidth,
//         backgroundImageUI: backgroundImageUI ?? this.backgroundImageUI,
//         color: color ?? this.color,
//         image: image ?? this.image,
//         mode: mode ?? this.mode,
//         paintStyle: paintingStyle ?? paintStyle,
//         text: text ?? this.text);
//   }
// }
