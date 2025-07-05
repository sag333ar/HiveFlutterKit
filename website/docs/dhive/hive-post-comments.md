---
title: 📝 💬 Hive Post Comments
sidebar_label: 📝 💬 Hive Post Comments
slug: /dhive/hive-post-comments
---

# 📝 💬 Hive Post Comments

The `HivePostComments` widget provides a full-featured comment thread and reply interface for any Hive post or video. It supports viewing, searching, replying, and upvoting comments, and is designed for seamless integration into video players, post detail screens, or as a standalone comment section.

---

## Screenshot

![CommunityListScreenshot](/img/dhive/image-16.png)

---

## Features

- View the full comment thread for a Hive post or video
- Search/filter comments
- Post new comments and replies
- Upvote comments
- Refresh the comment list
- Nested/threaded replies
- Loading, error, and empty states

---

## Constructor

```dart
HivePostComments({
  required String author,
  required String permlink,
  void Function(String body)? onComment,
  void Function(Discussion comment)? onUpvoteComment,
  void Function(Discussion comment)? onReplyComment,
})
```

## Parameters

| Parameter           | Type                                 | Required | Description                                 |
|---------------------|--------------------------------------|----------|---------------------------------------------|
| `author`            | `String`                             | ✅       | The author of the post or video             |
| `permlink`          | `String`                             | ✅       | The permlink of the post or video           |
| `onComment`         | `void Function(String body)?`        | ❌       | Callback when a new comment is posted       |
| `onUpvoteComment`   | `void Function(Discussion)?`         | ❌       | Callback when a comment is upvoted          |
| `onReplyComment`    | `void Function(Discussion)?`         | ❌       | Callback when a reply is posted             |

---

## Usage Example

```dart
HivePostComments(
  author: 'demo-user',
  permlink: 'my-video-post',
  onComment: (body) => print("New comment: $body"),
  onUpvoteComment: (comment) => print("Upvoted comment"),
  onReplyComment: (comment) => print("Replied to comment"),
)
```

---

## UI & Behavior

- **AppBar**: Shows total comment count, back button, and search icon
- **Comment List**: Scrollable, refreshable, supports nested replies
- **Add Comment Button**: Visible for logged-in users
- **Loading/Error/Empty States**: Loader, retry, and "No Results" messages

---

## Comment Posting Flow

```dart
_showCommentInput() → _addComment() → hfk.comment(...) → _fetchComments()
```

---

DHive's - Communities List

## Related

- `CommentTile`
- `CommentSearchBar`
- `HiveFlutterKitPlatform`
- `Discussion` model

---

## Notes

- Designed for both anonymous and authenticated users
- Can be embedded in a bottom sheet, modal, or full screen
- Supports deep linking to specific comments (with custom logic)

---
