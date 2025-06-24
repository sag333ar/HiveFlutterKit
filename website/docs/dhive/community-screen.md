---
title: DHive's - Community
sidebar_label: Community
slug: /dhive/community-screen
---

# 🏠 DHive's - Community

The `CommunityScreen` widget provides a way to display a feed of posts ("discussions") based on a specific tag, often used to show content from a particular Hive community or posts related to a certain topic. It allows sorting these posts by various criteria (e.g., trending, created, hot). The widget includes features like infinite scrolling for loading more posts and provides callbacks for common user interactions.

---

## Screenshots

### List View
![List View](/img/dhive/image-9.png)

### Grid View
![Grid View](/img/dhive/image-10.png)

### Large Preview
 ![Large Preview](/img/dhive/image-11.png)


---

## Features

- Displays discussions based on a tag or community
- Supports sort options (trending, hot, created, etc.)
- Infinite scrolling
- Interaction callbacks for tap, vote, comment, and reblog

---

## Constructor

```dart
CommunityScreen({
  Key? key,
  required HiveFlutterKitPlatform hfk,
  required String tag,
  required String sortBy,
  void Function(Discussion post)? onTap,
  void Function(String author)? onAuthorTap,
  void Function(String category)? onCategoryTap,
  void Function(Discussion post)? onUpvoteTap,
  void Function(Discussion post)? onCommentTap,
  void Function(Discussion post)? onReblogTap,
})
```

## Parameters

| Parameter       | Type                     | Required | Description                                |
| --------------- | ------------------------ | -------- | ------------------------------------------ |
| `key`           | `Key?`                   | No       | Flutter widget key                         |
| `hfk`         | `HiveFlutterKitPlatform` | Yes      | Hive platform instance for API access      |
| `tag`           | `String`                 | Yes      | Community tag or topic to fetch posts from |
| `sortBy`        | `String`                 | Yes      | Sort method (e.g., trending, hot, created) |
| `onTap`         | `Function(Discussion)?`  | No       | Called when a post is tapped               |
| `onAuthorTap`   | `Function(String)?`      | No       | Called when author name/avatar is tapped   |
| `onCategoryTap` | `Function(String)?`      | No       | Called when post category is tapped        |
| `onUpvoteTap`   | `Function(Discussion)?`  | No       | Called when upvote icon is tapped          |
| `onCommentTap`  | `Function(Discussion)?`  | No       | Called when comment icon is tapped         |
| `onReblogTap`   | `Function(Discussion)?`  | No       | Called when reblog icon is tapped          |

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';

class MyCommunityFeedScreen extends StatelessWidget {
  final HiveFlutterKitPlatform hfk;
  final String communityTag = "hive-125125";
  final String sortOrder = "trending";

  const MyCommunityFeedScreen({super.key, required this.hfk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trending in \$communityTag"),
      ),
      body: CommunityScreen(
        hfk: hfk,
        tag: communityTag,
        sortBy: sortOrder,
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

// main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final hfk = await HiveFlutterKit.platform.initialize(...);
//   runApp(MaterialApp(home: MyCommunityFeedScreen(hfk: hfk)));
// }
```

---

## Notes

- Ensure `HiveFlutterKitPlatform` is properly initialized before rendering the screen.
- Sorting behavior may differ depending on Hive API support for specific sort types.

---

## Related

- [AccountPostsScreen](/dhive/account-posts-screen.md)
- [BlogScreen](/dhive/blog-screen.md)
- [Comments](/dhive/comments-screen.md)
- [Replies](/dhive/replies-screen.md)
- [CommunitiesList](/dhive/communities-list.md)
- `Discussion` Model
- `CommunityItem` Model

---
