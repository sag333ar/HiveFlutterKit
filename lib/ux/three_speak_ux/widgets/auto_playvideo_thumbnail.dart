import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/provider/ipfs_node_provider.dart';
import 'package:video_player/video_player.dart';

class AutoPlayVideoThumbnail extends StatefulWidget {
  final GQLFeedItem item;
  final bool isVisible;

  const AutoPlayVideoThumbnail({
    Key? key,
    required this.item,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<AutoPlayVideoThumbnail> createState() => _AutoPlayVideoThumbnailState();
}

class _AutoPlayVideoThumbnailState extends State<AutoPlayVideoThumbnail> {
  VideoPlayerController? _controller;
  Timer? _autoPlayTimer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _initializeVideo() {
    final videoUrl = _getVideoUrl(widget.item);
    if (videoUrl != null) {
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void didUpdateWidget(AutoPlayVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      _handleVisibilityChange();
    }
  }

  void _handleVisibilityChange() {
    _autoPlayTimer?.cancel();

    if (widget.isVisible && !_isPlaying) {
      _autoPlayTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && widget.isVisible) {
          setState(() {
            _isPlaying = true;
            _controller?.play();
          });
        }
      });
    } else {
      setState(() {
        _isPlaying = false;
        _controller?.pause();
        _controller?.seekTo(Duration.zero);
      });
    }
  }

  String? _getVideoUrl(GQLFeedItem item) {
    return item.playUrl;
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = getThumbnailUrl(widget.item);
    print(thumbnailUrl);
    final duration = getVideoDuration(widget.item);
    print(duration);

    return Stack(
      children: [
        if (_isPlaying && _controller?.value.isInitialized == true)
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          )
        else
          CachedNetworkImage(
            imageUrl: thumbnailUrl ?? '',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
          ),
        if (!_isPlaying && duration != null)
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
        if (_isPlaying && _controller?.value.isInitialized == true)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.black45,
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
