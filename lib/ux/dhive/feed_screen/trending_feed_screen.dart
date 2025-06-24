import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import '../common_list_view/view_list.dart';

class TrendingFeedScreen extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final Function? onTap;
  final Function? onAuthorTap;
  final Function? onCategoryTap;
  final Function? onUpvoteTap;
  final Function? onDownVoteTap;
  final Function? onCommentTap;
  final Function? onReblogTap;

  const TrendingFeedScreen({
    super.key,
    required this.hfk,
    this.onTap,
    this.onAuthorTap,
    this.onCategoryTap,
    this.onUpvoteTap,
    this.onDownVoteTap,
    this.onCommentTap,
    this.onReblogTap,
  });

  @override
  State<TrendingFeedScreen> createState() => _TrendingFeedScreenState();
}

class _TrendingFeedScreenState extends State<TrendingFeedScreen> {
  List<Discussion> discussions = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  String sortBy = 'trending';
  String tag = '';

  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDiscussions();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        _loadMoreDiscussions();
      }
    });
  }

  Future<void> _loadDiscussions() async {
    setState(() {
      isLoading = true;
      hasMore = true;
    });

    try {
      final posts = await widget.hfk.getDiscussions(
        sortBy,
        limit: pageSize,
        tag: tag,
      );
      setState(() {
        discussions = posts;
        isLoading = false;
        hasMore = posts.length == pageSize;
      });
    } catch (e) {
      debugPrint('Error loading discussions: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMoreDiscussions() async {
    if (discussions.isEmpty || isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    final lastPost = discussions.last;

    try {
      final morePosts = await widget.hfk.getDiscussions(
        sortBy,
        limit: pageSize + 1,
        tag: tag,
        startAuthor: lastPost.author,
        startPermlink: lastPost.permlink,
      );

      final filtered =
          morePosts
              .where(
                (p) =>
                    !(p.author == lastPost.author &&
                        p.permlink == lastPost.permlink),
              )
              .toList();

      setState(() {
        discussions.addAll(filtered);
        hasMore = filtered.length >= pageSize;
        isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading more discussions: $e');
      setState(() => isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<String> amountValues =
        discussions
            .map(
              (discussion) =>
                  '\$${discussion.pendingPayoutValue?.amount?.toStringAsFixed(2) ?? '0.00'}',
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadDiscussions,
        child: ViewList(
          discussions: discussions,
          isLoadingMore: isLoadingMore,
          hasMore: hasMore,
          scrollController: _scrollController,
          amoutValues: amountValues,
          onTap: widget.onTap,
          onAuthorTap: widget.onAuthorTap,
          onCategoryTap: widget.onCategoryTap,
          onUpvoteTap: widget.onUpvoteTap,
          onDownVoteTap: widget.onDownVoteTap,
          onCommentTap: widget.onCommentTap,
          onReblogTap: widget.onReblogTap,
        ),
      ),
    );
  }
}
