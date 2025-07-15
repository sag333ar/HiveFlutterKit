import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/studio_video_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_thumbnail.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoCard extends StatefulWidget {
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
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  int? _comments;
  int? _upvotes;
  String? _payoutValue;
  bool _loadingStats = false;
  late HiveFlutterKitPlatform hfk;

  @override
  void initState() {
    super.initState();
    hfk = HiveFlutterKitPlatform.instance;
    if (widget.item.numOfComments == null || widget.item.numOfUpvotes == null) {
      _fetchStats();
    }
  }

  Future<void> _fetchStats() async {
    setState(() {
      _loadingStats = true;
    });
    try {
      final discussion = await hfk.getContent(
        author: widget.item.author,
        permlink: widget.item.permlink,
      );
      if (discussion != null) {
        setState(() {
          _comments = discussion.children ?? 0;
          _upvotes = (discussion.activeVotes?.length ?? 0);
          _payoutValue = discussion.payOutValue;
        });
      }
    } catch (e) {
    } finally {
      setState(() {
        _loadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: widget.onTap,
      child: Skeletonizer(
        enabled: _loadingStats,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          margin: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isInGrid ?? false)
                    Expanded(
                      flex: 1,
                      child: VideoThumbnail(
                        item: item,
                        isVisible: widget.isVisible,
                      ),
                    )
                  else
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: VideoThumbnail(
                        item: item,
                        isVisible: widget.isVisible,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4,
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
                        if (widget.isReportVisible == true)
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onTapAuthor,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: server.userOwnerThumb(item.author),
                              width: 32,
                              height: 32,
                              // placeholder:
                              //     (context, url) => const SizedBox(
                              //       width: 25,
                              //       height: 25,
                              //       child: CircularProgressIndicator(
                              //         strokeWidth: 2,
                              //       ),
                              //     ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.onTapAuthor,
                          child: Text(
                            item.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeago.format(item.created),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.isPayoutValueVisible == true)
                          Text(
                            item.hiveValue != null
                                ? '\$${item.hiveValue}'
                                : (_payoutValue != null
                                    ? '\$$_payoutValue'
                                    : ''),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: widget.onTapUpvote,
                              child: _iconStat(
                                Icons.thumb_up_alt_outlined,
                                "${item.numOfUpvotes ?? _upvotes ?? 0}",
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: widget.onTapComment,
                              child: _iconStat(
                                Icons.comment_outlined,
                                "${item.numOfComments ?? _comments ?? 0}",
                              ),
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
      ),
    );
  }

  Widget _iconStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blue),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
