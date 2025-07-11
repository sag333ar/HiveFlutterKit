import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_trending_tags.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_community_screen/threespeak_commnuity_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_login_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/threespeak_user_account.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/thumbnail_upload_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/upload_info_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/video_upload_screen.dart';

// Callback type for showing video options
typedef ShowVideoOptionsCallback = void Function(BuildContext context, String videoId);

class ThreeSpeakComponentsWidget extends StatelessWidget {
  final HiveFlutterKitPlatform hfk; // For ThreespeakLoginScreen
  final Function(String) showSnackBar; // For displaying messages
  final Widget Function(BuildContext context, String? author, String? permlink, GQLFeedItem? item) videoPlayerBuilder;
  final ShowVideoOptionsCallback showVideoOptionsSheet;
  final VoidCallback onUserLogout; // Callback for when user logs out from ThreeSpeakCurrentUserAccount


  const ThreeSpeakComponentsWidget({
    super.key,
    required this.hfk,
    required this.showSnackBar,
    required this.videoPlayerBuilder,
    required this.showVideoOptionsSheet,
    required this.onUserLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        const Text("ThreeSpeak Actions / Components", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        // Video Upload Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoUploadScreen(
                  owner: 'shaktimaaan', // TODO: Parameterize or get from logged-in state
                  token: "No token", // TODO: Get actual token
                  onVideoUpload: (model) {
                    showSnackBar('Video uploaded: ${model.filename}');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThumbnailUploadScreen(
                          uploadModel: model,
                          onThumbnailUpload: (updatedModel) {
                            showSnackBar('Thumbnail uploaded: ${updatedModel.thumbnailFilename}');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadInfoScreen(
                                  uploadModel: updatedModel,
                                  onUploadComplete: (response) {
                                    showSnackBar('Upload complete: $response');
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: const Text('Upload Video (3Speak)'),
        ),

        // User Account Screen Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThreeSpeakCurrentUserAccount(
                  username: 'shaktimaaan', // TODO: Parameterize or get from logged-in state
                  token: "No token", // TODO: Get actual token
                  shouldShowBackButton: true,
                  onTapBackButton: () => Navigator.of(context).pop(),
                  onTabChanged: (tabIndex) => showSnackBar('Tab changed to: $tabIndex'),
                  onLogout: () {
                    showSnackBar('User logged out from 3Speak Account');
                    onUserLogout(); // Call the passed logout callback
                    // Navigator.of(context).pop(); // Pop current screen if needed
                  },
                  onPublish: (username, permlink) => showSnackBar('Publishing video: $username/$permlink'),
                  onViewMyVideo: (username, permlink) {
                     showSnackBar('Viewing video: $username/$permlink');
                     // Potentially navigate to video player
                  },
                  onViewDetails: (username, permlink) => showSnackBar('Viewing details: $username/$permlink'),
                  onMoreOptions: (videoId) => showVideoOptionsSheet(context, videoId),
                ),
              ),
            );
          },
          child: const Text('My Account (3Speak)'),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Trending Feed (3Speak)')),
                  body: ThreeSpeakVideoFeed(
                    feedType: ThreeSpeakVideoFeedType.trending,
                    onTapVideoItem: (tappedItem) {
                      var screen = videoPlayerBuilder(context, null, null, tappedItem);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
                    },
                    onTapAuthor: (item) => showSnackBar('Tapped author: ${item.author}'),
                    onTapReport: (item) => showSnackBar('Tapped report: ${item.permlink}'),
                    onTapUpvote: (item) => showSnackBar('Tapped upvote: ${item.permlink}'),
                    onTapComment: (item) => showSnackBar('Tapped comment: ${item.permlink}'),
                    isPayoutValueVisible: true,
                  ),
                ),
              ),
            );
          },
          child: const Text('Show Trending Feed (3Speak)'),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThreeSpeakVideoFeed( 
                  feedType: ThreeSpeakVideoFeedType.search,
                  isSearch: true,
                  onTapVideoItem: (tappedItem) {
                    var screen = videoPlayerBuilder(context, null, null, tappedItem);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
                  },
                  onTapAuthor: (item) => showSnackBar('Tapped author: ${item.author}'),
                  onTapReport: (item) => showSnackBar('Tapped report: ${item.permlink}'),
                  onTapUpvote: (item) => showSnackBar('Tapped upvote: ${item.permlink}'),
                  onTapComment: (item) => showSnackBar('Tapped comment: ${item.permlink}'),
                ),
              ),
            );
          },
          child: const Text('Search Screen (3Speak)'),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThreespeakCommnuityScreen(
                  communityId: 'hive-163772', // TODO: Parameterize
                  title: 'Worldmappin', // TODO: Parameterize
                  videoFeed: () {
                    return ThreeSpeakVideoFeed(
                      feedType: ThreeSpeakVideoFeedType.commnuityFeed,
                      commnuityId: 'hive-163772', // TODO: Parameterize
                      onTapVideoItem: (tappedItem) {
                         var screen = videoPlayerBuilder(context, null, null, tappedItem);
                         Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
                      },
                      onTapAuthor: (item) => showSnackBar('Tapped author: ${item.author}'),
                      onTapReport: (item) => showSnackBar('Tapped report: ${item.permlink}'),
                      onTapUpvote: (item) => showSnackBar('Tapped upvote: ${item.permlink}'),
                      onTapComment: (item) => showSnackBar('Tapped comment: ${item.permlink}'),
                    );
                  },
                  onTapBackButton: () => Navigator.of(context).pop(),
                  shouldShowBackButton: true, // Usually true if pushed
                ),
              ),
            );
          },
          child: const Text('Show 3Speak Community Screen'),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThreeSpeakTrendingTags(
                  onTapTag: (tag) {
                    showSnackBar('Tapped tag: $tag');
                    // Potentially navigate to a feed filtered by this tag
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThreeSpeakVideoFeed(
                                feedType: ThreeSpeakVideoFeedType.trendingTagFeed,
                                tag: tag,
                                onTapVideoItem: (tappedItem) {
                                   var screen = videoPlayerBuilder(context, null, null, tappedItem);
                                   Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
                                },
                                onTapAuthor: (item) => showSnackBar('Tapped author: ${item.author}'),
                                onTapReport: (item) => showSnackBar('Tapped report: ${item.permlink}'),
                                onTapUpvote: (item) => showSnackBar('Tapped upvote: ${item.permlink}'),
                                onTapComment: (item) => showSnackBar('Tapped comment: ${item.permlink}'),
                              ),
                        ),
                      );
                  },
                ),
              ),
            );
          },
          child: const Text('Trending Tags (3Speak)'),
        ),
         ElevatedButton(
            onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => Dialog(
                    insetPadding: EdgeInsets.zero,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: ThreeSpeakLoginScreen(
                        hfk: hfk, // Pass hfk instance
                        uponLogin: (ctx, token, username) {
                            showSnackBar('3Speak Logged in with token: $token, username: $username');
                            Navigator.of(ctx).pop(); // Close dialog upon login
                        },
                        ),
                    ),
                    ),
                );
            },
            child: const Text('ThreeSpeak Login Screen (Dialog)'),
        ),
      ],
    );
  }
}
