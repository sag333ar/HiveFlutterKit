import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/components/user_profile_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';

enum VideoListType { publishNow, myVideos, encoding }

typedef OnPublishCallback = void Function(String username, String permlink);
typedef OnViewMyVideoCallback = void Function(String username, String permlink);
typedef OnViewDetailsCallback = void Function(String username, String permlink);
typedef OnMoreOptionsCallback = void Function(String videoId);
typedef OnTabChangedCallback = void Function(int tabIndex);

class ThreeSpeakCurrentUserAccount extends StatefulWidget {
  final String? token;
  final String username;
  final OnTabChangedCallback? onTabChanged;
  final VoidCallback? onLogout;
  final OnPublishCallback? onPublish;
  final OnViewMyVideoCallback? onViewMyVideo;
  final OnViewDetailsCallback? onViewDetails;
  final OnMoreOptionsCallback? onMoreOptions;
  final VoidCallback? onTapBackButton;
  final bool shouldShowBackButton;
  final bool shouldShowPublishButton;

  const ThreeSpeakCurrentUserAccount({
    super.key,
    this.token,
    required this.username,
    this.onTabChanged,
    this.onLogout,
    this.onPublish,
    this.onViewMyVideo,
    this.onViewDetails,
    this.onMoreOptions,
    this.onTapBackButton,
    this.shouldShowBackButton = true,
    this.shouldShowPublishButton = false,
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
  String? errorMessage;
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchVideos() async {
    if (widget.token == null) {
      setState(() {
        errorMessage = 'No authentication token provided';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse(server.myVideosApiUrl);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': widget.token!,
      };

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          allVideos = responseData is List ? responseData : [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching videos: $e');
      setState(() {
        errorMessage = 'Failed to load videos: $e';
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
      String emptyMessage;
      switch (listType) {
        case VideoListType.publishNow:
          emptyMessage = 'No videos ready to publish.';
          break;
        case VideoListType.myVideos:
          emptyMessage = 'No published videos found.';
          break;
        case VideoListType.encoding:
          emptyMessage = 'No videos currently encoding.';
          break;
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchVideos,
      child: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          final thumbnailUrl = video['thumbUrl'] ?? '';
          final title = video['title'] ?? 'No Title';
          final permlink = video['permlink'] ?? '';
          final username = video['owner'] ?? widget.username;
          final videoId = video['_id'] ?? '';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                          (context, error, stackTrace) => Container(
                            width: 100,
                            height: 60,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.video_library,
                              color: Colors.grey[600],
                            ),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 100,
                          height: 60,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'By $username',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (video['status'] != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(video['status']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              video['status'].toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      if (listType == VideoListType.publishNow && widget.shouldShowPublishButton)
                        ElevatedButton(
                          onPressed: () {
                            if (widget.onPublish != null) {
                              widget.onPublish!(username, permlink);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: const Text("Publish"),
                        ),
                      if (listType == VideoListType.myVideos)
                        ElevatedButton(
                          onPressed: () {
                            if (widget.onViewMyVideo != null) {
                              widget.onViewMyVideo!(username, permlink);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: const Text("View"),
                        ),
                      if (listType == VideoListType.encoding)
                        ElevatedButton(
                          onPressed: () {
                            if (widget.onViewDetails != null) {
                              widget.onViewDetails!(username, permlink);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: const Text("Details"),
                        ),
                      const SizedBox(height: 4),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          if (widget.onMoreOptions != null) {
                            widget.onMoreOptions!(videoId);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'encoding':
      case 'encoding_queued':
        return Colors.orange;
      case 'uploaded':
        return Colors.blue;
      case 'publish_manual':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
        title: Row(
          children: [
            if (!widget.shouldShowBackButton) const SizedBox(width: 12),
            UserProfileImage(userName: widget.username, radius: 40),
            const SizedBox(width: 12),
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchVideos),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              if (widget.onLogout != null) {
                widget.onLogout!();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Publish Now',
              icon: Badge(
                label: Text('${publishNowVideos.length}'),
                child: const Icon(Icons.publish),
              ),
            ),
            Tab(
              text: 'My Videos',
              icon: Badge(
                label: Text('${myVideos.length}'),
                child: const Icon(Icons.video_library),
              ),
            ),
            Tab(
              text: 'Encoding',
              icon: Badge(
                label: Text('${encodingVideos.length}'),
                child: const Icon(Icons.hourglass_empty),
              ),
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(fontSize: 16, color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchVideos,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
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
