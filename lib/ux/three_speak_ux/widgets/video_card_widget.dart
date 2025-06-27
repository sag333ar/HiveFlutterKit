import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/user_channel_screen/user_channel_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_thumbnail.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoCard extends StatefulWidget {
  final GQLFeedItem item;
  final bool isVisible;
  final void Function() onTap;
  final void Function() onTapAuthor;
  final void Function() onTapReport;
  final void Function() onTapUpvote;
  final void Function() onTapComment;

  const VideoCard({
    super.key,
    required this.item,
    required this.isVisible,
    required this.onTap,
    required this.onTapAuthor,
    required this.onTapReport,
    required this.onTapUpvote,
    required this.onTapComment,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    bool isMobile = MediaQuery.of(context).size.width < 600;

    void handleTapAuthor() {
      widget.onTapAuthor();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoThumbnail(item: item, isVisible: widget.isVisible),
            ),
            isMobile
                ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: handleTapAuthor,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                height: 40,
                                width: 40,
                                placeholder:
                                    (context, url) => const SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(),
                                    ),
                                imageUrl: server.userOwnerThumb(
                                  item.author?.username ?? '',
                                ),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ),
                            ), // <-- always use this
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title ?? 'Untitled',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Report') {
                                widget.onTapReport.call();
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
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '@${item.author?.username ?? 'unknown'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.createdAt != null
                                    ? timeago.format(item.createdAt!)
                                    : 'Unknown',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: widget.onTapUpvote,
                                child: _buildStatItem(
                                  Icons.thumb_up,
                                  item.stats?.numVotes?.toString() ?? '0',
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: widget.onTapComment,
                                child: _buildStatItem(
                                  Icons.comment,
                                  item.stats?.numComments?.toString() ?? '0',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: handleTapAuthor,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                height: 40,
                                width: 40,
                                placeholder:
                                    (context, url) => const SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(),
                                    ),
                                imageUrl: server.userOwnerThumb(
                                  item.author?.username ?? '',
                                ),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ),
                            ), // <-- always use this
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title ?? 'Untitled',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Report') {
                                widget.onTapReport.call();
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
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '@${item.author?.username ?? 'unknown'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.createdAt != null
                                    ? timeago.format(item.createdAt!)
                                    : 'Unknown',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildStatItem(
                                Icons.thumb_up,
                                item.stats?.numVotes?.toString() ?? '0',
                              ),
                              const SizedBox(width: 16),
                              _buildStatItem(
                                Icons.comment,
                                item.stats?.numComments?.toString() ?? '0',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
