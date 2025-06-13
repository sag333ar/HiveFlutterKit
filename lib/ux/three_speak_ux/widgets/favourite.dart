import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For optional haptic feedback

class FavouriteWidget extends StatefulWidget {
  const FavouriteWidget({
    Key? key,
    required this.isLiked,
    required this.onAdd,
    required this.onRemove,
    this.iconColor,
    this.iconSize,
    this.alignment,
    this.disablePadding = false,
    this.snackDuration = const Duration(seconds: 3),
    this.enableHaptic = true,
    required this.toastType,
  }) : super(key: key);

  final bool isLiked;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Color? iconColor;
  final bool disablePadding;
  final String toastType;
  final double? iconSize;
  final Alignment? alignment;
  final Duration snackDuration;
  final bool enableHaptic;

  @override
  State<FavouriteWidget> createState() => _FavouriteWidgetState();
}

class _FavouriteWidgetState extends State<FavouriteWidget> {
  late bool _isLiked;

  @override
  void initState() {
    _isLiked = widget.isLiked;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FavouriteWidget oldWidget) {
    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _toggleLike() {
    if (_isLiked) {
      widget.onRemove();
      _showSnackBar(false);
    } else {
      widget.onAdd();
      _showSnackBar(true);
    }

    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _showSnackBar(bool isAdding) {
    final String action = isAdding ? "added to" : "removed from";
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        duration: widget.snackDuration,
        content: Text(
          'The ${widget.toastType} is $action your bookmarks',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding =
        widget.disablePadding ? EdgeInsets.zero : const EdgeInsets.all(4);

    return InkWell(
      onTap: _toggleLike,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        alignment: widget.alignment,
        padding: padding,
        child: Icon(
          _isLiked ? Icons.bookmark : Icons.bookmark_border,
          size: widget.iconSize ?? 20,
          color: widget.iconColor ?? Colors.grey,
        ),
      ),
    );
  }
}
