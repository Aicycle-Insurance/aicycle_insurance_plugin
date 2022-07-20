import 'dart:io';

import 'package:aicycle_insurance/src/constants/endpoints.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart' as mime;

class UploadResponse {
  final String filePath;
  final String imageName;

  UploadResponse({required this.filePath, required this.imageName});
}

Future<UploadResponse?> upLoadImageToS3({
  required String token,
  required String imageFiles,
}) async {
  List<bool> results = [];
  try {
    DateTime now = DateTime.now();
    var tempFile = File(imageFiles);
    // setup
    String filePath =
        'INSURANCE/${now.millisecondsSinceEpoch}/${basename(tempFile.path)}';
    String imageName = basename(tempFile.path);

    List<File> localImageFiles = [];
    localImageFiles.add(tempFile);

    // Upload all images of all folders
    // Get upload Urls
    List<dynamic> uploadUrls =
        await getUploadImageUrls(filePaths: [filePath], token: token);
    for (int idx = 0; idx < uploadUrls.length; idx++) {
      File file = localImageFiles[idx];
      var imageData = await file.readAsBytes();
      var url = Uri.parse(uploadUrls[idx]['uploadUrl'] ?? '');
      // ignore: unused_local_variable
      var uploadRes = await http.put(
        url,
        body: imageData,
        headers: {
          'Content-Type': mime.lookupMimeType(basename(file.path)) ?? ''
        },
      );
      if (uploadRes.statusCode == 200) {
        results.add(true);
      } else {
        results.add(false);
      }
    }
    if (results.every((element) => element)) {
      return UploadResponse(
        filePath: filePath,
        imageName: imageName,
      );
    }
  } catch (e) {
    rethrow;
  }
}

Future<List<String>> getUploadImageUrls({
  required List<String> filePaths,
  required String token,
}) async {
  try {
    Map<String, String> header = {'authorization': 'Bearer $token'};
    GetConnect getConnect = Get.find();
    var response = await getConnect.post(
      Endpoints.getUploadUrl,
      {'filePaths': filePaths},
      headers: header,
    );
    var result = response.body;
    return result['urls'];
  } catch (e) {
    return [];
  }
}
