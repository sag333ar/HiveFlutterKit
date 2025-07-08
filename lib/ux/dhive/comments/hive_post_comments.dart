import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/comment_search_bar.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/comment_tile.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/reply_bottomsheet.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class HivePostComments extends StatefulWidget {
  const HivePostComments({
    super.key,
    required this.author,
    required this.permlink,
    this.onComment,
    this.onUpvoteComment,
    this.onReplyComment,
    this.currentUser,
  });
  final String author;
  final String permlink;
  final void Function(String body)? onComment;
  final void Function(String author, String permlink)? onUpvoteComment;
  final void Function(String author, String permlink)? onReplyComment;
  final String? currentUser;

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
  final HiveFlutterKitPlatform hfk = HiveFlutterKitPlatform.instance;

  List<Discussion> _comments = [];
  bool _loading = true;
  bool _error = false;
  bool _isAddingComment = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String _currentUser = '';
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchComments();
  }

  Future<void> _loadCurrentUser() async {
    var username = await hfk.getCurrentUser();
    username = username.replaceAll('"', '');
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
    } catch (e, st) {
      print('[HivePostComments] Error fetching comments: $e\n$st');
      setState(() {
        _error = true;
        _loading = false;
      });
    }
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

    void _showGlobalSnackBar(
      String message, {
      Color backgroundColor = Colors.green,
    }) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }

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
                  ? (author, permlink) {
                    widget.onReplyComment!(author, permlink);
                  }
                  : null,
          // : (author, permlink) => _showCommentInput(
          //       parentAuthor: author,
          //       parentPermlink: permlink,
          //       depth: item.depth,
          //     ),
          onUpvote:
              widget.onUpvoteComment != null
                  ? (author, permlink) {
                    widget.onUpvoteComment!(author, permlink);
                  }
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
    if (_currentUser == null ||
        _currentUser == '' ||
        _currentUser.contains('No user is currently logged in'))
      return SizedBox.shrink();
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
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder:
                              (context) => ReplyBottomsheet(
                                parentAuthor: widget.author,
                                parentPermlink: widget.permlink,
                              ),
                        );
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
