import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_thumbnail.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoCard extends StatelessWidget {
  final GQLFeedItem item;
  final bool isVisible;
  final bool isMobile;
  final void Function() onTap;
  final void Function() onTapAuthor;
  final void Function() onTapReport;
  final void Function() onTapUpvote;
  final void Function() onTapComment;

  const VideoCard({
    super.key,
    required this.item,
    required this.isVisible,
    required this.isMobile,
    required this.onTap,
    required this.onTapAuthor,
    required this.onTapReport,
    required this.onTapUpvote,
    required this.onTapComment,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: isMobile ? _buildMobileLayout() : _buildStackedLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoThumbnail(item: item, isVisible: isVisible),
            ),
            _topGradient(),
            _authorInfo(top: 8, left: 8),
          ],
        ),
        _bottomOverlay(),
      ],
    );
  }

  Widget _buildStackedLayout() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoThumbnail(item: item, isVisible: isVisible),
        ),
        _topGradient(),
        _authorInfo(top: 8, left: 8),
        Positioned(left: 0, right: 0, bottom: 0, child: _bottomOverlay()),
      ],
    );
  }

  Widget _topGradient() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: 60,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _authorInfo({double top = 0, double left = 0}) {
    final username = item.author?.username ?? 'unknown';
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: onTapAuthor,
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: server.userOwnerThumb(username),
                width: 32,
                height: 32,
                placeholder:
                    (context, url) => const SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                errorWidget:
                    (context, url, error) => const Icon(Icons.error, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomOverlay() {
    final title = item.title ?? 'Untitled';
    final createdAt =
        item.createdAt != null ? timeago.format(item.createdAt!) : 'Unknown';
    final votes = item.stats?.numVotes?.toString() ?? '0';
    final comments = item.stats?.numComments?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Report') {
                    onTapReport.call();
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(
                        value: 'Report',
                        child: Text(
                          'Report',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    createdAt,
                    style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onTapUpvote,
                    child: _iconStat(Icons.favorite, votes),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onTapComment,
                    child: _iconStat(Icons.comment, comments),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }
}
