---
title: DHive - User's Comments
sidebar_label: Comments
slug: /dhive/comments-screen
---

# 🗨️ Dhive - User's Comments

The `CommentsScreen` widget is designed to display a scrollable list of comments authored by a specific Hive account. It manages fetching these comments from the blockchain, presenting them to the user, and implementing an infinite scroll mechanism to load older comments as the user scrolls. Like other similar widgets in the kit, it supports various callbacks for user interactions.

---

## Features

- Displays user-authored comments from Hive
- Supports infinite scrolling
- Offers interaction callbacks (tap, upvote, etc.)
- Customizable UI integration

---

## Constructor

```dart
CommentsScreen({
  Key? key,
  required HiveFlutterKitPlatform dhive,
  required String account,
  void Function(Discussion comment)? onTap,
  void Function(String author)? onAuthorTap,
  void Function(String category)? onCategoryTap,
  void Function(Discussion comment)? onUpvoteTap,
  void Function(Discussion comment)? onCommentTap,
  void Function(Discussion comment)? onReblogTap,
})
```

## Parameters

| Parameter       | Type                     | Required | Description                                       |
| --------------- | ------------------------ | -------- | ------------------------------------------------- |
| `key`           | `Key?`                   | No       | Flutter widget key                                |
| `dhive`         | `HiveFlutterKitPlatform` | Yes      | Hive platform instance used for fetching comments |
| `account`       | `String`                 | Yes      | Hive account username                             |
| `onTap`         | `Function(Discussion)?`  | No       | Called when a comment is tapped                   |
| `onAuthorTap`   | `Function(String)?`      | No       | Called when author's avatar/name is tapped        |
| `onCategoryTap` | `Function(String)?`      | No       | Called when the category is tapped                |
| `onUpvoteTap`   | `Function(Discussion)?`  | No       | Called when upvote icon is tapped                 |
| `onCommentTap`  | `Function(Discussion)?`  | No       | Called when comment/reply icon is tapped          |
| `onReblogTap`   | `Function(Discussion)?`  | No       | Called for reblog action (if supported)           |

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';

class MyCommentsViewScreen extends StatelessWidget {
  final HiveFlutterKitPlatform dhive;
  final String accountName = "gtg";

  const MyCommentsViewScreen({super.key, required this.dhive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments by @$accountName"),
      ),
      body: CommentsScreen(
        dhive: dhive,
        account: accountName,
        onTap: (Discussion comment) {
          print("Tapped on comment: \${comment.permlink}");
          print("Parent post: @\${comment.parentAuthor}/\${comment.parentPermlink}");
        },
        onAuthorTap: (String author) {
          print("Tapped on author: \$author");
        },
        onUpvoteTap: (Discussion comment) {
          print("Upvoted comment: \${comment.permlink}");
        },
      ),
    );
  }
}

// main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final dhive = await HiveFlutterKit.platform.initialize(...);
//   runApp(MaterialApp(home: MyCommentsViewScreen(dhive: dhive)));
// }
```

---

## Screenshots

| List View                 | Grid View                 | Large Preview                 |
| ------------------------- | ------------------------- | ----------------------------- |
| ![List View](/img/dhive/image-6.png) | ![Grid View](/img/dhive/image-7.png) | ![Large Preview](/img/dhive/image-8.png) |

---

## Notes

- Reblogging comments is not natively supported by Hive; custom behavior might be app-specific.
- Ensure `HiveFlutterKitPlatform` is properly initialized before use.

---

## Related

- [BlogScreen](/dhive/blog-screen.md)
- `Discussion` model
- `HiveFlutterKitPlatform`
- `ViewList` components

---
