import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'thumnail.dart';

class ThreeSpeakVideoCard extends StatelessWidget {
  final String title;
  final String username;
  final DateTime createdAt;
  final String votes;
  final String comments;
  final String rewards;
  final String? thumbnailUrl;
  final void Function() onTap;
  final void Function() onTapAuthor;
  final void Function() onTapReport;
  final void Function() onTapUpvote;
  final void Function() onTapComment;
  final bool? isInGrid;
  final bool? isPayoutValueVisible;
  final bool isVisible;
  final int duration;

  const ThreeSpeakVideoCard({
    super.key,
    required this.title,
    required this.username,
    required this.createdAt,
    required this.votes,
    required this.comments,
    required this.rewards,
    this.thumbnailUrl,
    required this.onTap,
    required this.onTapAuthor,
    required this.onTapReport,
    required this.onTapUpvote,
    required this.onTapComment,
    this.isInGrid,
    this.isPayoutValueVisible,
    required this.isVisible,
    required this.duration
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        margin: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Row
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onTapAuthor,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: server.userOwnerThumb(username),
                            width: 32,
                            height: 32,
                            placeholder:
                                (context, url) => const SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onTapAuthor,
                        child: Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        timeago.format(createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                if (isInGrid ?? false)
                  Expanded(
                    flex: 1,
                    child: VideoThumbnail(
                      thumbnailurl: thumbnailUrl ?? '',
                      isVisible: isVisible,
                      duration: duration,
                    ),
                  )
                else
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoThumbnail(
                      thumbnailurl: thumbnailUrl ?? '',
                      isVisible: isVisible,
                      duration: duration
                    ),
                  ),

                // Title + Report
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),

                // Time, Votes, Comments
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isPayoutValueVisible == true)
                        Text(
                          '\$$rewards',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onTapUpvote,
                            child: _iconStat(Icons.favorite_border, votes),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: onTapComment,
                            child: _iconStat(Icons.comment_outlined, comments),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _iconStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black87),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
