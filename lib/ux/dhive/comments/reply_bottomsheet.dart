import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class ReplyBottomsheet extends StatefulWidget {
  final String parentAuthor;
  final String parentPermlink;
  final String? currentUser;
  final Future<void> Function(String author, String permlink, String body)?
  onCommentSubmitted;

  const ReplyBottomsheet({
    super.key,
    required this.parentAuthor,
    required this.parentPermlink,
    this.currentUser,
    this.onCommentSubmitted,
  });

  @override
  State<ReplyBottomsheet> createState() => _ReplyBottomsheetState();
}

class _ReplyBottomsheetState extends State<ReplyBottomsheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  String _currentUser = "";

  final HiveFlutterKitPlatform hfk = HiveFlutterKitPlatform.instance;
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
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

  Future<void> _sendReply() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;

    setState(() => _isSending = true);

    try {
      if (widget.onCommentSubmitted != null) {
        await widget.onCommentSubmitted!(
          widget.parentAuthor,
          widget.parentPermlink,
          body,
        );
      } else {
        // Use aioha-current-user's comment (hfk)
        final hfk = HiveFlutterKitPlatform.instance;
        final permlink = DateTime.now().millisecondsSinceEpoch.toString();
        final result = await hfk.comment(
          widget.parentAuthor,
          widget.parentPermlink,
          permlink,
          "",
          body,
          {},
        );
        final decodedResult = jsonDecode(result);
        if (decodedResult['success'] == true) {
          Navigator.of(context).pop();
          _showSnackBar('Vote Success: $result', Colors.green);
        } else {
          Navigator.of(context).pop();
          _showSnackBar('Vote Failed: ${decodedResult['error']}', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to send reply: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentAvatarUrl =
        "https://images.hive.blog/u/${widget.parentAuthor}/avatar";
    final currentUserAvatarUrl =
        widget.currentUser != null
            ? "https://images.hive.blog/u/${widget.currentUser}/avatar"
            : "https://images.hive.blog/u/$_currentUser/avatar";

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Author Avatar
              CircleAvatar(
                backgroundImage: NetworkImage(parentAvatarUrl),
                radius: 20,
              ),
              SizedBox(width: 8),
              // Author/permlink inline
              Text(
                '${widget.parentAuthor}/${widget.parentPermlink}',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Spacer(),
              // Current User Avatar
              CircleAvatar(
                backgroundImage: NetworkImage(currentUserAvatarUrl),
                radius: 20,
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            enabled: !_isSending,
            decoration: InputDecoration(
              labelText: 'Reply',
              hintText: 'Enter your reply here...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Spacer(),
              TextButton(
                onPressed: _isSending ? null : () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSending ? null : _sendReply,
                child:
                    _isSending
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text('Send'),
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
