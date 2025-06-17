import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/video_player.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/user_profile_image.dart';

class SearchScreen extends StatefulWidget {
  final String currentUser;
  const SearchScreen({super.key, required this.currentUser});

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
              (_controller.text.trim().length >= 4)
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UserProfileimage(
                      url: _controller.text.trim(),
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
              (_controller.text.isNotEmpty)
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        text = '';
                      });
                    },
                  )
                  : null,
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: (value) {
          _timer?.cancel();

          setState(() {}); // Rebuild to update prefix/suffix

          if (value.trim().isEmpty || value.trim().length < 4) {
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
    );
  }

  Widget _searchResults() {
    if (text.isEmpty) {
      return const Center(
        child: Text('Search videos by typing at least 4 characters.'),
      );
    }

    return ThreeSpeakVideoFeed(
      feedType: ThreeSpeakVideoFeedType.search,
      searchTerm: text,
      onTapVideoItem: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(item: item),
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
