import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';

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
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return widget.itemBuilder(context, widget.items[index], index, false);
      },
    );
  }
}
