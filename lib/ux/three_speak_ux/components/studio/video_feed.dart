import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/studio_video_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/services/api_service.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/studio/video_listView.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_card_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum ApiVideoFeedType {
  home,
  trending,
  newVideos,
  firstUploads,
  user,
  community,
  related,
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

  static final Map<String, List<ThreeSpeakVideo>> _feedCache = {};

  static String _getCacheKey(
    ApiVideoFeedType feedType,
    String? username,
    String? communityId,
  ) {
    switch (feedType) {
      case ApiVideoFeedType.user:
        return 'user:${username ?? ''}';
      case ApiVideoFeedType.community:
        return 'community:${communityId ?? ''}';
      default:
        return feedType.name;
    }
  }

  @override
  State<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  final ApiService _api = ApiService();
  List<ThreeSpeakVideo> _items = [];
  List<VideoFeedGridItemViewModel> _viewModels = [];
  bool _loading = true;
  String? _error;

  int _skip = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCacheAndFetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore &&
        !_loading) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
    });
    await _fetchFeed();
  }

  void _loadCacheAndFetch() {
    final key = VideoFeed._getCacheKey(
      widget.feedType,
      widget.username,
      widget.communityId,
    );
    final cachedItems = VideoFeed._feedCache[key];
    if (cachedItems != null && cachedItems.isNotEmpty) {
      setState(() {
        _items = cachedItems;
        _viewModels =
            cachedItems
                .map(VideoFeedGridItemViewModel.fromThreeSpeakVideo)
                .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = true;
      });
    }
    _fetchFeed();
  }

  Future<void> _fetchFeed({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _skip = 0;
      _hasMore = true;
      _items.clear();
      _viewModels.clear();
    }

    try {
      List<ThreeSpeakVideo> newItems = [];

      switch (widget.feedType) {
        case ApiVideoFeedType.home:
          newItems = await _api.getHomeVideos(skip: _skip);
          break;
        case ApiVideoFeedType.trending:
          newItems = await _api.getTrendingVideos(skip: _skip);
          break;
        case ApiVideoFeedType.newVideos:
          newItems = await _api.getNewVideos(skip: _skip);
          break;
        case ApiVideoFeedType.firstUploads:
          newItems = await _api.getFirstUploadsVideos(skip: _skip);
          break;
        case ApiVideoFeedType.user:
          if (widget.username != null) {
            newItems = await _api.getUserVideos(widget.username!, skip: _skip);
          }
          break;
        case ApiVideoFeedType.community:
          if (widget.communityId != null) {
            newItems = await _api.getCommunityVideos(
              widget.communityId!,
              skip: _skip,
            );
          }
          break;
        case ApiVideoFeedType.related:
          if (widget.username != null) {
            newItems = await _api.getRelatedVideos(
              widget.username!,
              skip: _skip,
            );
          }
          break;
      }

      setState(() {
        if (newItems.length < 50) _hasMore = false;
        _items.addAll(newItems);
        _viewModels.addAll(
          newItems.map(VideoFeedGridItemViewModel.fromThreeSpeakVideo),
        );
        _loading = false;
        _isLoadingMore = false;
        _error = null;
      });

      _skip += newItems.length;
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _handleTapVideoItem(BuildContext context, ThreeSpeakVideo item) {
    widget.onTapVideoItem(item);
  }

  void _handleTapAuthor(BuildContext context, ThreeSpeakVideo item) {
    widget.onTapAuthor(item);
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    if (_loading && _items.isEmpty) {
      final dummyItems = List.generate(
        isWide ? 8 : 6,
        (_) => VideoFeedGridItemViewModel.dummy(),
      );

      if (isWide) {
        final crossAxisCount = screenWidth ~/ 350;
        return Skeletonizer(
          enabled: true,
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.99,
            ),
            itemCount: dummyItems.length,
            itemBuilder: (context, index) {
              return VideoCard(
                item: dummyItems[index],
                isVisible: true,
                isInGrid: true,
                onTap: () {},
                onTapAuthor: () {},
                onTapReport: () {},
                onTapUpvote: () {},
                onTapComment: () {},
              );
            },
          ),
        );
      } else {
        return Skeletonizer(
          enabled: true,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: dummyItems.length,
            itemBuilder: (context, index) {
              return VideoCard(
                item: dummyItems[index],
                isVisible: true,
                onTap: () {},
                onTapAuthor: () {},
                onTapReport: () {},
                onTapUpvote: () {},
                onTapComment: () {},
              );
            },
          ),
        );
      }
    }

    if (_error != null && _items.isEmpty) {
      return Center(child: Text('Error: $_error'));
    }

    if (_items.isEmpty) {
      return const Center(child: Text('No videos found.'));
    }

    if (isWide) {
      final crossAxisCount = screenWidth ~/ 350;
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.99,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _viewModels[index];
          return VideoCard(
            item: item,
            isVisible: true,
            isInGrid: true,
            isPayoutValueVisible: widget.isPayoutValueVisible,
            onTap: () => _handleTapVideoItem(context, _items[index]),
            onTapAuthor: () => _handleTapAuthor(context, _items[index]),
            onTapReport: () => widget.onTapReport(_items[index]),
            onTapUpvote: () => widget.onTapUpvote(_items[index]),
            onTapComment: () => widget.onTapComment(_items[index]),
          );
        },
      );
    } else {
      return VideoListview(
        controller: _scrollController,
        items: _viewModels,
        itemBuilder: (context, item, index, isVisible) {
          return VideoCard(
            item: _viewModels[index],
            isVisible: true,
            onTap: () => _handleTapVideoItem(context, _items[index]),
            onTapAuthor: () => _handleTapAuthor(context, _items[index]),
            onTapReport: () => widget.onTapReport(_items[index]),
            onTapUpvote: () => widget.onTapUpvote(_items[index]),
            onTapComment: () => widget.onTapComment(_items[index]),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.shouldShowBackButton == true
              ? AppBar(
                leading: BackButton(onPressed: widget.onTapBackButton),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () async {
                      final key = VideoFeed._getCacheKey(
                        widget.feedType,
                        widget.username,
                        widget.communityId,
                      );
                      VideoFeed._feedCache.remove(key);
                      setState(() {
                        _loading = true;
                      });
                      _fetchFeed(forceRefresh: true);
                    },
                  ),
                ],
              )
              : null,
      body: RefreshIndicator(
        onRefresh: () async {
          final key = VideoFeed._getCacheKey(
            widget.feedType,
            widget.username,
            widget.communityId,
          );
          VideoFeed._feedCache.remove(key);
          setState(() {
            _loading = true;
          });
          await _fetchFeed(forceRefresh: true);
        },
        child: _buildContent(context),
      ),
    );
  }
}
