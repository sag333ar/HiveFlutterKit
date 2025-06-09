import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

enum PickerType { gallery, camera }

enum CameraFacing { front, rear }

class CustomImagePicker {
  static Future<void> show({
    required BuildContext context,
    required PickerType type,
    CameraFacing cameraFacing = CameraFacing.front,
    int imageQuality = 60,
    double maxHeight = 600,
    double maxWidth = 600,
    required void Function(XFile? file, Uint8List? bytes) onPick,
  }) async {
    final ImagePicker picker = ImagePicker();
    XFile? image;

    try {
      if (type == PickerType.gallery) {
        image = await picker.pickImage(source: ImageSource.gallery);
      } else {
        final preferredCamera =
            (cameraFacing == CameraFacing.front)
                ? CameraDevice.front
                : CameraDevice.rear;
        image = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: preferredCamera,
          imageQuality: imageQuality,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        );
      }

      if (image != null) {
        Uint8List fileBytes = await image.readAsBytes();
        onPick(image, fileBytes);
      } else {
        onPick(null, null);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      onPick(null, null);
    }
  }
}
