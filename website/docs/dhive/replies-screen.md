---
title: DHive - User's Replies
sidebar_label: Replies
slug: /dhive/replies-screen
---

# 💬 Dhive - User's Replies

The `RepliesScreen` widget is used to display a scrollable list of replies that a specific Hive account has received on their posts or comments. It fetches discussions using the "replies" filter specific to that account. The widget handles pagination (infinite scrolling) and provides standard interaction callbacks.

---

## Features

- Displays replies received by a Hive account
- Supports infinite scrolling
- Interaction callbacks (tap, vote, reply, etc.)
- Easy to integrate with custom UI

---

## Constructor

```dart
RepliesScreen({
  Key? key,
  required HiveFlutterKitPlatform hfk,
  required String account,
  void Function(Discussion reply)? onTap,
  void Function(String author)? onAuthorTap,
  void Function(String category)? onCategoryTap,
  void Function(Discussion reply)? onUpvoteTap,
  void Function(Discussion reply)? onCommentTap,
  void Function(Discussion reply)? onReblogTap,
})
```

## Parameters

| Parameter       | Type                     | Required | Description                                      |
| --------------- | ------------------------ | -------- | ------------------------------------------------ |
| `key`           | `Key?`                   | No       | Flutter widget key                               |
| `hfk`         | `HiveFlutterKitPlatform` | Yes      | Hive platform instance used for fetching replies |
| `account`       | `String`                 | Yes      | Hive account username to get replies for         |
| `onTap`         | `Function(Discussion)?`  | No       | Called when a reply is tapped                    |
| `onAuthorTap`   | `Function(String)?`      | No       | Called when author's avatar/name is tapped       |
| `onCategoryTap` | `Function(String)?`      | No       | Called when the category is tapped               |
| `onUpvoteTap`   | `Function(Discussion)?`  | No       | Called when upvote icon is tapped                |
| `onCommentTap`  | `Function(Discussion)?`  | No       | Called when comment/reply icon is tapped         |
| `onReblogTap`   | `Function(Discussion)?`  | No       | Called for reblog action (if supported)          |

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';

class MyAccountRepliesScreen extends StatelessWidget {
  final HiveFlutterKitPlatform hfk;
  final String accountName = "peakd";

  const MyAccountRepliesScreen({super.key, required this.hfk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Replies to @$accountName"),
      ),
      body: RepliesScreen(
        hfk: hfk,
        account: accountName,
        onTap: (Discussion reply) {
          print("Tapped on reply from @\${reply.author}: \${reply.permlink}");
          print("In response to: @\${reply.parentAuthor}/\${reply.parentPermlink}");
        },
        onAuthorTap: (String author) {
          print("Tapped on author of reply: \$author");
        },
      ),
    );
  }
}

// Example initialization
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final hfk = await HiveFlutterKit.platform.initialize(...);
//   runApp(MaterialApp(home: MyAccountRepliesScreen(hfk: hfk)));
// }
```

---

## Screenshots

| List View                  | Grid View                  | Large Preview                  |
| -------------------------- | -------------------------- | ------------------------------ |
| ![List View](/img/dhive/image-12.png) | ![Grid View](/img/dhive/image-13.png) | ![Large Preview](/img/dhive/image-14.png) |

---

## Notes

- Reblogging replies may not be supported by default on Hive; customize based on your app behavior.
- Always ensure `HiveFlutterKitPlatform` is initialized before using the widget.

---

## Related

- [CommentsScreen](/dhive/comments-screen.md)
- [BlogScreen](/dhive/blog-screen.md)
- `Discussion` model
- `HiveFlutterKitPlatform`
- `ViewList` components

---
