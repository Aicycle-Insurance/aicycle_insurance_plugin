import 'dart:io';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  ImageUtils._();
  static Future<PickedFile> compressImage(File img) async {
    File compressedFile;
    try {
      final Directory extDir = await getTemporaryDirectory();
      final appImageDir =
          await Directory('${extDir.path}/app_images').create(recursive: true);

      // compress
      final String targetPath =
          '${appImageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      compressedFile = await FlutterImageCompress.compressAndGetFile(
        img.absolute.path,
        targetPath,
        quality: 100, minHeight: 1200, minWidth: 1600,
        // format: CompressFormat.png,
      );
      if (compressedFile == null) {
        return PickedFile(img.path);
      }

      return PickedFile(compressedFile.path);
    } catch (e) {
      return PickedFile(img.path);
    }
  }

  static Future<ui.Image> getUiImage(String imageAssetPath) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image baseSizeImage =
        image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage = image.copyResize(baseSizeImage,
        height: baseSizeImage.height, width: baseSizeImage.width);
    ui.Codec codec =
        await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}
