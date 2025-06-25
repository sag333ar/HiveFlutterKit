import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/components/user_profile_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';

enum VideoListType { publishNow, myVideos, encoding }

class ThreeSpeakCurrentUserAccount extends StatefulWidget {
  final String token;
  final String username;
  final void Function(int)? onTabChanged;
  final VoidCallback? onLogout;
  final void Function(String username, String permlink)? onPublish;
  final void Function(String username, String permlink)? onViewMyVideo;
  final void Function(String username, String permlink)? onViewDetails;
  final void Function(String videoId)? onMoreOptions;
  final VoidCallback? onTapBackButton;  
  const ThreeSpeakCurrentUserAccount({
    super.key,
    required this.token,
    required this.username,
    this.onTabChanged,
    this.onLogout,
    this.onPublish,
    this.onViewMyVideo,
    this.onViewDetails,
    this.onMoreOptions,
    this.onTapBackButton,
  });

  @override
  State<ThreeSpeakCurrentUserAccount> createState() =>
      _ThreeSpeakCurrentUserAccountState();
}

class _ThreeSpeakCurrentUserAccountState
    extends State<ThreeSpeakCurrentUserAccount>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allVideos = [];
  bool isLoading = true;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging && widget.onTabChanged != null) {
        widget.onTabChanged!(_tabController.index);
      }
    });
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final uri = Uri.parse(server.myVideosApiUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': widget.token,
    };
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          allVideos = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> get encodingVideos =>
      allVideos
          .where(
            (v) => [
              'uploaded',
              'encoding_queued',
              'encoding',
            ].contains(v['status']),
          )
          .toList();

  List<dynamic> get publishNowVideos =>
      allVideos.where((v) => v['status'] == 'publish_manual').toList();

  List<dynamic> get myVideos =>
      allVideos.where((v) => v['status'] == 'published').toList();

  Widget buildVideoList(
    List<dynamic> videos, {
    required VideoListType listType,
  }) {
    if (videos.isEmpty) {
      return const Center(child: Text('No videos found.'));
    }

    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final thumbnailUrl = video['thumbUrl'] ?? '';
        final title = video['title'] ?? 'No Title';
        final permlink = video['permlink'] ?? '';
        final username = video['owner'] ?? widget.username;
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnailUrl,
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Container(width: 100, height: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),
              if (listType == VideoListType.publishNow)
                ElevatedButton(
                  onPressed: () {
                    if (widget.onPublish != null) {
                      widget.onPublish!(username, permlink);
                    } else {
                      print("Publish video: \\${video['_id']}");
                    }
                  },
                  child: const Text("Publish"),
                ),
              if (listType == VideoListType.myVideos)
                ElevatedButton(
                  onPressed: () {
                    if (widget.onViewMyVideo != null) {
                      widget.onViewMyVideo!(username, permlink);
                    } else {
                      print("View My Video: \\${video['_id']}");
                    }
                  },
                  child: const Text("View My Video"),
                ),
              if (listType == VideoListType.encoding)
                ElevatedButton(
                  onPressed: () {
                    if (widget.onViewDetails != null) {
                      widget.onViewDetails!(username, permlink);
                    } else {
                      print("View Details: \\${video['_id']}");
                    }
                  },
                  child: const Text("View Details"),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  if (widget.onMoreOptions != null) {
                    widget.onMoreOptions!(video['_id'] ?? '');
                  } else {
                    print("More options for: \\${video['_id']}");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onTapBackButton != null) {
              widget.onTapBackButton!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Row(
          children: [
            UserProfileImage(userName: widget.username, radius: 40),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.username,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              if (widget.onLogout != null) {
                widget.onLogout!();
              } else {
                // Default action
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Publish Now'),
            Tab(text: 'My Videos'),
            Tab(text: 'Encoding'),
          ],
        ),
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  buildVideoList(
                    publishNowVideos,
                    listType: VideoListType.publishNow,
                  ),
                  buildVideoList(myVideos, listType: VideoListType.myVideos),
                  buildVideoList(
                    encodingVideos,
                    listType: VideoListType.encoding,
                  ),
                ],
              ),
    );
  }
}
