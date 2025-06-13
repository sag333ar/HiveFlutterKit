import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/comment_search_bar.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/comment_tile.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class HivePostComments extends StatefulWidget {
  const HivePostComments({
    super.key,
    required this.author,
    required this.permlink,
    this.onComment,
    this.onUpvoteComment,
    this.onReplyComment,
  });
  final String author;
  final String permlink;
  final void Function(String body)? onComment;
  final void Function(Discussion comment)? onUpvoteComment;
  final void Function(Discussion comment)? onReplyComment;

  @override
  State<HivePostComments> createState() => _HivePostCommentsState();
}

class _HivePostCommentsState extends State<HivePostComments> {
  final ValueNotifier<bool> showSearchBar = ValueNotifier(false);
  final TextEditingController searchController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  String _currentUser = "";
  final HiveFlutterKitPlatform hfk = HiveFlutterKitPlatform.instance;

  List<Discussion> _comments = [];
  bool _loading = true;
  bool _error = false;
  bool _isAddingComment = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchComments();
  }

  Future<void> _loadCurrentUser() async {
    final username = await hfk.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = username;
      });
    }
  }

  Future<void> _fetchComments() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final comments = await hfk.getCommentsList(
        widget.author,
        widget.permlink,
      );
      setState(() {
        _comments = comments.cast<Discussion>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _addComment({
    required String body,
    String? parentAuthor,
    String? parentPermlink,
    int? depth,
  }) async {
    if (!mounted || _isAddingComment) return;

    if (_currentUser.isEmpty) {
      _showSnackBar(
        'You are not logged in. Please log in to comment.',
        Colors.blue,
      );
      return;
    }

    setState(() {
      _isAddingComment = true;
    });

    try {
      final permlink = DateTime.now().millisecondsSinceEpoch.toString();
      final res = await hfk.comment(
        parentAuthor ?? widget.author,
        parentPermlink ?? widget.permlink,
        permlink,
        "",
        body,
        {},
      );

      final decoded = jsonDecode(res);
      final isSuccess = decoded['success'] == true;

      if (mounted) {
        if (isSuccess) {
          await _fetchComments();
          _showSnackBar('Comment published successfully', Colors.green);
        } else {
          _showSnackBar('Failed to publish comment.', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to add comment: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingComment = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    // Use the specific ScaffoldMessenger for this modal
    _scaffoldMessengerKey.currentState?.clearSnackBars();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showCommentInput({
    String? parentAuthor,
    String? parentPermlink,
    int? depth,
  }) {
    final TextEditingController _controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: !_isAddingComment,
      enableDrag: !_isAddingComment,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 6,
                  enabled: !_isAddingComment,
                  decoration: InputDecoration(
                    labelText: parentAuthor == null ? 'Add a comment' : 'Reply',
                    hintText: 'Enter your comment here...',
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Spacer(),
                    TextButton(
                      onPressed:
                          _isAddingComment
                              ? null
                              : () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed:
                          _isAddingComment
                              ? null
                              : () async {
                                final text = _controller.text.trim();
                                if (text.isNotEmpty) {
                                  Navigator.pop(context);

                                  await _addComment(
                                    body: text,
                                    parentAuthor: parentAuthor,
                                    parentPermlink: parentPermlink,
                                    depth: depth,
                                  );
                                }
                              },
                      child:
                          _isAddingComment
                              ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text('Post'),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Widget commentsListView() {
    final filtered =
        searchController.text.trim().isEmpty
            ? _comments
            : _comments
                .where(
                  (c) =>
                      c.body?.toLowerCase().contains(
                        searchController.text.trim().toLowerCase(),
                      ) ??
                      false,
                )
                .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommentSearchBar(
          showSearchBar: showSearchBar,
          onChanged: (value) => setState(() {}),
          textEditingController: searchController,
        ),
        filtered.isNotEmpty
            ? Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchComments,
                child: _commentListViewBuilder(filtered),
              ),
            )
            : Expanded(
              child: Center(
                child: Text(
                  "No Results Found",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  ScrollablePositionedList _commentListViewBuilder(List<Discussion> items) {
    final Set<String> replyKeys = {};
    for (final c in items) {
      if (c.replies != null) {
        replyKeys.addAll(c.replies!);
      }
    }
    final topLevel =
        items.where((c) {
          final key = '${c.author}/${c.permlink}';
          return !replyKeys.contains(key);
        }).toList();

    return ScrollablePositionedList.separated(
      itemScrollController: itemScrollController,
      scrollOffsetController: scrollOffsetController,
      itemPositionsListener: itemPositionsListener,
      scrollOffsetListener: scrollOffsetListener,
      itemBuilder: (context, index) {
        final item = topLevel[index];
        return CommentTile(
          key: ValueKey(
            '${item.author}/${item.permlink}/${item.created ?? ''}',
          ),
          itemScrollController: itemScrollController,
          isPadded: false,
          currentUser: _currentUser,
          comment: item,
          index: index,
          searchKey: searchController.text.trim(),
          onReply:
              widget.onReplyComment != null
                  ? () => widget.onReplyComment!(item)
                  : () => _showCommentInput(
                    parentAuthor: item.author ?? '',
                    parentPermlink: item.permlink ?? '',
                    depth: item.depth,
                  ),
          onUpvote:
              widget.onUpvoteComment != null
                  ? () => widget.onUpvoteComment!(item)
                  : null,
          allComments: items,
        );
      },
      separatorBuilder:
          (context, index) =>
              Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
      itemCount: topLevel.length,
    );
  }

  Widget _addCommentButton() {
    if (_currentUser.isEmpty) return SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
        child: SizedBox(
          height: 48,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: _isAddingComment ? Colors.grey : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onPressed:
                _isAddingComment
                    ? null
                    : () {
                      if (widget.onComment != null) {
                        widget.onComment!("");
                      } else {
                        _showCommentInput();
                      }
                    },
            icon:
                _isAddingComment
                    ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Icon(Icons.add, color: Colors.white),
            label: Text(
              _isAddingComment ? "Adding..." : "Add a Comment",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: _addCommentButton(),
        appBar: AppBar(
          title: Text('Comments (${_comments.length})'),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed:
                _isAddingComment ? null : () => Navigator.of(context).pop(),
          ),
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: showSearchBar,
              builder: (context, showSearchButton, child) {
                return Visibility(
                  visible: _comments.isNotEmpty && !showSearchButton,
                  child: child!,
                );
              },
              child: IconButton(
                onPressed: () {
                  showSearchBar.value = true;
                },
                icon: Icon(Icons.search, color: Colors.black87),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child:
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : _error
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sorry, something went wrong",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: _fetchComments,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            "Retry",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : commentsListView(),
        ),
      ),
    );
  }
}
