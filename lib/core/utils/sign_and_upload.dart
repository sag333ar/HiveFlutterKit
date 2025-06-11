import 'dart:convert';
import 'dart:typed_data';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/upload_image.dart';

Future<UploadResponse> signAndUploadImage({
  required HiveFlutterKitPlatform hfk,
  required String uploadUrlServer,
  required String fileName,
  required Uint8List fileBytes,
}) async {
  var username = await hfk.getCurrentUser();
  username = username.replaceAll("\"", "");
  int timeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  var object = {
    "signed_message": {"type": "posting", "app": "ecency.app"},
    "authors": [username],
    "timestamp": timeStamp,
  };

  final resultOfSignature = await hfk.signMessage(
    jsonEncode(object),
    'posting',
  );

  final decodedResult = jsonDecode(resultOfSignature);

  if (decodedResult['success'] == true) {
    object['signatures'] = [decodedResult['result']];
    var base64StringOfObject = toBase64(jsonEncode(object));

    // Now call the correct uploadImage (returning a map)
    final uploadResult = await hfk.uploadImage(
      imageBytes: fileBytes,
      fileName: fileName,
      token: base64StringOfObject,
      uploadUrlSever: uploadUrlServer,
    );

    return uploadResult;
  } else {
    return UploadResponse(
        success: false,
        url: null,
        message: "Failed to sign image: ${decodedResult['error']}");
  }
}

String toBase64(String input) {
  List<int> bytes = utf8.encode(input);
  String base64Str = base64Encode(bytes);
  return base64Str;
}