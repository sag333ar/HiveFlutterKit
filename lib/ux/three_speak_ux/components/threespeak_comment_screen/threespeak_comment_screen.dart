import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/hive_post_comments.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/reply_bottomsheet.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/three_speak_core/services/api_service.dart';
import 'package:hive_flutter_kit/ux/upvote.dart';

class ThreespeakCommentScreen extends StatefulWidget {
  final String author;
  final String permlink;
  final String currentUser;
  final String authToken;
  final HiveFlutterKitPlatform hfk;
  final Function(bool status, String? result)? onSubmitComment;
  final Function(bool status, String? result)? onSubmitVote;

  const ThreespeakCommentScreen({
    super.key,
    required this.author,
    required this.permlink,
    required this.currentUser,
    required this.authToken,
    required this.hfk,
    this.onSubmitComment,
    this.onSubmitVote,
  });

  @override
  State<ThreespeakCommentScreen> createState() =>
      _ThreespeakCommentScreenState();
}

class _ThreespeakCommentScreenState extends State<ThreespeakCommentScreen> {
  void _showReplyBottomSheet(String author, String permlink) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => ReplyBottomsheet(
            parentAuthor: author,
            parentPermlink: permlink,
            currentUser: widget.currentUser,
            onCommentSubmitted: (author, permlink, body) async {
              final apiService = ApiService();
              try {
                final response = await apiService.handleComment(
                  author: author,
                  permlink: permlink,
                  body: body,
                  authToken: widget.authToken,
                );

                if (mounted) Navigator.of(context).pop();

                if (response['success'] == true) {
                  if (mounted) Navigator.of(context).pop();
                  if (widget.onSubmitComment != null) {
                    widget.onSubmitComment!(
                      true,
                      'Successfully posted on $author/$permlink',
                    );
                  }
                } else {
                  if (mounted) Navigator.of(context).pop();
                  if (widget.onSubmitComment != null) {
                    widget.onSubmitComment!(
                      false,
                      'Comment Failed: Could not post on $author/$permlink',
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comment Failed on $author/$permlink'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  if (widget.onSubmitComment != null) {
                    widget.onSubmitComment!(false, e.toString());
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comment Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  void _showVoteBottomSheet(String author, String permlink) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.5,
            child: Material(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: Colors.white,
              child: VoteBottomSheet(
                hfk: widget.hfk,
                author: author,
                permlink: permlink,
                onClickUpvoteTap: (author, permlink, weight) async {
                  final apiService = ApiService();
                  try {
                    final response = await apiService.handleUpvote(
                      author: author,
                      permlink: permlink,
                      weight: weight,
                      authToken: widget.authToken,
                    );

                    Navigator.of(context).pop();

                    if (response['success'] == true) {
                      Navigator.of(context).pop();
                      if (widget.onSubmitVote != null) {
                        widget.onSubmitVote!(
                          true,
                          "Upvote Success: Comment successfully upvoted.",
                        );
                      }
                    } else {
                      Navigator.of(context).pop();
                      if (widget.onSubmitVote != null) {
                        widget.onSubmitVote!(
                          false,
                          "Upvote Failed: Could not upvote $author/$permlink",
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Upvote Failed for $author/$permlink"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    if (widget.onSubmitVote != null) {
                      widget.onSubmitVote!(false, e.toString());
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Upvote Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HivePostComments(
      author: widget.author,
      permlink: widget.permlink,
      currentUser: widget.currentUser,
      onReplyComment: _showReplyBottomSheet,
      onUpvoteComment: _showVoteBottomSheet,
    );
  }
}
