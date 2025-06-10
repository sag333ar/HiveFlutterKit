import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/provider/ipfs_node_provider.dart';

class VideoThumbnail extends StatelessWidget {
  final GQLFeedItem item;
  final bool isVisible;

  const VideoThumbnail({
    Key? key,
    required this.item,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = getThumbnailUrl(item);
    final duration = getVideoDuration(item);

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: thumbnailUrl ?? '',
          height: 200,
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

  String _formatDuration(double duration) {
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toInt().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double? getVideoDuration(GQLFeedItem item) {
    try {
      final metadata = item.jsonMetadata?['raw'];
      return metadata?['video']?['info']?['duration']?.toDouble();
    } catch (e) {
      print('Duration parse error: $e');
      return null;
    }
  }

  String? getThumbnailUrl(GQLFeedItem item) {
    try {
      final metadata = item.jsonMetadata?['raw'];
      final sourceMap = metadata?['video']?['sourceMap'];
      if (sourceMap is List) {
        final thumbnail = sourceMap.firstWhere(
          (src) => src['type'] == 'thumbnail',
          orElse: () => null,
        );
        if (thumbnail != null && thumbnail['url'] != null) {
          String rawUrl = thumbnail['url'];

          // Replace ipfs:// with fixed CDN prefix
          if (rawUrl.startsWith('ipfs://')) {
            rawUrl = rawUrl.replaceFirst('ipfs://', IpfsNodeProvider().nodeUrl);
          }

          // Proxy the final URL for optimization
          if (rawUrl.startsWith('http')) {
            return 'https://images.hive.blog/320x160/$rawUrl';
          }

          return rawUrl;
        }
      }

      // Fallback to existing thumbnail URL, also proxied
      final fallbackUrl = item.spkvideo?.thumbnailUrl;
      if (fallbackUrl != null && fallbackUrl.startsWith('http')) {
        return 'https://images.hive.blog/320x160/$fallbackUrl';
      }

      return fallbackUrl;
    } catch (e) {
      print('Error parsing thumbnail URL: $e');
      return null;
    }
  }
}
