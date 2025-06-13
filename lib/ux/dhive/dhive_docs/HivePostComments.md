# HivePostComments Widget Documentation

This document explains the `HivePostComments` screen widget, used for displaying and interacting with comments on a specific Hive video or Hive post.

---

## 🎯 Purpose

The `HivePostComments` widget allows users to:

* View the full comment thread on a video post
* Search through comments
* Post new comments or replies
* Upvote comments
* Refresh the comment list

It connects to the Hive blockchain using `HiveFlutterKitPlatform` and supports both anonymous viewers and authenticated users.

---

## 🧱 Main Components

### Parameters

| Name              | Type                                 | Description                            |
| ----------------- | ------------------------------------ | -------------------------------------- |
| `author`          | `String`                             | The author of the video post           |
| `permlink`        | `String`                             | The unique permlink for the video post |
| `onComment`       | `void Function(String body)?`        | Optional external comment handler      |
| `onUpvoteComment` | `void Function(Discussion comment)?` | Optional external upvote handler       |
| `onReplyComment`  | `void Function(Discussion comment)?` | Optional external reply handler        |

### Internal State

* `_comments`: List of `Discussion` objects fetched from Hive
* `_currentUser`: Logged-in Hive username ()
* `_loading`: Indicates if data is being loaded
* `_error`: Indicates fetch failure

---

## 🔄 Lifecycle Methods

### `initState()`

* Loads the current user from secure storage
* Fetches the comment list using `hfk.getCommentsList()`

---

## 📤 Features & Logic

### Comment Fetching

```dart
final comments = await hfk.getCommentsList(widget.author, widget.permlink);
```

### Add New Comment

* Opens a bottom sheet for input
* Uses `hfk.comment(...)` to publish to the blockchain
* Automatically refreshes the list after publishing

### Comment Thread Filtering

* Top-level comments are displayed
* Replies are nested within their respective top-level items using the `CommentTile`

### Search

* `CommentSearchBar` allows live filtering of comment text

---

## 💬 UI Components

### AppBar

* Shows total comment count
* Has a back button and search icon

### Comment List

* Displays a scrollable, refreshable list
* Uses `ScrollablePositionedList` for fine-grained control and reply navigation

### Empty / Error / Loading States

* Circular loader during fetch
* Error message and retry button on failure
* "No Results Found" if filter returns empty

### Add Comment Button

* Shows only for logged-in users
* Positioned at the bottom using `bottomNavigationBar`

---

## 🔄 Comment Posting Flow

```dart
_showCommentInput() → _addComment() → hfk.comment(...) → _fetchComments()
```

---

## 🧩 Dependencies

* `HiveFlutterKitPlatform`
* `CommentSearchBar`
* `CommentTile`
* `flutter_secure_storage`
* `scrollable_positioned_list`

---

## 📦 Integration Example

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

## 📎 Related Widgets & Files

* `CommentTile`
* `CommentSearchBar`
* `HiveFlutterKitPlatform`
* `Discussion` model
* `lib/screens/comments/comments_screen.dart`

---

## 📝 Improvements

* Add support for threaded reply nesting
* Support rich text or markdown in input field
* Scroll to newly added comment

---

For usage within a video player or full-screen feed, this widget can be embedded in a bottom sheet or separate route.
