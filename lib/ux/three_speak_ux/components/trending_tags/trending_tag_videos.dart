import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/trending_tags/tag_favourite_provider.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/favourite.dart';

class TrendingTagVideos extends StatefulWidget {
  const TrendingTagVideos({
    Key? key,
    required this.tag,
    required this.onTapVideoItem,
    required this.onTapAuthor,
    required this.onTapReport,
    required this.onTapUpvote,
    required this.onTapComment,
  });

  final void Function(GQLFeedItem item) onTapVideoItem;
  final void Function(GQLFeedItem item) onTapAuthor;
  final void Function(GQLFeedItem item) onTapReport;
  final void Function(GQLFeedItem item) onTapUpvote;
  final void Function(GQLFeedItem item) onTapComment;
  final String tag;

  @override
  State<TrendingTagVideos> createState() => _TrendingTagVideosState();
}

class _TrendingTagVideosState extends State<TrendingTagVideos>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var provider = TagFavoriteProvider();
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: const Icon(Icons.tag),
          title: Text(widget.tag),
        ),
        actions: [
          FavouriteWidget(
            toastType: "Tag",
            isLiked: provider.isTagPresentLocally(widget.tag),
            onAdd: () {
              provider.storeLikedTagLocally(widget.tag);
            },
            onRemove: () {
              provider.storeLikedTagLocally(widget.tag);
            },
          ),
        ],
      ),
      body: ThreeSpeakVideoFeed(
        feedType: ThreeSpeakVideoFeedType.trendingTagFeed,
        tag: widget.tag,
        onTapVideoItem: widget.onTapVideoItem,
        onTapAuthor: widget.onTapAuthor,
        onTapReport: widget.onTapReport,
        onTapUpvote: widget.onTapUpvote,
        onTapComment: widget.onTapComment,
      ),
    );
  }
}
