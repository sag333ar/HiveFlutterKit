import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/hive_post_info.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/provider/user_favourite_provider.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_info.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String author;
  final String permlink;
  final DateTime? createdAt;
  final GQLFeedItem item;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
    required this.author,
    required this.permlink,
    required this.createdAt,
    required this.item,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  var setupDone = false;

  List<GQLFeedItem> relatedVideos = [];
  bool isLoadingRelatedVideos = true;

  HivePostInfoPostResultBody? postInfo;

  String _currentUser = "";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  LoginModel? _loggedInUser;

  var userFavouriteProvider = UserFavoriteProvider();

  @override
  void initState() {
    super.initState();
    setupPlayer();
    loadHiveInfo();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final username = await _storage.read(key: 'username');
    final token = await _storage.read(key: 'token');
    if (mounted) {
      setState(() {
        _currentUser = username ?? "";
        if (username != null && token != null) {
          _loggedInUser = LoginModel(username: username);
        }
      });
    }
  }

  bool isUserVoted() {
    if (postInfo == null || _currentUser.isEmpty) return false;
    return postInfo!.activeVotes.any((vote) => vote.voter == _currentUser);
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
      print('Error loading Hive info: $e');
    }
  }

  Future<HivePostInfoPostResultBody> fetchHiveInfoForThisVideo() async {
    var request = http.Request('POST', Uri.parse('https://api.hive.blog/'));
    request.body = json.encode({
      "id": 1,
      "jsonrpc": "2.0",
      "method": "bridge.get_discussion",
      "params": {
        "author": widget.author,
        "permlink": widget.permlink,
        "observer": "",
      },
    });

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var result =
          HivePostInfo.fromJsonString(string).result.resultData
              .where((element) => element.permlink == widget.permlink)
              .first;
      return result;
    } else {
      throw response.reasonPhrase ?? 'Cannot load payout info';
    }
  }

  void setupPlayer() async {
    final resolvedUrl = _resolveIPFSUrl(
      widget.videoUrl,
    ); // e.g. ends with index.m3u8

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
      print("Error initializing video player: $e");
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
        print("Running on Web");
        return 'https://ipfs-3speak.b-cdn.net/ipfs/$hash/manifest.m3u8';
      } else if (Platform.isAndroid) {
        print("Running on Android");
        return 'https://ipfs-3speak.b-cdn.net/ipfs/$hash/480p/index.m3u8';
      } else {
        print("Running on another platform");
        return 'https://ipfs-3speak.b-cdn.net/ipfs/$hash/manifest.m3u8';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 800;

            if (isWideScreen) {
              // Web/Desktop layout: video player + info on top, related videos grid below
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Centered video player with more width and side padding
                    Center(
                      child: Container(
                        width: 1600, // Increased width (e.g. 1120px)
                        constraints: BoxConstraints(
                          maxWidth: 1800,
                          minWidth: 400,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 32,
                        ), // Space from both sides
                        height: 540,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child:
                              setupDone && chewieController != null
                                  ? Chewie(controller: chewieController!)
                                  : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                        ),
                      ),
                    ),
                    //Video info (centered to match player)
                    Center(
                      child: Container(
                        width: 1600,
                        constraints: BoxConstraints(
                          maxWidth: 1800,
                          minWidth: 400,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        child: VideoInfo(
                          title: widget.title,
                          author: widget.author,
                          createdAt: widget.createdAt,
                          video: widget.item,
                          postInfo: postInfo,
                          currentUser: _currentUser,
                          loggedInUser: _loggedInUser,
                          userFavouriteProvider: userFavouriteProvider,
                          onUserChanged: (user) {
                            setState(() {
                              _loggedInUser = user;
                            });
                          },
                          onLogout: () {
                            setState(() {
                              _loggedInUser = null;
                            });
                          },
                          reloadHiveInfo: () async {
                            loadHiveInfo();
                          },
                          isUserVoted: isUserVoted,
                        ),
                      ),
                    ),
                    Divider(height: 1),
                  ],
                ),
              );
            } else {
              // Mobile layout (stacked)
              return Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child:
                        setupDone && chewieController != null
                            ? Chewie(controller: chewieController!)
                            : const Center(child: CircularProgressIndicator()),
                  ),
                  VideoInfo(
                    title: widget.title,
                    author: widget.author,
                    createdAt: widget.createdAt,
                    video: widget.item,
                    postInfo: postInfo,
                    currentUser: _currentUser,
                    loggedInUser: _loggedInUser,
                    userFavouriteProvider: userFavouriteProvider,
                    onUserChanged: (user) {
                      setState(() {
                        _loggedInUser = user;
                      });
                    },
                    onLogout: () {
                      setState(() {
                        _loggedInUser = null;
                      });
                    },
                    reloadHiveInfo: () async {
                      loadHiveInfo();
                    },
                    isUserVoted: isUserVoted,
                  ),
                  Divider(height: 1),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
