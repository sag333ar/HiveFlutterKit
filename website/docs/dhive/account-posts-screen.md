---
title: AccountPostsScreen Widget
sidebar_label: AccountPostsScreen
slug: /dhive/account-posts-screen
---

# 🧑‍💻 AccountPostsScreen Widget

The `AccountPostsScreen` is a Flutter widget provided by the `hive_flutter_kit` package, designed to display a scrollable list of blog posts for a specific Hive blockchain user.

It provides a rich UI experience with optional interactions like tapping on authors, upvoting, commenting, or reblogging.

---

## Features

- Infinite scroll of posts by a Hive user
- Fully customizable callbacks for tap interactions
- Reusable and embeddable in any Flutter screen

---

## Constructor

```dart
AccountPostsScreen({
  Key? key,
  required HiveFlutterKitPlatform dhive,
  required String account,
  void Function(Discussion post)? onTap,
  void Function(String author)? onAuthorTap,
  void Function(String category)? onCategoryTap,
  void Function(Discussion post)? onUpvoteTap,
  void Function(Discussion post)? onCommentTap,
  void Function(Discussion post)? onReblogTap,
})
```

## Parameters

| Parameter       | Type                     | Required | Description                                 |
| --------------- | ------------------------ | -------- | ------------------------------------------- |
| `key`           | `Key?`                   | No       | Flutter widget key                          |
| `dhive`         | `HiveFlutterKitPlatform` | Yes      | The platform instance for Hive interactions |
| `account`       | `String`                 | Yes      | Hive username whose posts to load           |
| `onTap`         | `Function(Discussion)?`  | No       | Called when a post is tapped                |
| `onAuthorTap`   | `Function(String)?`      | No       | Called when author name or avatar is tapped |
| `onCategoryTap` | `Function(String)?`      | No       | Called when post category is tapped         |
| `onUpvoteTap`   | `Function(Discussion)?`  | No       | Called when upvote button is tapped         |
| `onCommentTap`  | `Function(Discussion)?`  | No       | Called when comment button is tapped        |
| `onReblogTap`   | `Function(Discussion)?`  | No       | Called when reblog button is tapped         |

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';

class MyFeedScreen extends StatelessWidget {
  final HiveFlutterKitPlatform dhive;
  final String accountName = "hivebuzz";

  const MyFeedScreen({super.key, required this.dhive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts by @$accountName"),
      ),
      body: AccountPostsScreen(
        dhive: dhive,
        account: accountName,
        onTap: (post) {
          print("Tapped on post: \${post.permlink}");
        },
        onAuthorTap: (author) {
          print("Tapped on author: \$author");
        },
        onCategoryTap: (category) {
          print("Tapped on category: \$category");
        },
        onUpvoteTap: (post) {
          print("Upvoted post: \${post.permlink}");
        },
        onCommentTap: (post) {
          print("Commented on post: \${post.permlink}");
        },
        onReblogTap: (post) {
          print("Reblogged post: \${post.permlink}");
        },
      ),
    );
  }
}
```

---

## Screenshots

| List View               | Grid View                 | Large Preview                 |
| ----------------------- | ------------------------- | ----------------------------- |
| ![List View](/img/dhive/image.png) | ![Grid View](/img/dhive/image-1.png) | ![Large Preview](/img/dhive/image-2.png) |

---

## Notes

- Ensure `HiveFlutterKitPlatform` is properly initialized before using this widget.
- Works best with a `Discussion` model as defined in your core Hive types.

---

## Related

- `ViewList`
- `ViewComments`
- `ViewMode` enum for layout types

---
