---
title: TrendingFeedScreen Widget
sidebar_label: TrendingFeedScreen
slug: /dhive/trending-feed-screen
---

# 🔥 TrendingFeedScreen Widget

The `TrendingFeedScreen` widget displays a feed of trending posts from the Hive blockchain. It is ideal for showing the most popular or upvoted content, and supports infinite scrolling, sorting, and user interaction callbacks.

---

## Features

- Shows trending posts from Hive
- Infinite scroll for continuous content loading
- Sorting options (e.g., trending, hot, created)
- Tap, upvote, comment, and reblog callbacks
- Customizable UI for integration in any Flutter app

---

## Constructor

```dart
TrendingFeedScreen({
  Key? key,
  required HiveFlutterKitPlatform hfk,
  String sortBy = "trending",
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
| `hfk`         | `HiveFlutterKitPlatform` | Yes      | Hive platform instance for API access       |
| `sortBy`        | `String`                 | No       | Sort method (default: "trending")           |
| `onTap`         | `Function(Discussion)?`  | No       | Called when a post is tapped                |
| `onAuthorTap`   | `Function(String)?`      | No       | Called when author name/avatar is tapped    |
| `onCategoryTap` | `Function(String)?`      | No       | Called when post category is tapped         |
| `onUpvoteTap`   | `Function(Discussion)?`  | No       | Called when upvote icon is tapped           |
| `onCommentTap`  | `Function(Discussion)?`  | No       | Called when comment icon is tapped          |
| `onReblogTap`   | `Function(Discussion)?`  | No       | Called when reblog icon is tapped           |

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';

class MyTrendingFeedScreen extends StatelessWidget {
  final HiveFlutterKitPlatform hfk;

  const MyTrendingFeedScreen({super.key, required this.hfk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trending Posts"),
      ),
      body: TrendingFeedScreen(
        hfk: hfk,
        sortBy: "trending",
        onTap: (Discussion post) {
          print("Tapped on post: @\${post.author}/\${post.permlink}");
        },
        onAuthorTap: (String author) {
          print("Tapped on author: \$author");
        },
      ),
    );
  }
}
```

---

## Screenshots

| List View                 | Grid View                  | Large Preview                  |
| ------------------------- | -------------------------- | ------------------------------ |
| ![List View](/img/dhive/image-16.png) | ![Grid View](/img/dhive/image-17.png) | ![Large Preview](/img/dhive/image-18.png) |

---

## Notes

- Ensure `HiveFlutterKitPlatform` is properly initialized before rendering the screen.
- Sorting options may include "trending", "hot", "created", etc.

---

## Related

- [CommunityScreen](/dhive/community-screen.md)
- [BlogScreen](/dhive/blog-screen.md)
- [AccountPostsScreen](/dhive/account-posts-screen.md)
- `Discussion` model
- `HiveFlutterKitPlatform`
- `ViewList` components

---
