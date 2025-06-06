import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/graphql/gql_communicator.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/video_card_widget.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/visibility_detector.dart';

enum ThreeSpeakFeedType { trending, newUploads, hot, firstUploads }

class ThreeSpeakFeedList extends StatefulWidget {
  final ThreeSpeakFeedType feedType;
  final bool isShorts;
  final String? lang;

  final void Function(GQLFeedItem item)? onTapVideoItem;
  final void Function(GQLFeedItem item)? onTapAuthor;
  final void Function(GQLFeedItem item)? onTapReport;

  const ThreeSpeakFeedList({
    super.key,
    required this.feedType,
    this.isShorts = false,
    this.lang,
    this.onTapVideoItem,
    this.onTapAuthor,
    this.onTapReport,
  });

  @override
  State<ThreeSpeakFeedList> createState() => _ThreeSpeakFeedListState();
}

class _ThreeSpeakFeedListState extends State<ThreeSpeakFeedList> {
  final GQLCommunicator _gql = GQLCommunicator();
  List<GQLFeedItem> _items = [];
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
      List<GQLFeedItem> items = [];
      switch (widget.feedType) {
        case ThreeSpeakFeedType.trending:
          items = await _gql.getTrendingFeed(widget.isShorts, 0, widget.lang);
          break;
        case ThreeSpeakFeedType.newUploads:
          items = await _gql.getNewUploadsFeed(widget.isShorts, 0, widget.lang);
          break;
        case ThreeSpeakFeedType.hot:
          // If you have a hot feed, implement here
          // items = await _gql.getHotFeed(widget.isShorts, 0, widget.lang);
          break;
        case ThreeSpeakFeedType.firstUploads:
          items = await _gql.getFirstUploadsFeed(
            widget.isShorts,
            0,
            widget.lang,
          );
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

  void _openVideo(BuildContext context, GQLFeedItem item) {
    // TODO: Implement navigation or video open logic
    // Example: Navigator.push(...);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No videos found.'));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    if (isWide) {
      final crossAxisCount = screenWidth ~/ 350;
      return GridView.builder(
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
            onTap: () => widget.onTapVideoItem?.call(item),
            onTapAuthor: () => widget.onTapAuthor?.call(item),
            onTapReport: () => widget.onTapReport?.call(item),
          );
        },
      );
    } else {
      return VisibilityDetectorListView(
        items: _items,
        itemBuilder: (context, item, index, isVisible) {
          return VideoCard(
            item: item,
            isVisible: isVisible,
            onTap: () => widget.onTapVideoItem?.call(item),
            onTapAuthor: () => widget.onTapAuthor?.call(item),
            onTapReport: () => widget.onTapReport?.call(item),
          );
        },
      );
      // return ListView.builder(
      //   itemCount: _items.length,
      //   itemBuilder: (context, index) {
      //     final item = _items[index];
      //     return VideoCard(
      //       item: item,
      //       isVisible: true,
      //       onTap: () => _openVideo(context, item),
      //     );
      //   },
      // );
    }
  }
}
