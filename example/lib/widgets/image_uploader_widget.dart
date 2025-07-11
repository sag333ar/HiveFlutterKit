import 'package:flutter/material.dart';

class ImageUploaderWidget extends StatelessWidget {
  final String? uploadedImageUrl;
  final bool isUploading;
  final VoidCallback onPickAndUploadImage;
  final VoidCallback onSignAndBroadcastTx;
  final bool isBroadcasting;
  final String? broadcastResult;

  const ImageUploaderWidget({
    super.key,
    this.uploadedImageUrl,
    required this.isUploading,
    required this.onPickAndUploadImage,
    required this.onSignAndBroadcastTx,
    required this.isBroadcasting,
    this.broadcastResult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Upload Profile Image and Broadcast Operation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (uploadedImageUrl != null)
          Image.network(uploadedImageUrl!, width: 120, height: 120),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isUploading ? null : onPickAndUploadImage,
              child: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Pick & Upload Image'),
            ),
          ],
        ),
        if (uploadedImageUrl != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Uploaded URL: $uploadedImageUrl',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ElevatedButton(
          onPressed: (uploadedImageUrl != null && !isBroadcasting)
              ? onSignAndBroadcastTx
              : null,
          child: isBroadcasting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign & Broadcast Tx'),
        ),
        if (broadcastResult != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Broadcast Result: $broadcastResult',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        const Divider(),
      ],
    );
  }
}
