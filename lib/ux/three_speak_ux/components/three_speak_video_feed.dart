import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/core/three_speak_core/graphql/gql_communicator.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/user_channel_screen/user_channel_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/video_player.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/user_profile_image.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_card_widget.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/visibility_detector.dart';

class ThreeSpeakVideoFeed extends StatefulWidget {
  final ThreeSpeakVideoFeedType feedType;
  final bool isShorts;
  final String? lang;
  final bool isSearch;

  final void Function(GQLFeedItem item)? onTapVideoItem;
  final void Function(GQLFeedItem item)? onTapAuthor;
  final void Function(GQLFeedItem item)? onTapReport;
  final void Function(GQLFeedItem item)? onTapUpvote;
  final void Function(GQLFeedItem item)? onTapComment;

  final String? relatedAuthor;
  final String? relatedPermlink;
  final String? username;
  final String? searchTerm;
  final String? commnuityId;

  const ThreeSpeakVideoFeed({
    super.key,
    required this.feedType,
    this.isShorts = false,
    this.lang,
    this.isSearch = false,
    this.onTapVideoItem,
    this.onTapAuthor,
    this.onTapReport,
    this.relatedAuthor,
    this.relatedPermlink,
    this.username,
    this.searchTerm,
    this.commnuityId,
    this.onTapUpvote,
    this.onTapComment,
  });

  @override
  State<ThreeSpeakVideoFeed> createState() => _ThreeSpeakVideoFeedState();
}

class _ThreeSpeakVideoFeedState extends State<ThreeSpeakVideoFeed> {
  final GQLCommunicator _gql = GQLCommunicator();
  List<GQLFeedItem> _items = [];
  bool _loading = true;
  String? _error;

  // For search bar logic
  String _searchText = '';
  String _debouncedText = '';
  Timer? _timer;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isSearch && widget.feedType == ThreeSpeakVideoFeedType.search) {
      _controller = TextEditingController();
    }
    _fetchFeed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ThreeSpeakVideoFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch if searchTerm or feedType changes, or if search bar text changes
    if (widget.isSearch && widget.feedType == ThreeSpeakVideoFeedType.search) {
      if (_debouncedText != oldWidget.searchTerm) {
        _fetchFeed();
      }
    } else if (oldWidget.searchTerm != widget.searchTerm ||
        oldWidget.feedType != widget.feedType) {
      _fetchFeed();
    }
  }

  void _onSearchChanged(String value) {
    _timer?.cancel();
    setState(() {
      _searchText = value;
    });
    if (value.trim().length < 4) {
      setState(() {
        _debouncedText = '';
      });
      _fetchFeed();
      return;
    }
    _timer = Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _debouncedText = value.trim();
      });
      _fetchFeed();
    });
  }

  PreferredSizeWidget? _buildSearchAppBar() {
    if (!(widget.isSearch &&
        widget.feedType == ThreeSpeakVideoFeedType.search)) {
      return null;
    }
    return AppBar(
      title: TextField(
        controller: _controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon:
              (_controller!.text.trim().length >= 4)
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UserProfileimage(
                      url: _controller!.text.trim(),
                      radius: 16,
                      verticalPadding: 0,
                    ),
                  )
                  : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon:
              (_controller!.text.isNotEmpty)
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _controller!.clear();
                        _searchText = '';
                        _debouncedText = '';
                      });
                      _fetchFeed();
                    },
                  )
                  : null,
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Future<void> _fetchFeed() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<GQLFeedItem> items = [];
      // If searchTerm is provided and feedType is search, use search
      if (widget.feedType == ThreeSpeakVideoFeedType.search) {
        final searchValue =
            widget.isSearch ? _debouncedText : widget.searchTerm;
        if (searchValue != null && searchValue.trim().length >= 4) {
          items = await _gql.getSearchFeed(
            searchValue.trim(),
            widget.isShorts,
            0,
            widget.lang,
          );
        }
      } else {
        switch (widget.feedType) {
          case ThreeSpeakVideoFeedType.trending:
            items = await _gql.getTrendingFeed(widget.isShorts, 0, widget.lang);
            break;
          case ThreeSpeakVideoFeedType.newUploads:
            items = await _gql.getNewUploadsFeed(
              widget.isShorts,
              0,
              widget.lang,
            );
            break;
          case ThreeSpeakVideoFeedType.hot:
            // If you have a hot feed, implement here
            // items = await _gql.getHotFeed(widget.isShorts, 0, widget.lang);
            break;
          case ThreeSpeakVideoFeedType.firstUploads:
            items = await _gql.getFirstUploadsFeed(
              widget.isShorts,
              0,
              widget.lang,
            );
            break;
          case ThreeSpeakVideoFeedType.related:
            if (widget.relatedAuthor != null &&
                widget.relatedPermlink != null) {
              items = await _gql.getRelated(
                widget.relatedAuthor!,
                widget.relatedPermlink!,
                widget.lang,
              );
            }
            break;
          case ThreeSpeakVideoFeedType.userFeed:
            final user = widget.username;
            if (user != null && user.isNotEmpty) {
              items = await _gql.getUserFeed(
                [user],
                widget.isShorts,
                0,
                widget.lang,
              );
            }
            break;
          case ThreeSpeakVideoFeedType.commnuityFeed:
            final communityId = widget.commnuityId;
            if (communityId != null && communityId.isNotEmpty) {
              items = await _gql.getCommunity(
                communityId,
                widget.isShorts,
                0,
                widget.lang,
              );
            }
            break;
          case ThreeSpeakVideoFeedType.myFeed:
            final user = widget.username;
            if (user != null && user.isNotEmpty) {
              items = await _gql.getMyFeed(
                user,
                widget.isShorts,
                0,
                widget.lang,
              );
            }
            break;
          case ThreeSpeakVideoFeedType.search:
            // Already handled above
            break;
        }
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

  void _handleTapAuthor(BuildContext context, GQLFeedItem item) {
    if (widget.onTapAuthor != null) {
      widget.onTapAuthor!(item);
    } else {
      final username = item.author?.username;
      if (username != null && username.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserChannelScreen(owner: username)),
        );
      }
    }
  }

  void _handleTapVideoItem(BuildContext context, GQLFeedItem item) {
    if (widget.onTapVideoItem != null) {
      widget.onTapVideoItem!(item);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: item)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showSearchBar =
        widget.isSearch && widget.feedType == ThreeSpeakVideoFeedType.search;
    Widget content;
    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text('Error: $_error'));
    } else if (_items.isEmpty) {
      content = Center(
        child: Text(
          showSearchBar
              ? (_controller?.text.trim().isEmpty ?? true)
                  ? 'Search videos by typing at least 4 characters.'
                  : 'No videos found.'
              : 'No videos found.',
        ),
      );
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
            childAspectRatio: 4 / 3.2,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return VideoCard(
              item: item,
              isVisible: true,
              onTap: () => _handleTapVideoItem(context, item),
              onTapAuthor: () => _handleTapAuthor(context, item),
              onTapReport: () => widget.onTapReport?.call(item),
              onTapUpvote: () => widget.onTapUpvote?.call(item),
              onTapComment: () => widget.onTapComment?.call(item),
            );
          },
        );
      } else {
        content = VisibilityDetectorListView(
          items: _items,
          itemBuilder: (context, item, index, isVisible) {
            return VideoCard(
              item: item,
              isVisible: isVisible,
              onTap: () => _handleTapVideoItem(context, item),
              onTapAuthor: () => _handleTapAuthor(context, item),
              onTapReport: () => widget.onTapReport?.call(item),
              onTapUpvote: () => widget.onTapUpvote?.call(item),
              onTapComment: () => widget.onTapComment?.call(item),
            );
          },
        );
      }
    }

    if (showSearchBar) {
      return Scaffold(appBar: _buildSearchAppBar(), body: content);
    } else {
      return content;
    }
  }
}
