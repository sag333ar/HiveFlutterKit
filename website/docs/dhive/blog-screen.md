---
title: 👤 📕 DHive - User's Blog
sidebar_label: 👤 📕 Blog
slug: /dhive/blog-screen
---

# 👤 📕 DHive - User's Blog

The `BlogScreen` is a Flutter widget provided by the `hive_flutter_kit` package, used to display a scrollable list of blog entries (original posts and reblogs) from a Hive blockchain account.

It offers a familiar "blog" format of content display, complete with infinite scrolling and several interaction points for developers to hook into.

---

## Screenshots

### List View
![List View](/img/dhive/image-3.png)

### Grid View
![Grid View](/img/dhive/image-4.png)

### Large Preview
![Large Preview](/img/dhive/image-5.png)


---

## Features

- Displays original posts and reblogs
- Infinite scrolling support
- Customizable interaction callbacks
- Easy integration with existing Flutter views

---

## Constructor

```dart
BlogScreen({
  Key? key,
  required HiveFlutterKitPlatform hfk,
  required String account,
  void Function(Discussion blogEntry)? onTap,
  void Function(String author)? onAuthorTap,
  void Function(String category)? onCategoryTap,
  void Function(Discussion blogEntry)? onUpvoteTap,
  void Function(Discussion blogEntry)? onCommentTap,
  void Function(Discussion blogEntry)? onReblogTap,
})
```

## Parameters

| Parameter       | Type                     | Required | Description                              |
| --------------- | ------------------------ | -------- | ---------------------------------------- |
| `key`           | `Key?`                   | No       | Flutter widget key                       |
| `hfk`         | `HiveFlutterKitPlatform` | Yes      | Hive platform instance                   |
| `account`       | `String`                 | Yes      | Hive account username                    |
| `onTap`         | `Function(Discussion)?`  | No       | Called when a blog entry is tapped       |
| `onAuthorTap`   | `Function(String)?`      | No       | Called when author name/avatar is tapped |
| `onCategoryTap` | `Function(String)?`      | No       | Called when blog category is tapped      |
| `onUpvoteTap`   | `Function(Discussion)?`  | No       | Called when upvote icon is tapped        |
| `onCommentTap`  | `Function(Discussion)?`  | No       | Called when comment icon is tapped       |
| `onReblogTap`   | `Function(Discussion)?`  | No       | Called when reblog icon is tapped        |

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';

class MyBlogDisplayScreen extends StatelessWidget {
  final HiveFlutterKitPlatform hfk;
  final String accountName = "ecency";

  const MyBlogDisplayScreen({super.key, required this.hfk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blog of @$accountName"),
      ),
      body: BlogScreen(
        hfk: hfk,
        account: accountName,
        onTap: (blogEntry) {
          print("Tapped on blog entry: \${blogEntry.permlink}");
          if (blogEntry.rebloggedBy != null && blogEntry.rebloggedBy!.isNotEmpty) {
            print("Reblogged by: \${blogEntry.rebloggedBy!.join(', ')}");
          }
        },
        onAuthorTap: (author) {
          print("Tapped on author: \$author");
        },
        onCategoryTap: (category) {
          print("Tapped on category: \$category");
        },
        onUpvoteTap: (entry) {
          print("Upvoted: \${entry.permlink}");
        },
        onCommentTap: (entry) {
          print("Commented: \${entry.permlink}");
        },
        onReblogTap: (entry) {
          print("Reblogged: \${entry.permlink}");
        },
      ),
    );
  }
}
```

---

## Notes

- Ensure the `HiveFlutterKitPlatform` is initialized before passing to `BlogScreen`.
- Useful for profile-style content feeds or public blog viewers.

---

## Related

- [AccountPostsScreen](/dhive/account-posts-screen.md)
- `Discussion` model
- `HiveFlutterKitPlatform`
- `ViewList` components

---
