import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import '../common_list_view/view_list.dart';

class AccountPostsScreen extends StatefulWidget {
  final HiveFlutterKitPlatform dhive;
  final String account;
  final Function? onTap;
  final Function? onAuthorTap;
  final Function? onCategoryTap;
  final Function? onUpvoteTap;
  final Function? onDownVoteTap;
  final Function? onCommentTap;
  final Function? onReblogTap;

  const AccountPostsScreen({
    super.key,
    required this.dhive,
    required this.account,
    this.onTap,
    this.onAuthorTap,
    this.onCategoryTap,
    this.onUpvoteTap,
    this.onDownVoteTap,
    this.onCommentTap,
    this.onReblogTap,
  });

  @override
  State<AccountPostsScreen> createState() => _AccountPostsScreenState();
}

class _AccountPostsScreenState extends State<AccountPostsScreen> {
  List<Discussion> posts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        _loadMorePosts();
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
      hasMore = true;
    });

    try {
      final result = await widget.dhive.getAccountPosts(
        widget.account,
        "posts",
        limit: pageSize,
      );
      setState(() {
        posts = result;
        isLoading = false;
        hasMore = result.length == pageSize;
      });
    } catch (e) {
      debugPrint('Error loading account posts: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (posts.isEmpty || isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    final lastPost = posts.last;

    try {
      final morePosts = await widget.dhive.getAccountPosts(
        widget.account,
        "posts",
        limit: pageSize + 1,
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
        posts.addAll(filtered);
        hasMore = filtered.length >= pageSize;
        isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading more account posts: $e');
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
        posts
            .map(
              (discussion) =>
                  '\$${discussion.payout?.toStringAsFixed(2) ?? '0.00'}',
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: ViewList(
          discussions: posts,
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
