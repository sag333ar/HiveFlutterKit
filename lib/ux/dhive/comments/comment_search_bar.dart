// lib/screens/comments/comment_search_bar.dart
import 'package:flutter/material.dart';

class CommentSearchBar extends StatelessWidget {
  const CommentSearchBar({
    Key? key,
    required this.showSearchBar,
    required this.onChanged,
    required this.textEditingController,
  }) : super(key: key);

  final ValueNotifier<bool> showSearchBar;
  final void Function(String) onChanged;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showSearchBar,
      builder: (context, showSearchbar, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: showSearchbar ? 56 : 0,
          child: showSearchbar
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textEditingController,
                          onChanged: onChanged,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search in comments...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          textEditingController.clear();
                          onChanged('');
                          showSearchBar.value = false;
                        },
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
        );
      },
    );
  }
}
