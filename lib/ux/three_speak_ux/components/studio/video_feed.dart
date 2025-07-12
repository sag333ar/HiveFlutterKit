import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/studio_video_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/services/api_service.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/studio/video_listView.dart';

import 'video_card.dart';

enum ApiVideoFeedType {
  home,
  trending,
  newVideos,
  firstUploads,
  user,
  community,
}

class VideoFeed extends StatefulWidget {
  final ApiVideoFeedType feedType;
  final String? username;
  final String? communityId;
  final void Function(ThreeSpeakVideo item) onTapVideoItem;
  final void Function(ThreeSpeakVideo item) onTapAuthor;
  final void Function(ThreeSpeakVideo item) onTapReport;
  final void Function(ThreeSpeakVideo item) onTapUpvote;
  final void Function(ThreeSpeakVideo item) onTapComment;
  final bool? isPayoutValueVisible;
  final bool? shouldShowBackButton;
  final VoidCallback? onTapBackButton;

  const VideoFeed({
    super.key,
    required this.feedType,
    this.username,
    this.communityId,
    required this.onTapVideoItem,
    required this.onTapAuthor,
    required this.onTapReport,
    required this.onTapUpvote,
    required this.onTapComment,
    this.isPayoutValueVisible,
    this.shouldShowBackButton,
    this.onTapBackButton,
  });

  @override
  State<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  final ApiService _api = ApiService();
  List<ThreeSpeakVideo> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<ThreeSpeakVideo> items = [];
      switch (widget.feedType) {
        case ApiVideoFeedType.home:
          items = await _api.getHomeVideos();
          break;
        case ApiVideoFeedType.trending:
          items = await _api.getTrendingVideos();
          break;
        case ApiVideoFeedType.newVideos:
          items = await _api.getNewVideos();
          break;
        case ApiVideoFeedType.firstUploads:
          items = await _api.getFirstUploadsVideos();
          break;
        case ApiVideoFeedType.user:
          if (widget.username != null) {
            items = await _api.getUserVideos(widget.username!);
          }
          break;
        case ApiVideoFeedType.community:
          if (widget.communityId != null) {
            items = await _api.getCommunityVideos(widget.communityId!);
          }
          break;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _handleTapAuthor(BuildContext context, ThreeSpeakVideo item) {
    widget.onTapAuthor(item);
  }

  void _handleTapVideoItem(BuildContext context, ThreeSpeakVideo item) {
    widget.onTapVideoItem(item);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text('Error: $_error'));
    } else if (_items.isEmpty) {
      content = const Center(child: Text('No videos found.'));
    } else {
      final screenWidth = MediaQuery.of(context).size.width;
      final isWide = screenWidth >= 600;
      if (isWide) {
        final crossAxisCount = screenWidth ~/ 350;
        content = GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.99,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            print('title: ${item.title}');
            print('owner: ${item.owner}');
            print('date: ${item.created}');
            print('thumbnail: ${item.thumbnail}');
            return ThreeSpeakVideoCard(
              title: item.title ?? 'Untitled',
              username: item.owner ?? 'unknown',
              createdAt: item.created ?? DateTime.now(),
              thumbnailUrl: item.thumbnail ?? '',
              duration: item.duration ?? 0,
              votes: '0',
              comments: '0',
              rewards: '0',
              isVisible: true,
              isInGrid: true,
              isPayoutValueVisible: widget.isPayoutValueVisible,
              onTap: () => _handleTapVideoItem(context, item),
              onTapAuthor: () => _handleTapAuthor(context, item),
              onTapReport: () => widget.onTapReport(item),
              onTapUpvote: () => widget.onTapUpvote(item),
              onTapComment: () => widget.onTapComment(item),
            );
          },
        );
      }
      else {
        content = VideoListview(
          items: _items,
          itemBuilder: (context, item, index, isVisible) {
            return ThreeSpeakVideoCard(
              title: item.title ?? 'Untitled',
              username: item.owner ?? 'unknown',
              createdAt: item.created ?? DateTime.now(),
              thumbnailUrl: item.thumbnail ?? '',
              duration: item.duration ?? 0,
              votes: '0',
              comments: '0',
              rewards: '0',
              isVisible: isVisible,
              isInGrid: false,
              isPayoutValueVisible: widget.isPayoutValueVisible,
              onTap: () => _handleTapVideoItem(context, item),
              onTapAuthor: () => _handleTapAuthor(context, item),
              onTapReport: () => widget.onTapReport(item),
              onTapUpvote: () => widget.onTapUpvote(item),
              onTapComment: () => widget.onTapComment(item),
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: widget.shouldShowBackButton == true
          ? AppBar(leading: BackButton(onPressed: widget.onTapBackButton))
          : null,
      body: content,
    );
  }
}
