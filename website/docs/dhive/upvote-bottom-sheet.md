---
title: 📝 👍 Upvote BottomSheet
sidebar_label: 📝 👍Upvote BottomSheet
slug: /dhive/upvote-bottom-sheet
---

# 📝 👍 Upvote BottomSheet

The `UpvoteBottomSheet` widget provides a modal interface for viewing the list of voters on a Hive post or comment and allows the current user to upvote if they haven't already. It is designed to be used as a bottom sheet or dialog in your Flutter app.

---

## Screenshots
![Upvote BottomSheet](/img/dhive/upvote-bottomsheet.png)

## Features

- Displays a list of all voters with avatars and usernames
- Highlights the current user if they have voted
- Shows the total number of voters
- Allows the current user to upvote directly from the sheet (if not already voted)
- Handles login and duplicate vote checks
- Integrates with the `VoteDialog` for voting
- Supports a custom upvote callback (`onClickUpvote`) for advanced use cases

---

## Constructor

```dart
UpvoteBottomSheet({
  required HiveFlutterKitPlatform hfk,
  required String author,
  required String permlink,
  required bool isContentVoted,
  required String currentUser,
  VoidCallback? onVoted,
  VoidCallback? onClickUpvote,
})
```

## Parameters

| Parameter         | Type                      | Required | Description                                                      |
|------------------ |--------------------------|----------|------------------------------------------------------------------|
| `hfk`             | `HiveFlutterKitPlatform` | ✅       | Hive blockchain service instance                                 |
| `author`          | `String`                 | ✅       | Author of the post or comment                                    |
| `permlink`        | `String`                 | ✅       | Permlink of the post or comment                                  |
| `isContentVoted`  | `bool`                   | ✅       | Whether the current user has already voted                       |
| `currentUser`     | `String`                 | ✅       | Username of the current user                                     |
| `onVoted`         | `VoidCallback?`          | ❌       | Callback after a successful vote                                 |
| `onClickUpvote`   | `VoidCallback?`          | ❌       | Custom callback for upvote button; if not set, shows VoteDialog  |

---

## Usage Example

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => UpvoteBottomSheet(
    hfk: hiveFlutterKit,
    author: post.author,
    permlink: post.permlink,
    isContentVoted: isVoted,
    currentUser: currentUser,
    onVoted: () {
      // Refresh UI or fetch new vote data
    },
    onClickUpvote: () {
      // Custom upvote logic (optional)
      print('Upvote button pressed!');
    },
  ),
);
```

---

## Behavior

- The sheet displays a list of voters with avatars and vote details.
- If the current user is not logged in, trying to upvote will prompt a login message.
- If the user has already voted, a message is shown.
- If eligible, the user can upvote via a dialog or a custom callback.
- The current user's vote is highlighted in the list.

---

## Workflow

1. User opens the bottom sheet to view voters.
2. If the user is not logged in, upvote prompts a login message.
3. If the user has already voted, a message is shown.
4. If the user is eligible and `onClickUpvote` is provided, it is called when the upvote button is pressed.
5. If `onClickUpvote` is not provided, the default `VoteDialog` is shown for voting.
6. After a successful vote, the `onVoted` callback (if provided) is called.

---

## Notes

- The widget fetches the list of voters using `hfk.getActiveVotes`.
- The upvote action uses a `VoteDialog` for confirmation and voting unless a custom `onClickUpvote` is provided.
- Designed for integration with HiveFlutterKit voting and authentication flows.
- The widget is responsive and works well in both mobile and desktop layouts.

---

## Customization

- Use the `onClickUpvote` callback to provide a custom upvote flow (e.g., show a custom dialog, analytics, etc.).
- Use the `onVoted` callback to refresh UI or fetch new vote data after a successful vote.

---

## Related

- `VoteDialog`
- `HiveFlutterKitPlatform`
- [AccountPostsScreen](/dhive/account-posts-screen.md)
- [CommunityScreen](/dhive/community-screen.md)
- [UserProfilePicture](/dhive/user-profile-picture.md)
