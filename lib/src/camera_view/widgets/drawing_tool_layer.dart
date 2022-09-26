// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as imagePlugin;
// import 'package:mime/mime.dart' as mime;

// import '../../../types/damage_assessment.dart';
// import '../../../types/damage_type.dart';
// import '../../../types/user_corrected_damage.dart';
// import '../../common/dialog/process_dialog.dart';
// import '../../constants/colors.dart';
// import '../../constants/damage_types.dart';
// import '../../constants/endpoints.dart';
// import '../../constants/strings.dart';
// import '../../extensions/hex_color_extension.dart';
// import '../../modules/resful_module.dart';
// import '../../modules/resful_module_impl.dart';
// import '../../painter/image_painter.dart';

// enum DrawStatus {
//   none,

//   /// Chuẩn bị (chọn có hoặc không muốn sửa mask thiệt hại)
//   ready,

//   /// Bắt đầu vẽ
//   start,

//   /// Đang vẽ
//   drawing,

//   /// Kết thúc vẽ
//   end
// }

// // ignore: must_be_immutable
// class DrawingToolLayer extends StatefulWidget {
//   const DrawingToolLayer({
//     Key key,
//     this.damageAssess,
//     this.imageUrl,
//     this.onCancelCallBack,
//     this.onSaveCallBack,
//     this.token,
//   }) : super(key: key);

//   final String imageUrl;
//   final String token;
//   final Rx<DamageAssessmentModel> damageAssess;
//   final Function() onCancelCallBack;
//   final Function(List<Uint8List>) onSaveCallBack;

//   @override
//   State<DrawingToolLayer> createState() => _DrawingToolLayerState();
// }

// class _DrawingToolLayerState extends State<DrawingToolLayer> {
//   ///transparent image
//   String transparentImage =
//       "https://upload.wikimedia.org/wikipedia/commons/8/89/HD_transparent_picture.png";

//   /// Trạng thái thay đổi độ rộng bút
//   var isStrokeWidthChanged = false.obs;

//   Rx<DamageTypes> currentDamageType;
//   Rx<File> backgroundImage;
//   Rx<DrawStatus> drawStatus;

//   imagePlugin.Image backgroundImageUI;

//   /// map mask url với dữ liệu mask tương ứng
//   var initNetworkMask = <String, List<String>>{};
//   var damageMaskDrawables = <String, Uint8List>{};

//   /// lưu mask vừa vẽ để hiển thị preview
//   var previewUserMaskImagesBuffer = <Uint8List>[].obs;
//   Size painterSize;

//   /// painter key để lấy kích thước vùng vẽ
//   final GlobalKey painterKey = GlobalKey();

//   @override
//   void initState() {
//     initBackground();
//     drawStatus = Rx<DrawStatus>(DrawStatus.none);
//     super.initState();
//   }

//   /// Khởi tạo background vẽ
//   Future<void> initBackground() async {
//     backgroundImage = Rx<File>(File(widget.imageUrl));
//     backgroundImageUI =
//         imagePlugin.decodeImage(backgroundImage.value.readAsBytesSync());
//     await initMask();
//   }

//   /// Khởi tạo mask đã có
//   Future<void> initMask() async {
//     for (var key
//         in DamageTypeConstant.listDamageType.map((e) => e.damageTypeGuid)) {
//       initNetworkMask[key] = [];
//     }
//     for (var part in widget.damageAssess.value.carParts) {
//       for (var mask in part.carPartDamages) {
//         if (initNetworkMask[mask.uuid] == null) {
//           initNetworkMask[mask.uuid] = [];
//         }
//         initNetworkMask[mask.uuid].add(mask.maskUrl);
//       }
//     }
//     // for (var key in initNetworkMask.keys) {
//     //   if (initNetworkMask[key].isEmpty) {
//     //     initNetworkMask[key].add(transparentImage);
//     //   }
//     // }
//     print(initNetworkMask);

//     await mergeDamageLinkToFile();
//   }

//   Future<void> mergeDamageLinkToFile() async {
//     for (var key in initNetworkMask.keys) {
//       Color _color;
//       //set color
//       final index = DamageTypeConstant.listDamageType
//           .indexWhere((element) => element.damageTypeGuid == key);
//       if (index != -1) {
//         final colorHex =
//             DamageTypeConstant.listDamageType.elementAt(index).colorHex;
//         _color = HexColor.fromHex(colorHex).withOpacity(damageBaseOpacity);
//       }

//       Uint8List finalBytes;

//       ///Merge image
//       if (initNetworkMask[key].isNotEmpty) {
//         final firstUrl = initNetworkMask[key].first;
//         http.Response response = await http.get(firstUrl);
//         final image1 = imagePlugin.decodePng(response.bodyBytes);
//         var mergedImage = imagePlugin.Image(
//             backgroundImageUI.width, backgroundImageUI.height);
//         imagePlugin.copyInto(mergedImage, image1, blend: false);

//         mergedImage = imagePlugin.colorOffset(
//           mergedImage,
//           alpha: -256 + _color.alpha,
//           red: -255 + _color.red,
//           blue: -255 + _color.blue,
//           green: -255 + _color.green,
//         );
//         finalBytes = imagePlugin.encodePng(mergedImage);

//         if (initNetworkMask[key].length > 1) {
//           for (var url in initNetworkMask[key].sublist(1)) {
//             //get image
//             http.Response response = await http.get(url);
//             //join two image

//             final image1 = imagePlugin.decodePng(finalBytes);
//             var image2 = imagePlugin.decodePng(response.bodyBytes);
//             image2 = imagePlugin.colorOffset(
//               image2,
//               alpha: -256 + _color.alpha,
//               red: -255 + _color.red,
//               blue: -255 + _color.blue,
//               green: -255 + _color.green,
//             );
//             var mergedImage = imagePlugin.Image(
//                 backgroundImageUI.width, backgroundImageUI.height);
//             imagePlugin.copyInto(mergedImage, image1, blend: false);
//             imagePlugin.copyInto(mergedImage, image2, dstX: image1.width);

//             finalBytes = imagePlugin.encodePng(mergedImage);
//           }
//         }
//       } else {
//         ///add transparent image
//         http.Response response = await http.get(transparentImage);
//         var trans = imagePlugin.decodeImage(response.bodyBytes);
//         trans = imagePlugin.copyResize(trans,
//             width: backgroundImageUI.width, height: backgroundImageUI.height);
//         finalBytes = imagePlugin.encodePng(trans);
//       }

//       damageMaskDrawables[key] = Uint8List.fromList(finalBytes);
//     }
//   }

//   ///order by: break, dent, crack, scratch
//   List<String> get getMarkUrls {
//     return [
//       initNetworkMask.containsKey(DamageTypeConstant.typeBreak.damageTypeGuid)
//           ? initNetworkMask[DamageTypeConstant.typeBreak.damageTypeGuid]
//           : transparentImage,
//       initNetworkMask.containsKey(DamageTypeConstant.typeCrack.damageTypeGuid)
//           ? initNetworkMask[DamageTypeConstant.typeCrack.damageTypeGuid]
//           : transparentImage,
//       initNetworkMask.containsKey(DamageTypeConstant.typeDent.damageTypeGuid)
//           ? initNetworkMask[DamageTypeConstant.typeDent.damageTypeGuid]
//           : transparentImage,
//       initNetworkMask.containsKey(DamageTypeConstant.typeScratch.damageTypeGuid)
//           ? initNetworkMask[DamageTypeConstant.typeScratch.damageTypeGuid]
//           : transparentImage,
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//         future: initBackground(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting)
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.75),
//               ),
//               padding: const EdgeInsets.all(8.0),
//               margin: const EdgeInsets.all(16.0),
//               child: CircularProgressIndicator(),
//             );
//           if (snap.connectionState == ConnectionState.done) {
//             /// Cbi vẽ
//             drawStatus.value = DrawStatus.ready;
//             return Obx(() {
//               return Stack(
//                 children: [
//                   if (drawStatus.value == DrawStatus.drawing)
//                     Container(
//                       color: Colors.black,
//                       child: Center(
//                         child: ImagePainter(
//                           drawables: damageMaskDrawables.values.toList(),
//                           key: painterKey,
//                           backgroundImage: backgroundImage.value,
//                           onCancelCallBack: () {
//                             widget.onCancelCallBack();
//                             drawStatus.value = DrawStatus.end;
//                           },
//                           onSaveCallBack: (data) {
//                             widget.onSaveCallBack(data);
//                             drawStatus.value = DrawStatus.end;
//                           },
//                           colors: [
//                             //order by: break, dent, crack, scratch
//                             Color(0xFFBD10E0),
//                             Color(0xFFA2FF43),
//                             Color(0xFF0B7CFF),
//                             Color(0xFFFFEC05),
//                           ],
//                         ),
//                       ),
//                     ),
//                   if (drawStatus.value == DrawStatus.ready ||
//                       drawStatus.value == DrawStatus.end)
//                     SafeArea(
//                       child: Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.only(bottom: 16, left: 16),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.5),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Text(
//                                     StringKeys.missingDamage,
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   CupertinoButton(
//                                     padding: EdgeInsets.zero,
//                                     minSize: 0,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                         border: Border.all(color: Colors.white),
//                                       ),
//                                       child: const Text(
//                                         StringKeys.noWord,
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                     onPressed: widget.onCancelCallBack,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   CupertinoButton(
//                                     padding: EdgeInsets.zero,
//                                     minSize: 0,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                       child: Row(
//                                         children: const [
//                                           Text(
//                                             StringKeys.yesWord,
//                                             style: TextStyle(
//                                               color: DefaultColors.blue,
//                                             ),
//                                           ),
//                                           SizedBox(width: 8),
//                                           Icon(
//                                             Icons.edit,
//                                             color: DefaultColors.blue,
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                     onPressed: () {
//                                       drawStatus.value = DrawStatus.drawing;
//                                       // WidgetsBinding.instance
//                                       //     ?.addPostFrameCallback((timeStamp) {
//                                       //   var renderObj = painterKey
//                                       //       .currentContext
//                                       //       ?.findRenderObject() as RenderBox;
//                                       //   // painterSize = renderObj.size;
//                                       //   setDamageMask();
//                                       // });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (drawStatus.value == DrawStatus.drawing)
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Stack(
//                         children: [
//                           // Align(
//                           //   alignment: Alignment.topRight,
//                           //   child: Row(
//                           //     crossAxisAlignment: CrossAxisAlignment.center,
//                           //     mainAxisAlignment: MainAxisAlignment.end,
//                           //     mainAxisSize: MainAxisSize.min,
//                           //     children: [
//                           //       Container(
//                           //         decoration: BoxDecoration(
//                           //           borderRadius: BorderRadius.circular(4),
//                           //           color: Colors.transparent,
//                           //           border: Border.all(
//                           //               width: 1, color: Colors.white),
//                           //         ),
//                           //         child: Row(
//                           //           mainAxisSize: MainAxisSize.min,
//                           //           children: [
//                           //             GestureDetector(
//                           //               onTap: toggleDrawing,
//                           //               child: Container(
//                           //                 height: 32,
//                           //                 width: 48,
//                           //                 decoration: BoxDecoration(
//                           //                   borderRadius:
//                           //                       BorderRadius.circular(4),
//                           //                   color: isDrawing()
//                           //                       ? Colors.white
//                           //                       : Colors.black54,
//                           //                 ),
//                           //                 child: Center(
//                           //                   child: Icon(
//                           //                     Icons.gesture,
//                           //                     color: isDrawing()
//                           //                         ? DefaultColors.blue
//                           //                         : Colors.white54,
//                           //                   ),
//                           //                 ),
//                           //               ),
//                           //             ),
//                           //             GestureDetector(
//                           //               onTap: toggleEraser,
//                           //               child: Container(
//                           //                 height: 32,
//                           //                 width: 48,
//                           //                 decoration: BoxDecoration(
//                           //                   borderRadius:
//                           //                       BorderRadius.circular(4),
//                           //                   color:
//                           //                   // isErasing()
//                           //                   //     ? Colors.white
//                           //                   //     :
//                           //                   Colors.black54,
//                           //                 ),
//                           //                 child: Center(
//                           //                   child: Icon(
//                           //                     PhosphorIcons.eraser,
//                           //                     color:
//                           //                     // isErasing()
//                           //                     //     ? DefaultColors.blue
//                           //                     //     :
//                           //                     Colors.white54,
//                           //                   ),
//                           //                 ),
//                           //               ),
//                           //             ),
//                           //           ],
//                           //         ),
//                           //       ),
//                           //       const SizedBox(width: 16),
//                           //       GestureDetector(
//                           //         onTap: changeDamageType,
//                           //         child: Container(
//                           //           height: 32,
//                           //           padding: const EdgeInsets.symmetric(
//                           //               horizontal: 8),
//                           //           decoration: BoxDecoration(
//                           //             borderRadius:
//                           //                 BorderRadius.circular(8),
//                           //             color: Colors.black54,
//                           //           ),
//                           //           child: Row(
//                           //             mainAxisSize: MainAxisSize.min,
//                           //             children: [
//                           //               CircleAvatar(
//                           //                 backgroundColor: HexColor.fromHex(
//                           //                     currentDamageType
//                           //                         .value.colorHex),
//                           //                 radius: 4,
//                           //               ),
//                           //               const SizedBox(width: 8),
//                           //               Text(
//                           //                 currentDamageType
//                           //                     .value.damageTypeName,
//                           //                 style: const TextStyle(
//                           //                     color: Colors.white,
//                           //                     fontWeight: FontWeight.w500),
//                           //               ),
//                           //               const SizedBox(width: 8),
//                           //               const Icon(
//                           //                 Icons.keyboard_arrow_down_rounded,
//                           //                 color: Colors.white,
//                           //               )
//                           //             ],
//                           //           ),
//                           //         ),
//                           //       ),
//                           //     ],
//                           //   ),
//                           // ),
//                           // Align(
//                           //   alignment: Alignment.centerRight,
//                           //   child: RotatedBox(
//                           //     quarterTurns: -1,
//                           //     child: Column(
//                           //       mainAxisSize: MainAxisSize.min,
//                           //       crossAxisAlignment: CrossAxisAlignment.center,
//                           //       children: [
//                           //         SizedBox(
//                           //           width: Get.width / 2,
//                           //           child: Slider.adaptive(
//                           //             min: 1,
//                           //             max: 50,
//                           //             activeColor: Colors.white,
//                           //             // thumbColor: Colors.white,
//                           //             inactiveColor: Colors.white38,
//                           //             // value: paintController
//                           //             //     .freeStyleStrokeWidth,
//                           //             onChangeStart: (value) =>
//                           //                 isStrokeWidthChanged.value = true,
//                           //             onChangeEnd: (value) =>
//                           //                 isStrokeWidthChanged.value = false,
//                           //             onChanged: (double value) {},
//                           //             // onChanged: setFreeStyleStrokeWidth,
//                           //           ),
//                           //         ),
//                           //       ],
//                           //     ),
//                           //   ),
//                           // ),
//                           // Align(
//                           //   alignment: Alignment.bottomCenter,
//                           //   child: Row(
//                           //     mainAxisAlignment: MainAxisAlignment.start,
//                           //     children: [
//                           //       Visibility(
//                           //         visible: true, // undoable(),
//                           //         child: GestureDetector(
//                           //           onTap: undo,
//                           //           child: Container(
//                           //             height: 48,
//                           //             width: 48,
//                           //             decoration: BoxDecoration(
//                           //               color: Colors.black54,
//                           //               borderRadius:
//                           //                   BorderRadius.circular(8),
//                           //             ),
//                           //             child: const Center(
//                           //               child: Icon(
//                           //                 Icons.replay_rounded,
//                           //                 color: Colors.white,
//                           //               ),
//                           //             ),
//                           //           ),
//                           //         ),
//                           //       ),
//                           //       const SizedBox(width: 8),
//                           //       Visibility(
//                           //         visible: true, // redoable(),
//                           //         child: GestureDetector(
//                           //           onTap: redo,
//                           //           child: Container(
//                           //             height: 48,
//                           //             width: 48,
//                           //             decoration: BoxDecoration(
//                           //               color: Colors.black54,
//                           //               borderRadius:
//                           //                   BorderRadius.circular(8),
//                           //             ),
//                           //             child: Center(
//                           //               child: Transform(
//                           //                 alignment: Alignment.center,
//                           //                 transform:
//                           //                     Matrix4.rotationY(math.pi),
//                           //                 child: const Icon(
//                           //                   Icons.replay_rounded,
//                           //                   color: Colors.white,
//                           //                 ),
//                           //               ),
//                           //             ),
//                           //           ),
//                           //         ),
//                           //       ),
//                           //       const Expanded(child: SizedBox()),
//                           //       Container(
//                           //         padding: const EdgeInsets.all(8),
//                           //         decoration: BoxDecoration(
//                           //           color: Colors.black54,
//                           //           borderRadius: BorderRadius.circular(8),
//                           //         ),
//                           //         child: Row(
//                           //           children: [
//                           //             CupertinoButton(
//                           //               padding: EdgeInsets.zero,
//                           //               minSize: 0,
//                           //               child: Container(
//                           //                 padding: const EdgeInsets.symmetric(
//                           //                   horizontal: 16,
//                           //                   vertical: 6,
//                           //                 ),
//                           //                 decoration: BoxDecoration(
//                           //                   borderRadius:
//                           //                       BorderRadius.circular(4),
//                           //                   border: Border.all(
//                           //                       color: Colors.white),
//                           //                 ),
//                           //                 child: const Text(
//                           //                   StringKeys.cancel,
//                           //                   style: TextStyle(
//                           //                       color: Colors.white),
//                           //                 ),
//                           //               ),
//                           //               onPressed: () {
//                           //                 drawStatus.value = DrawStatus.end;
//                           //                 // paintController.clearDrawables();
//                           //                 widget.onCancelCallBack();
//                           //               },
//                           //             ),
//                           //             const SizedBox(width: 8),
//                           //             CupertinoButton(
//                           //               padding: EdgeInsets.zero,
//                           //               minSize: 0,
//                           //               child: Container(
//                           //                 padding: const EdgeInsets.symmetric(
//                           //                   horizontal: 32,
//                           //                   vertical: 6,
//                           //                 ),
//                           //                 decoration: BoxDecoration(
//                           //                   color: Colors.white,
//                           //                   borderRadius:
//                           //                       BorderRadius.circular(4),
//                           //                 ),
//                           //                 child: const Text(
//                           //                   StringKeys.save,
//                           //                   style: TextStyle(
//                           //                       color: DefaultColors.blue),
//                           //                 ),
//                           //               ),
//                           //               onPressed: finishAnnotate,
//                           //             ),
//                           //           ],
//                           //         ),
//                           //       ),
//                           //     ],
//                           //   ),
//                           // ),
//                           Obx(
//                             () => Visibility(
//                               visible: isStrokeWidthChanged.value,
//                               child: Align(
//                                 alignment: Alignment.center,
//                                 child: CircleAvatar(
//                                   // radius:
//                                   //     paintController.freeStyleStrokeWidth /
//                                   //         2,
//                                   backgroundColor: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                 ],
//               );
//             });
//           } else {
//             return const SizedBox();
//           }
//         });
//   }

//   void finishAnnotate() async {
//     ProgressDialog.showWithCircleIndicator(context, isLandScape: true);

//     // final size = Size(backgroundImageUI.width.toDouble(),
//     //     backgroundImageUI.height.toDouble());

//     List<UserCorrectedDamageItem> correctedItems = [];
//     // for (var drawableItem in damageMaskDrawables.values) {
//     // var renderedImage = await renderDamageMask(
//     //     drawableItem.value, size, damageClassColors[drawableItem.key]);
//     // var pngImageBuffer = (await renderedImage.pngBytes);
//     // correctedItems.add(
//     //   UserCorrectedDamageItem(
//     //       maskData: pngImageBuffer,
//     //       damageClass: drawableItem.key,
//     //       maskImgName: nanoid() + '.png'),
//     // );
//     // previewUserMaskImagesBuffer.add(pngImageBuffer);
//     // }
//     await userCorrectDamage(
//       UserCorrectedDamages(
//         imageId: widget.damageAssess.value.imageId.toString(),
//         correctedData: correctedItems,
//       ),
//       isReAssessment: true,
//     );
//     ProgressDialog.hide(context);
//     widget.onSaveCallBack(previewUserMaskImagesBuffer);
//     drawStatus.value = DrawStatus.end;
//   }

//   Future userCorrectDamage(UserCorrectedDamages userCorrectedDamages,
//       {bool isReAssessment = false}) async {
//     try {
//       RestfulModule restfulModule = RestfulModuleImpl();

//       /// upload ảnh mask
//       List<dynamic> filePaths =
//           userCorrectedDamages.correctedData.map((imageData) {
//         return 'INSURANCE_RESULT/${imageData.maskImgName}';
//       }).toList();

//       var response = await restfulModule.post(
//         Endpoints.getUploadUrl,
//         {'filePaths': filePaths},
//         token: widget.token,
//       );
//       var uploadUrls = response.body['urls'];

//       for (int idx = 0; idx < filePaths.length; idx++) {
//         List<int> imageData = userCorrectedDamages.correctedData[idx].maskData;
//         var url = Uri.parse(uploadUrls[idx]['uploadUrl']);
//         var uploadRes = await http.put(
//           url,
//           body: imageData,
//           headers: {
//             'Content-Type': mime.lookupMimeType(
//                 userCorrectedDamages.correctedData[idx].maskImgName)
//           },
//         );
//         if (uploadRes.statusCode != 200) {
//           throw Exception(
//               "Upload failed. Got status code ${uploadRes.statusCode}");
//         }
//       }

//       ///
//       /// call process the new result
//       List<Map<String, String>> damagePayload = [];
//       for (var correctedData in userCorrectedDamages.correctedData) {
//         int idx = DamageTypeConstant.listDamageType.indexWhere(
//             (element) => element.damageTypeName == correctedData.damageClass);

//         damagePayload.add({
//           "class": DamageTypeConstant.listDamageType[idx].damageTypeGuid,
//           "maskPath": correctedData.maskImgName,
//         });
//       }
//       if (!isReAssessment) {
//         await restfulModule.post(
//           Endpoints.runEnginePercent,
//           {
//             "images": [
//               {
//                 "imageId": userCorrectedDamages.imageId,
//                 "damages": damagePayload,
//               }
//             ]
//           },
//           token: widget.token,
//         );
//       } else {
//         await restfulModule.post(
//           Endpoints.callEngineAfterUserEdit(userCorrectedDamages.imageId),
//           {"damages": damagePayload},
//           token: widget.token,
//         );
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Future<ui.Image> renderDamageMask(
//   //     Drawable maskDrawable, Size size, Color color) async {
//   //   final recorder = ui.PictureRecorder();
//   //   final canvas = Canvas(recorder);

//   //   canvas.save();
//   //
//   //   // var _scale = paintController.painterKey.currentContext?.size ?? size;
//   //
//   //   canvas.transform(Matrix4.identity()
//   //       .scaled(size.width / _scale.width, size.height / _scale.height)
//   //       .storage);
//   //   canvas.drawColor(color, ui.BlendMode.clear);
//   //   canvas.saveLayer(Rect.largest, Paint());
//   //
//   //   maskDrawable.draw(canvas, size);
//   //   canvas.restore();
//   //
//   //   var renderedImage = await recorder
//   //       .endRecording()
//   //       .toImage(size.width.floor(), size.height.floor());
//   //   return renderedImage;
//   // }

//   // void setFreeStyleStrokeWidth(double value) {
//   //   paintController.freeStyleStrokeWidth = value;
//   // }

//   // void startDrawing() {
//   //   updateFreeStyle(FreeStyleMode.draw);
//   // }

//   // bool isDrawing() {
//   //   return paintController.freeStyleMode == FreeStyleMode.draw;
//   // }
//   //
//   // void toggleEraser() {
//   //   startEraser();
//   // }

//   // void toggleDrawing() {
//   //   startDrawing();
//   // }

//   // void startEraser() {
//   //   updateFreeStyle(FreeStyleMode.erase);
//   // }
//   //
//   // void stopFreeStyle() {
//   //   updateFreeStyle(FreeStyleMode.none);
//   // }

//   // bool isErasing() {
//   //   return paintController.freeStyleMode == FreeStyleMode.erase;
//   // }

//   // void updateFreeStyle(FreeStyleMode value) {
//   //   paintController.freeStyleMode = value;
//   // }

//   void undo() {
//     // paintController.undo();
//   }

//   void redo() {
//     // paintController.redo();
//   }

//   // bool undoable() => paintController.canUndo;

//   // bool redoable() => paintController.canRedo;
// }
