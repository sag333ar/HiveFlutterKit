import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/ux/upvote.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:math' as math;

class CommentTile extends StatefulWidget {
  const CommentTile({
    Key? key,
    required this.comment,
    required this.index,
    required this.currentUser,
    required this.searchKey,
    required this.itemScrollController,
    this.isPadded = false,
    this.onReply,
    this.onUpvote,
    this.allComments,
  }) : super(key: key);

  final Discussion comment;
  final int index;
  final String currentUser;
  final String searchKey;
  final ItemScrollController itemScrollController;
  final bool isPadded;
  final void Function()? onReply;
  final void Function()? onUpvote;
  final List<Discussion>? allComments; // <-- Add this

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool isHighlighted = false;
  String _currentUser = "";
  final HiveFlutterKitPlatform hfk = HiveFlutterKitPlatform.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _colorAnimation = ColorTween(
      begin: Colors.blue.withOpacity(0.1),
      end: Colors.transparent,
    ).animate(_animationController);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isHighlighted = false;
        });
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    final username = await hfk.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = username ?? "";
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  bool _hasVoted() {
    return widget.comment.activeVotes!
        .where((vote) => vote.voter == _currentUser)
        .isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final int depth = widget.comment.depth ?? 1;
    final padding =
        widget.isPadded
            ? EdgeInsets.only(left: math.max(0, (depth - 1) * 16.0))
            : EdgeInsets.zero;

    // Find replies if available
    List<Widget> replyWidgets = [];
    if (widget.comment.replies != null &&
        widget.comment.replies!.isNotEmpty &&
        widget.allComments != null) {
      for (final replyKey in widget.comment.replies!) {
        final parts = replyKey.split('/');
        if (parts.length == 2) {
          final replyAuthor = parts[0];
          final replyPermlink = parts[1];
          final reply =
              widget.allComments!
                  .where(
                    (c) =>
                        c.author == replyAuthor && c.permlink == replyPermlink,
                  )
                  .cast<Discussion?>()
                  .toList();
          if (reply.isNotEmpty) {
            replyWidgets.add(
              CommentTile(
                comment: reply.first!,
                index: 0,
                currentUser: widget.currentUser,
                searchKey: widget.searchKey,
                itemScrollController: widget.itemScrollController,
                isPadded: true,
                onReply: widget.onReply,
                allComments: widget.allComments,
              ),
            );
          }
        }
      }
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: isHighlighted ? _colorAnimation.value : Colors.transparent,
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 20,
                    child: Text(
                      widget.comment.author!.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        widget.comment.author!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _getTimeAgo(
                          widget.comment.created != null
                              ? DateTime.tryParse(widget.comment.created!) ??
                                  DateTime.now()
                              : DateTime.now(),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Builder(
                      builder: (context) {
                        try {
                          final body = widget.comment.body ?? '';
                          // Check for image URL (jpg, png, gif, jpeg, webp, svg)
                          final imageUrlRegExp = RegExp(
                            r'(https?:\/\/.*\.(?:png|jpg|jpeg|gif|webp|svg))',
                            caseSensitive: false,
                          );
                          final imageUrlMatch = imageUrlRegExp.firstMatch(body);

                          // Simple check for HTML tags
                          final isHtml = RegExp(
                            r'<[a-z][\s\S]*>',
                          ).hasMatch(body);

                          if (imageUrlMatch != null) {
                            final url =
                                'https://images.hive.blog/360x360/${imageUrlMatch.group(0)!}';
                            final before = body.substring(
                              0,
                              imageUrlMatch.start,
                            );
                            final after = body.substring(imageUrlMatch.end);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (before.trim().isNotEmpty)
                                  isHtml
                                      ? Html(
                                        data: before,
                                        style: {
                                          "body": Style(
                                            fontSize: FontSize(14),
                                            color: Colors.black87,
                                            lineHeight: LineHeight(1.4),
                                          ),
                                        },
                                      )
                                      : MarkdownBody(
                                        data: before,
                                        styleSheet: MarkdownStyleSheet(
                                          p: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => Dialog(
                                              child: InteractiveViewer(
                                                child: Image.network(url),
                                              ),
                                            ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (after.trim().isNotEmpty)
                                  isHtml
                                      ? Html(
                                        data: after,
                                        style: {
                                          "body": Style(
                                            fontSize: FontSize(14),
                                            color: Colors.black87,
                                            lineHeight: LineHeight(1.4),
                                          ),
                                        },
                                      )
                                      : MarkdownBody(
                                        data: after,
                                        styleSheet: MarkdownStyleSheet(
                                          p: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                              ],
                            );
                          } else if (isHtml) {
                            return Html(
                              data: body,
                              style: {
                                "body": Style(
                                  fontSize: FontSize(14),
                                  color: Colors.black87,
                                  lineHeight: LineHeight(1.4),
                                ),
                              },
                            );
                          } else {
                            return MarkdownBody(
                              data: body,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              onTapLink: (text, href, title) {
                                if (href != null &&
                                    imageUrlRegExp.hasMatch(href)) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => Dialog(
                                          child: InteractiveViewer(
                                            child: Image.network(href),
                                          ),
                                        ),
                                  );
                                }
                              },
                            );
                          }
                        } catch (e) {
                          return Text(
                            "Unable to display comment.",
                            style: TextStyle(
                              color: Colors.red,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 72.0,
                    bottom: 12.0,
                    right: 16.0,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          if (widget.onUpvote != null) {
                            widget.onUpvote!();
                            return;
                          }
                          if (_currentUser.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please login to reply'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.blue,
                              ),
                            );
                            return;
                          }
                          if (_hasVoted()) {
                            return;
                          }
                          // Show upvote dialog with slider and thumb icon
                          final hfk = HiveFlutterKitPlatform.instance;
                          final result = await showDialog(
                            context: context,
                            builder:
                                (context) => VoteDialog(
                                  hfk: hfk,
                                  author: widget.comment.author!,
                                  permlink: widget.comment.permlink!,
                                ),
                          );
                          // If upvote was successful, reload this comment tile
                          if (result == true) {
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_up,
                                size: 16,
                                color:
                                    _hasVoted()
                                        ? Colors.blue
                                        : Colors.grey[400],
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.comment.stats?.totalVotes?.toString() ??
                                    '0',
                                style: TextStyle(
                                  color:
                                      _hasVoted()
                                          ? Colors.blue
                                          : Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          if (widget.onReply != null) {
                            widget.onReply!();
                            return;
                          }
                          if (_currentUser.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please login to reply'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.blue,
                              ),
                            );
                            return;
                          }
                          // ...existing code...
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Reply',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Show replies if any
                if (replyWidgets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: replyWidgets,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
