import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/core/three_speak_core/graphql/gql_communicator.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_info.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:collection/collection.dart';

class VideoPlayerScreen extends StatefulWidget {
  final GQLFeedItem? item;
  final String? author;
  final String? permlink;

  final void Function(String, String)? onTapComment;
  final void Function(String, String)? onTapUpvote;
  final void Function(String, String)? onTapShare;
  final void Function(String, String)? onTapBookmark;
  final void Function(String, String)? onTapAuthor;
  final VoidCallback onTapBackButton;
  final bool shouldShowBackButton;
  final void Function(String, String)? onTapInfo;
  final ThreeSpeakVideoFeed Function() videoFeed;
  // final Widget Function(BuildContext context, GQLFeedItem item)? relatedBuilder;

  const VideoPlayerScreen({
    super.key,
    required this.item,
    this.onTapComment,
    this.onTapUpvote,
    this.onTapShare,
    this.onTapBookmark,
    required this.onTapBackButton,
    this.onTapAuthor,
    this.onTapInfo,
    this.author,
    this.permlink,
    required this.shouldShowBackButton,
    required this.videoFeed,
  }) : assert(
         (item != null && author == null && permlink == null) ||
             (item == null && author != null && permlink != null),
         'You must either provide a post OR both author and permlink',
       );

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  var setupDone = false;
  GQLFeedItem? item;

  List<GQLFeedItem> relatedVideos = [];
  bool isLoadingRelatedVideos = true;
  Discussion? postInfo;
  String currentUserName = "";
  final HiveFlutterKitPlatform hfk = HiveFlutterKitPlatform.instance;
  final GQLCommunicator _gql = GQLCommunicator();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      item = widget.item!;
      setupPlayer();
      loadHiveInfo();
      setupUsername();
    } else {
      getVideoItem();
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newAuthor = widget.author;
    final newPermlink = widget.permlink;

    if (newAuthor != oldWidget.author || newPermlink != oldWidget.permlink) {
      _disposeAndReload();
    }
  }

  void _disposeAndReload() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    chewieController = null;
    setupDone = false;
    item = null;

    if (widget.item != null) {
      item = widget.item!;
      setupPlayer();
      loadHiveInfo();
      setupUsername();
    } else {
      getVideoItem();
    }

    setState(() {});
  }

  void getVideoItem() async {
    try {
      var videoItem = await _gql.getVideoItem(
        widget.author ?? '',
        widget.permlink ?? '',
      );
      setState(() {
        item = videoItem;
        setupPlayer();
        loadHiveInfo();
        setupUsername();
      });
    } catch (e) {
      debugPrint("Error getting video item: $e");
    }
  }

  void setupUsername() async {
    try {
      var user = await hfk.getCurrentUser();
      user = user.replaceAll('"', '');
      setState(() {
        currentUserName = user;
      });
    } catch (e) {
      debugPrint("Error fetching current user: $e");
    }
  }

  bool isContentVoted() {
    if (postInfo == null || currentUserName.isEmpty) {
      return false;
    }

    var userrname = currentUserName;
    var votes = postInfo?.activeVotes ?? [];
    return votes.where((e) => e.voter == userrname).isNotEmpty;
  }

  void loadHiveInfo() async {
    if (mounted) {
      setState(() {
        postInfo = null;
      });
    }
    try {
      var data = await fetchHiveInfoForThisVideo();
      if (mounted) {
        setState(() {
          postInfo = data;
        });
      }
    } catch (e) {
      debugPrint('Error loading Hive info: $e');
    }
  }

  Future<Discussion> fetchHiveInfoForThisVideo() async {
    if ((item!.author?.username ?? "").isEmpty ||
        (item!.permlink ?? "").isEmpty) {
      var errorMessage = "Author or permlink is empty, cannot fetch Hive info.";
      debugPrint(errorMessage);
      throw errorMessage;
    }
    var result = await hfk.getCommentsList(
      item!.author?.username ?? "",
      item!.permlink ?? "",
    );
    var discussion = result.firstWhereOrNull(
      (e) => e.author == item!.author?.username && e.permlink == item!.permlink,
    );
    if (discussion == null) {
      var errorMessage = "No discussion found for this video.";
      debugPrint(errorMessage);
      throw errorMessage;
    } else {
      return discussion;
    }
  }

  void setupPlayer() async {
    if (item!.playUrl == null || item!.playUrl!.isEmpty) {
      debugPrint("No play URL found for this video.");
      return;
    }
    final resolvedUrl = _resolveIPFSUrl(item!.playUrl ?? "");

    videoPlayerController = VideoPlayerController.network(resolvedUrl);

    try {
      await videoPlayerController.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        showControls: true,
      );

      if (mounted) {
        setState(() {
          setupDone = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video player: $e");
    }
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  String _resolveIPFSUrl(String url) {
    if (url.startsWith('ipfs://')) {
      final hash = url.replaceFirst('ipfs://', '').split('/')[0];
      if (kIsWeb) {
        debugPrint("Running on Web");
        return 'https://ipfs-3speak.b-cdn.net/ipfs/$hash/manifest.m3u8';
      } else if (Platform.isAndroid) {
        debugPrint("Running on Android");
         var url = 'https://ipfs-3speak.b-cdn.net/ipfs/$hash/480p/index.m3u8';
        //var url = 'https://ipfs-3speak.b-cdn.net/ipfs/$hash/manifest.m3u8';
        debugPrint("Running on Android - $url");
        return url;
      } else {
        debugPrint("Running on another platform");
        return 'https://ipfs-3speak.b-cdn.net/ipfs/$hash/manifest.m3u8';
      }
    }
    return url;
  }

  Widget _videoInfoWidget() {
    return VideoInfo(
      title: item!.title ?? "",
      author: item!.author?.username ?? "",
      permlink: item!.permlink ?? "",
      createdAt: item!.createdAt ?? DateTime.now(),
      video: item!,
      postInfo: postInfo,
      currentUser: currentUserName,
      isContentVoted: isContentVoted(),
      onTapComment: widget.onTapComment,
      onTapUpvote: widget.onTapUpvote,
      onTapShare: widget.onTapShare,
      onTapBookmark: widget.onTapBookmark,
      onTapAuthor: widget.onTapAuthor,
      onTapInfo: widget.onTapInfo,
    );
  }

  Widget loader() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading:
            widget.shouldShowBackButton
                ? BackButton(onPressed: widget.onTapBackButton)
                : null,
        title: Text(item?.title ?? "Loading Data"),
      ),
      body: SafeArea(
        child:
            item == null
                ? loader()
                : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideScreen = constraints.maxWidth >= 800;

                    if (isWideScreen) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                width: 1600,
                                constraints: BoxConstraints(
                                  maxWidth: 1800,
                                  minWidth: 400,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                height: 540,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child:
                                      setupDone && chewieController != null
                                          ? Chewie(
                                            controller: chewieController!,
                                          )
                                          : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 1600,
                                constraints: BoxConstraints(
                                  maxWidth: 1800,
                                  minWidth: 400,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: _videoInfoWidget(),
                              ),
                            ),
                            Divider(height: 1),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: 1800,
                                minWidth: 400,
                                maxHeight: 700,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: widget.videoFeed(),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child:
                                setupDone && chewieController != null
                                    ? Chewie(controller: chewieController!)
                                    : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                          ),
                          _videoInfoWidget(),
                          Divider(height: 1),
                          Expanded(child: widget.videoFeed()),
                        ],
                      );
                    }
                  },
                ),
      ),
    );
  }
}
