import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/studio_video_model.dart';

class VideoListview extends StatefulWidget {
  final List<ThreeSpeakVideo> items;
  final Widget Function(BuildContext, ThreeSpeakVideo, int, bool) itemBuilder;

  const VideoListview({
    Key? key,
    required this.items,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  State<VideoListview> createState() => _VideoListviewState();
}

class _VideoListviewState extends State<VideoListview> {
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
