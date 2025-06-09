import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_feed_list.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/video_player.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/get_video_url.dart';

class SearchScreen extends StatefulWidget {
  final LoginModel loginModel;
  const SearchScreen({Key? key, required this.loginModel}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String text = '';
  late TextEditingController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      title: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          _timer?.cancel();

          // If cleared or less than 4 characters
          if (value.trim().isEmpty || value.trim().length <= 3) {
            setState(() {
              text = '';
            });
            return;
          }

          _timer = Timer(const Duration(milliseconds: 800), () {
            setState(() {
              text = value.trim();
            });
          });
        },
      ),
      actions: [
        if (_controller.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              setState(() {
                text = '';
              });
            },
          ),
      ],
    );
  }

  Widget _searchResults() {
    if (text.isEmpty) {
      return const Center(
        child: Text('Search videos by typing at least 4 characters.'),
      );
    }

    return ThreeSpeakFeedList(
      feedType: ThreeSpeakFeedType.search,
      searchTerm: text,
      onTapVideoItem: (item) {
        final videoUrl = getVideoUrl(item);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => VideoPlayerScreen(
                  videoUrl: videoUrl ?? '',
                  title: item.title ?? 'Untitled',
                  author: item.author?.username ?? 'Unknown',
                  permlink: item.permlink ?? 'Unknown',
                  createdAt: item.createdAt,
                  item: item,
                ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(), body: _searchResults());
  }
}
