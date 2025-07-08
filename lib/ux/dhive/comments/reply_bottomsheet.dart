import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class ReplyBottomsheet extends StatefulWidget {
  final String parentAuthor;
  final String parentPermlink;
  final Future<void> Function(String body)? onCommentSubmitted;

  const ReplyBottomsheet({
    super.key,
    required this.parentAuthor,
    required this.parentPermlink,
    this.onCommentSubmitted,
  });

  @override
  State<ReplyBottomsheet> createState() => _ReplyBottomsheetState();
}

class _ReplyBottomsheetState extends State<ReplyBottomsheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendReply() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;

    setState(() => _isSending = true);

    try {
      if (widget.onCommentSubmitted != null) {
        await widget.onCommentSubmitted!(body);
      } else {
        // Use aioha-current-user's comment (hfk)
        final hfk = HiveFlutterKitPlatform.instance;
        final permlink = DateTime.now().millisecondsSinceEpoch.toString();
        await hfk.comment(
          widget.parentAuthor,
          widget.parentPermlink,
          permlink,
          "",
          body,
          {},
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reply: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            enabled: !_isSending,
            decoration: InputDecoration(
              labelText: 'Reply',
              hintText: 'Enter your reply here...',
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
                child: _isSending
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