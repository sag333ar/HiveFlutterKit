import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoThumbnail extends StatelessWidget {
  final bool isVisible;
  final String thumbnailurl;
  final int duration;

  const VideoThumbnail({
    Key? key,
    required this.isVisible,
    required this.thumbnailurl,
    required this.duration
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: thumbnailurl,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
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

  String _formatDuration(int duration) {
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toInt().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
