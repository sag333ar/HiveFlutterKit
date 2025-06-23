import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/trending_tags/tag_favourite_provider.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/favourite.dart';

class TrendingTagVideos extends StatefulWidget {
  const TrendingTagVideos({Key? key, required this.tag});

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
      ),
    );
  }
}
