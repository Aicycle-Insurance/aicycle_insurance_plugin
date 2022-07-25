import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  ImageUtils._();
  static Future<File> compressImage(File img) async {
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
        quality: 100,
        // format: CompressFormat.png,
      );
      if (compressedFile == null) {
        return File(img.path);
      }

      return File(compressedFile.path);
    } catch (e) {
      return File(img.path);
    }
  }
}
