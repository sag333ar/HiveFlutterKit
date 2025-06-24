import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/ux/dhive/common_list_view/view_comments.dart';

class CommentsScreen extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final String account;
  final Function? onTap;
  final Function? onAuthorTap;
  final Function? onCategoryTap;
  final Function? onUpvoteTap;
  final Function? onDownVoteTap;
  final Function? onCommentTap;
  final Function? onReblogTap;

  const CommentsScreen({
    super.key,
    required this.hfk,
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
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<Discussion> comments = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadComments();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        _loadMoreComments();
      }
    });
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
      hasMore = true;
    });

    try {
      final result = await widget.hfk.getAccountPosts(
        widget.account,
        "comments",
        limit: pageSize,
      );
      setState(() {
        comments = result;
        isLoading = false;
        hasMore = result.length == pageSize;
      });
    } catch (e) {
      debugPrint('Error loading account comments: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMoreComments() async {
    if (comments.isEmpty || isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    final lastComment = comments.last;

    try {
      final moreComments = await widget.hfk.getAccountPosts(
        widget.account,
        "comments",
        limit: pageSize + 1,
        startAuthor: lastComment.author,
        startPermlink: lastComment.permlink,
      );

      final filtered =
          moreComments
              .where(
                (p) =>
                    !(p.author == lastComment.author &&
                        p.permlink == lastComment.permlink),
              )
              .toList();

      setState(() {
        comments.addAll(filtered);
        hasMore = filtered.length >= pageSize;
        isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading more account comments: $e');
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
        comments
            .map(
              (discussion) =>
                  '\$${discussion.payout?.toStringAsFixed(2) ?? '0.00'}',
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadComments,
        child: ViewComments(
          discussions: comments,
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
