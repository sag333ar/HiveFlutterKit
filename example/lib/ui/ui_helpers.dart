import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/studio_video_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/video_player.dart'; // Assuming GQLFeedItem is here or in a related import

Widget buildVideoPlayerScreen(
  BuildContext context, // Added context for navigation
  String? author,
  String? permlink,
  ThreeSpeakVideo? item,
) {
  return VideoPlayerScreen(
    item: item,
    author: author,
    permlink: permlink,
    onTapBackButton: () {
      Navigator.pop(context);
    },
    shouldShowBackButton: true,
    videoFeed: () {
      // This nested function might need further refactoring if it becomes too complex
      // or if it needs access to more state from the calling widget.
      // For now, keeping its direct dependencies.
      return ThreeSpeakVideoFeed(
        feedType: ThreeSpeakVideoFeedType.related,
        onTapVideoItem: (tappedItem) {
          // Recursive call, ensure context is available and correctly used for navigation
          // var screen = buildVideoPlayerScreen(context, null, null, tappedItem);
          // var route = MaterialPageRoute(builder: (context) => screen);
          // Navigator.push(context, route);
        },
        // These might need to be passed as parameters if they vary
        relatedAuthor: item?.owner ?? author ?? 'unknown',
        relatedPermlink: item?.permlink ?? permlink ?? 'unknown',
        onTapAuthor: (GQLFeedItem feedItem) {
          debugPrint('Tapped author: ${feedItem.author}');
          // TODO: Implement or provide callback for author tap
        },
        onTapReport: (GQLFeedItem feedItem) {
          debugPrint('Tapped report: ${feedItem.permlink}');
          // TODO: Implement or provide callback for report tap
        },
        onTapUpvote: (GQLFeedItem feedItem) {
          debugPrint('Tapped upvote: ${feedItem.permlink}');
          // TODO: Implement or provide callback for upvote tap
        },
        onTapComment: (GQLFeedItem feedItem) {
          debugPrint('Tapped comment: ${feedItem.permlink}');
          // TODO: Implement or provide callback for comment tap
        },
      );
    },
  );
}
