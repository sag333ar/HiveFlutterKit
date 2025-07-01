import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_trending_tags.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_community_screen/threespeak_commnuity_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_login_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/video_upload_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/video_player.dart';

class ThreespeakComponents extends StatefulWidget {
  const ThreespeakComponents({super.key});

  @override
  State<ThreespeakComponents> createState() => _ThreespeakComponentsState();
}

class _ThreespeakComponentsState extends State<ThreespeakComponents> {
  late HiveFlutterKitPlatform hfk;

  @override
  void initState() {
    super.initState();
    hfk = HiveFlutterKitPlatform.instance;
  }

  VideoPlayerScreen getVideoPlayer(
    String? author,
    String? permlink,
    GQLFeedItem? item,
  ) {
    return VideoPlayerScreen(
      item: item,
      author: author, //'ninaeatshere',
      permlink: permlink, // 'movrcxlslz',
      onTapBackButton: () {
        Navigator.pop(context);
      },
      shouldShowBackButton: true,
      videoFeed: () {
        return ThreeSpeakVideoFeed(
          feedType: ThreeSpeakVideoFeedType.related,
          onTapVideoItem: (tappedItem) {
            var screen = getVideoPlayer(null, null, tappedItem);
            var route = MaterialPageRoute(builder: (context) => screen);
            Navigator.push(context, route);
          },
          relatedAuthor: 'ninaeatshere',
          relatedPermlink: 'movrcxlslz',
          onTapAuthor: (GQLFeedItem item) {
            debugPrint('Tapped author: ${item.author}');
          },
          onTapReport: (GQLFeedItem item) {
            debugPrint('Tapped report: ${item.permlink}');
          },
          onTapUpvote: (GQLFeedItem item) {
            debugPrint('Tapped upvote: ${item.permlink}');
          },
          onTapComment: (GQLFeedItem item) {
            debugPrint('Tapped comment: ${item.permlink}');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Threespeak Components')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // --- ThreeSpeak Feed List Buttons ---
            const SizedBox(height: 16),
            const Text(
              'ThreeSpeak Video Feeds',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => VideoUploadScreen(
                          owner: 'shaktimaaan',
                          token: "REMOVED",
                          onUploadSuccess: (response) {
                            // Handle the response object here
                            print('Upload success: $response');
                            // You can update state, show a dialog, etc.
                          },
                        ),
                  ),
                );
              },
              child: const Text('Upload Video'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          appBar: AppBar(title: const Text('Trending Feed')),
                          body: ThreeSpeakVideoFeed(
                            feedType: ThreeSpeakVideoFeedType.trending,
                            onTapVideoItem: (tappedItem) {
                              debugPrint('Tapped video item: $tappedItem');
                              var screen = getVideoPlayer(
                                null,
                                null,
                                tappedItem,
                              );
                              var route = MaterialPageRoute(
                                builder: (context) => screen,
                              );
                              Navigator.push(context, route);
                            },
                            onTapAuthor: (GQLFeedItem item) {
                              debugPrint('Tapped author: ${item.author}');
                            },
                            onTapReport: (GQLFeedItem item) {
                              debugPrint('Tapped report: ${item.permlink}');
                            },
                            onTapUpvote: (GQLFeedItem item) {
                              debugPrint('Tapped upvote: ${item.permlink}');
                            },
                            onTapComment: (GQLFeedItem item) {
                              debugPrint('Tapped comment: ${item.permlink}');
                            },
                          ),
                        ),
                  ),
                );
              },
              child: const Text('Show Trending Feed'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ThreeSpeakVideoFeed(
                          feedType: ThreeSpeakVideoFeedType.search,
                          isSearch: true,
                          onTapVideoItem: (tappedItem) {
                            debugPrint('Tapped video item: $tappedItem');
                          },
                          onTapAuthor: (GQLFeedItem item) {
                            debugPrint('Tapped author: ${item.author}');
                          },
                          onTapReport: (GQLFeedItem item) {
                            debugPrint('Tapped report: ${item.permlink}');
                          },
                          onTapUpvote: (GQLFeedItem item) {
                            debugPrint('Tapped upvote: ${item.permlink}');
                          },
                          onTapComment: (GQLFeedItem item) {
                            debugPrint('Tapped comment: ${item.permlink}');
                          },
                        ),
                  ),
                );
              },
              child: const Text('Search screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ThreespeakCommnuityScreen(
                          communityId: 'hive-163772',
                          title: 'Worldmappin',
                          onTapVideoItem: (item) {
                            debugPrint('Tapped video item: ${item.title}');
                          },
                          videoFeed: () {
                            return ThreeSpeakVideoFeed(
                              feedType: ThreeSpeakVideoFeedType.commnuityFeed,
                              commnuityId: 'hive-163772',
                              onTapVideoItem: (tappedItem) {
                                debugPrint('Tapped video item: $tappedItem');
                              },
                              onTapAuthor: (GQLFeedItem item) {
                                debugPrint('Tapped author: ${item.author}');
                              },
                              onTapReport: (GQLFeedItem item) {
                                debugPrint('Tapped report: ${item.permlink}');
                              },
                              onTapUpvote: (GQLFeedItem item) {
                                debugPrint('Tapped upvote: ${item.permlink}');
                              },
                              onTapComment: (GQLFeedItem item) {
                                debugPrint('Tapped comment: ${item.permlink}');
                              },
                            );
                          },
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
                    builder:
                        (context) => ThreeSpeakTrendingTags(
                          onTapTag: (tag) {
                            debugPrint('Tapped tag: $tag');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ThreeSpeakVideoFeed(
                                      feedType:
                                          ThreeSpeakVideoFeedType
                                              .trendingTagFeed,
                                      onTapVideoItem: (tappedItem) {
                                        debugPrint(
                                          'Tapped video item: $tappedItem',
                                        );
                                      },
                                      onTapAuthor: (onTapAuthor) {},
                                      onTapReport: (onTapReport) {},
                                      onTapUpvote: (onTapUpvote) {},
                                      onTapComment: (onTapComment) {},
                                    ),
                              ),
                            );
                          },
                        ),
                  ),
                );
              },
              child: const Text('trending tags'),
            ),
            ElevatedButton(
              onPressed: () {
                var screen = getVideoPlayer("ninaeatshere", "movrcxlslz", null);
                var route = MaterialPageRoute(builder: (context) => screen);
                Navigator.push(context, route);
              },
              child: const Text('video player'),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: EdgeInsets.zero,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: ThreeSpeakLoginScreen(
                                  hfk: hfk,
                                  uponLogin: (context, token, username) {
                                    debugPrint(
                                      'Logged in with token: $token, username: $username',
                                    );
                                    // Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('ThreeSpeak Login Screen User (Dialog)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
