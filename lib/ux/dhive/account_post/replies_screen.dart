import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import '../common_list_view/view_comments.dart';

class RepliesScreen extends StatefulWidget {
  final HiveFlutterKitPlatform dhive;
  final String account;
  final Function? onTap;
  final Function? onAuthorTap;
  final Function? onCategoryTap;
  final Function? onUpvoteTap;
  final Function? onCommentTap;
  final Function? onReblogTap;

  const RepliesScreen({
    super.key,
    required this.dhive,
    required this.account,
    this.onTap,
    this.onAuthorTap,
    this.onCategoryTap,
    this.onUpvoteTap,
    this.onCommentTap,
    this.onReblogTap,
  });

  @override
  State<RepliesScreen> createState() => _RepliesScreenState();
}

class _RepliesScreenState extends State<RepliesScreen> {
  List<Discussion> replies = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadReplies();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        _loadMoreReplies();
      }
    });
  }

  Future<void> _loadReplies() async {
    setState(() {
      isLoading = true;
      hasMore = true;
    });

    try {
      final result = await widget.dhive.getAccountPosts(
        widget.account,
        "replies",
        limit: pageSize,
      );
      setState(() {
        replies = result;
        isLoading = false;
        hasMore = result.length == pageSize;
      });
    } catch (e) {
      debugPrint('Error loading account replies: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMoreReplies() async {
    if (replies.isEmpty || isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    final lastReply = replies.last;

    try {
      final moreReplies = await widget.dhive.getAccountPosts(
        widget.account,
        "replies",
        limit: pageSize + 1,
        startAuthor: lastReply.author,
        startPermlink: lastReply.permlink,
      );

      final filtered =
          moreReplies
              .where(
                (p) =>
                    !(p.author == lastReply.author &&
                        p.permlink == lastReply.permlink),
              )
              .toList();

      setState(() {
        replies.addAll(filtered);
        hasMore = filtered.length >= pageSize;
        isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading more account replies: $e');
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
        replies
            .map(
              (discussion) =>
                  '\$${discussion.payout?.toStringAsFixed(2) ?? '0.00'}',
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Replies'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadReplies,
        child: ViewComments(
          discussions: replies,
          isLoadingMore: isLoadingMore,
          hasMore: hasMore,
          scrollController: _scrollController,
          amoutValues: amountValues,
          onTap: widget.onTap,
          onAuthorTap: widget.onAuthorTap,
          onCategoryTap: widget.onCategoryTap,
          onUpvoteTap: widget.onUpvoteTap,
          onCommentTap: widget.onCommentTap,
          onReblogTap: widget.onReblogTap,
        ),
      ),
    );
  }
}
