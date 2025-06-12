# TrendingFeedScreen

The `TrendingFeedScreen` widget displays a list of trending posts from the Hive blockchain. It uses infinite scrolling to fetch and render more posts dynamically and provides multiple callback hooks for user interactions such as voting, commenting, and reblogging.

---

## Features

* Displays trending discussions
* Infinite scrolling
* Customizable user interaction callbacks (tap, upvote, comment, etc.)

---

## Constructor

```dart
TrendingFeedScreen({
  Key? key,
  required HiveFlutterKitPlatform dhive,
  void Function(Discussion post)? onTap,
  void Function(String author)? onAuthorTap,
  void Function(String category)? onCategoryTap,
  void Function(Discussion post)? onUpvoteTap,
  void Function(Discussion post)? onCommentTap,
  void Function(Discussion post)? onReblogTap,
})
```

---

## Parameters

| Parameter       | Type                     | Required | Description                                   |
| --------------- | ------------------------ | -------- | --------------------------------------------- |
| `key`           | `Key?`                   | No       | Optional widget key                           |
| `dhive`         | `HiveFlutterKitPlatform` | Yes      | Hive platform instance used for API access    |
| `onTap`         | `Function(Discussion)?`  | No       | Called when a post is tapped                  |
| `onAuthorTap`   | `Function(String)?`      | No       | Called when an author's name/avatar is tapped |
| `onCategoryTap` | `Function(String)?`      | No       | Called when the category tag is tapped        |
| `onUpvoteTap`   | `Function(Discussion)?`  | No       | Called when the upvote icon is tapped         |
| `onCommentTap`  | `Function(Discussion)?`  | No       | Called when the comment icon is tapped        |
| `onReblogTap`   | `Function(Discussion)?`  | No       | Called when the reblog icon is tapped         |

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';

class MyTrendingScreen extends StatelessWidget {
  final HiveFlutterKitPlatform dhive;

  const MyTrendingScreen({super.key, required this.dhive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trending Feed")),
      body: TrendingFeedScreen(
        dhive: dhive,
        onTap: (discussion) {
          print("Post tapped: @\${discussion.author}/\${discussion.permlink}");
        },
        onAuthorTap: (author) {
          print("Author tapped: \$author");
        },
        onCommentTap: (discussion) {
          print("Comment tapped on post by: @\${discussion.author}");
        },
        // Add other callbacks as needed
      ),
    );
  }
}

// Example main
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final dhive = await HiveFlutterKit.platform.initialize(...);
//   runApp(MaterialApp(home: MyTrendingScreen(dhive: dhive)));
// }
```

---

## Screenshots

| List View                         | Grid View                         | Large Preview                         |
| --------------------------------- | --------------------------------- | ------------------------------------- |
| ![List View](trending-feed-1.png) | ![Grid View](trending-feed-2.png) | ![Large Preview](trending-feed-3.png) |

---

## Notes

* Ensure that `HiveFlutterKitPlatform` is fully initialized before rendering the widget.
* Trending data is subject to change frequently as new content is posted.

---

## Related

* `CommunityScreen`
* `RepliesScreen`
* `Discussion` model
* `HiveFlutterKitPlatform`
* `UserProfilePicture`, `ViewList` components
