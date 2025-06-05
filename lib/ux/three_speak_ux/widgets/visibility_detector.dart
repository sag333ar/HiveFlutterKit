import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VisibilityDetectorListView extends StatefulWidget {
  final List<GQLFeedItem> items;
  final Widget Function(BuildContext, GQLFeedItem, int, bool) itemBuilder;

  const VisibilityDetectorListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  State<VisibilityDetectorListView> createState() =>
      _VisibilityDetectorListViewState();
}

class _VisibilityDetectorListViewState
    extends State<VisibilityDetectorListView> {
  final Map<int, bool> _visibilityMap = {};

  @override
  void dispose() {
    _visibilityMap.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return VisibilityDetector(
          key: Key('video-$index'),
          onVisibilityChanged: (visibilityInfo) {
            final isVisible = visibilityInfo.visibleFraction > 0.5;
            if (mounted && _visibilityMap[index] != isVisible) {
              setState(() {
                _visibilityMap[index] = isVisible;
              });
            }
          },
          child: widget.itemBuilder(
            context,
            widget.items[index],
            index,
            _visibilityMap[index] ?? false,
          ),
        );
      },
    );
  }
}
