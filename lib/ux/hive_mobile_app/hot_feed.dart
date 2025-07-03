import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/ux/hive_mobile_app/hot_post_card.dart';

class HotFeed extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  const HotFeed({super.key, required this.hfk});

  @override
  State<HotFeed> createState() => _HotFeedState();
}

class _HotFeedState extends State<HotFeed> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHotPosts();
  }

  Future<void> fetchHotPosts() async {
    try {
      final result = await widget.hfk.getDiscussions(
        'hot',
        limit: 20,
        tag: '',
        startAuthor: null,
        startPermlink: null,
        observer: '',
      );
      setState(() {
        posts = result;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching hot feed: $e");
      setState(() => isLoading = false);
    }
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isWide = screenWidth >= 600;
  final crossAxisCount = isWide ? (screenWidth ~/ 300).clamp(2, 6) : 2;

  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return GridView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: posts.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 4 / 3.2 : 0.72,
    ),
    itemBuilder: (context, index) {
      final post = posts[index];
      return HotPostCard(post: post);
    },
  );
}

}
