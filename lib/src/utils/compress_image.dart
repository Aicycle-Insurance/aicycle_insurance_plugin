import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  ImageUtils._();
  static Future<XFile> compressImage(File img) async {
    late File? compressedFile;
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
        quality: 100,
        minHeight: 1200,
        minWidth: 1600,
        // format: CompressFormat.png,
      );
      if (compressedFile == null) {
        return XFile(img.path);
      }

      return XFile(compressedFile.path);
    } catch (e) {
      return XFile(img.path);
    }
  }
}
