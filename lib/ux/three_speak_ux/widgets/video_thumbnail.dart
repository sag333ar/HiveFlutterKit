import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/studio_video_model.dart';

class VideoThumbnail extends StatelessWidget {
  final VideoFeedGridItemViewModel item;
  final bool isVisible;

  const VideoThumbnail({Key? key, required this.item, required this.isVisible})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = item.thumbnail ?? '';
    final duration = item.duration?.toDouble();

    // If thumbnailUrl is null or empty, show asset image instead
    // if (thumbnailUrl.isEmpty) {
    //   return Stack(
    //     children: [
    //       Image.network(
    //         'https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI',
    //         height: 300,
    //         width: double.infinity,
    //         fit: BoxFit.cover,
    //       ),
    //       if (duration != null)
    //         Positioned(
    //           bottom: 8,
    //           right: 8,
    //           child: Container(
    //             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    //             decoration: BoxDecoration(
    //               color: Colors.black.withOpacity(0.8),
    //               borderRadius: BorderRadius.circular(4),
    //             ),
    //             child: Text(
    //               _formatDuration(duration),
    //               style: const TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w500,
    //               ),
    //             ),
    //           ),
    //         ),
    //     ],
    //   );
    // }

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: thumbnailUrl,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Image.asset(
                'packages/hive_flutter_kit/assets/images/logo.png',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
        ),
        if (duration != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(double duration) {
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toInt().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
