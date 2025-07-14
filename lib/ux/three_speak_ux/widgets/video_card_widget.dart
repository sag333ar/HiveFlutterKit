import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/studio_video_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_thumbnail.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoCard extends StatelessWidget {
  final VideoFeedGridItemViewModel item;
  final bool isVisible;
  final void Function() onTap;
  final void Function() onTapAuthor;
  final void Function() onTapReport;
  final void Function() onTapUpvote;
  final void Function() onTapComment;
  final bool? isInGrid;
  final bool? isPayoutValueVisible;
  final bool? isReportVisible; 

  const VideoCard({
    super.key,
    required this.item,
    required this.isVisible,
    required this.onTap,
    required this.onTapAuthor,
    required this.onTapReport,
    required this.onTapUpvote,
    required this.onTapComment,
    this.isInGrid,
    this.isPayoutValueVisible,
    this.isReportVisible,
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
                            imageUrl: server.userOwnerThumb(item.author),
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
                          item.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        timeago.format(item.created),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                if (isInGrid ?? false)
                  Expanded(
                    flex: 1,
                    child: VideoThumbnail(item: item, isVisible: isVisible),
                  )
                else
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoThumbnail(item: item, isVisible: isVisible),
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
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isReportVisible == true) 
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
                          item.hiveValue != null ? '\$${item.hiveValue}' : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      Row(
                        children: [
                          item.numOfUpvotes != null
                              ? GestureDetector(
                                onTap: onTapUpvote,
                                child: _iconStat(
                                  Icons.favorite_border,
                                  "${item.numOfUpvotes ?? 0}",
                                ),
                              )
                              : Container(),
                          const SizedBox(width: 12),
                          item.numOfComments != null
                              ? GestureDetector(
                                onTap: onTapUpvote,
                                child: _iconStat(
                                  Icons.favorite_border,
                                  "${item.numOfComments ?? 0}",
                                ),
                              )
                              : Container(),
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
