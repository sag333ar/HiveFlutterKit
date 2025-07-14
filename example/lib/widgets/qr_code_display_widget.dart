import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class QrCodeDisplayWidget extends StatelessWidget {
  final String qrString;
  final int timerDuration; // Max duration for the timer (e.g., 30 seconds)
  final VoidCallback onCancel;
  final VoidCallback? onTapQrCode; // Optional: if specific action needed on tap

  const QrCodeDisplayWidget({
    super.key,
    required this.qrString,
    required this.timerDuration,
    required this.onCancel,
    this.onTapQrCode,
  });

  @override
  Widget build(BuildContext context) {
    if (qrString.isEmpty || timerDuration <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        InkWell(
          child: QrImageView(
            data: qrString,
            version: QrVersions.auto,
            size: 200.0,
          ),
          onTap: onTapQrCode ?? () {
            var uri = Uri.tryParse(qrString);
            if (uri != null) {
              launchUrl(uri);
            }
          },
        ),
        Padding( // Add some padding for visual separation
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: LinearProgressIndicator(
            value: timerDuration / 30.0, // Assuming 30 is the max duration for the progress
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.blue,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
