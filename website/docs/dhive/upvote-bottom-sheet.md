---
title: UpvoteBottomSheet Widget
sidebar_label: UpvoteBottomSheet
slug: /dhive/upvote-bottom-sheet
---

# 👍 UpvoteBottomSheet Widget

The `UpvoteBottomSheet` widget provides a modal interface for viewing the list of voters on a Hive post or comment and allows the current user to upvote if they haven't already. It is designed to be used as a bottom sheet or dialog in your Flutter app.

---

## Features

- Displays a list of all voters with avatars and usernames
- Highlights the current user if they have voted
- Shows the total number of voters
- Allows the current user to upvote directly from the sheet (if not already voted)
- Handles login and duplicate vote checks
- Integrates with the `VoteDialog` for voting

---

## Screenshot

<!-- ![UpvoteBottomSheet Example](/img/dhive/upvote-bottom-sheet.png) -->

---

## Constructor

```dart
UpvoteBottomSheet({
  required HiveFlutterKitPlatform hfk,
  required List<String> voters,
  required bool currentUserPresentInVoters,
  required bool isContentVoted,
  required String currentUser,
  required dynamic postInfo,
  required String author,
  VoidCallback? onVoted,
})
```

## Parameters

| Parameter                    | Type                        | Required | Description                                                      |
|------------------------------|-----------------------------|----------|------------------------------------------------------------------|
| `hfk`                        | `HiveFlutterKitPlatform`    | ✅       | Hive blockchain service instance                                 |
| `voters`                     | `List<String>`              | ✅       | List of usernames who voted                                      |
| `currentUserPresentInVoters` | `bool`                      | ✅       | Whether the current user is in the voters list                   |
| `isContentVoted`             | `bool`                      | ✅       | Whether the current user has already voted                       |
| `currentUser`                | `String`                    | ✅       | Username of the current user                                     |
| `postInfo`                   | `dynamic`                   | ✅       | Post or comment info (should have `activeVotes` and `permlink`)  |
| `author`                     | `String`                    | ✅       | Author of the post or comment                                    |
| `onVoted`                    | `VoidCallback?`             | ❌       | Callback after a successful vote                                 |

---

## Usage Example

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => UpvoteBottomSheet(
    hfk: hiveFlutterKit,
    voters: votersList,
    currentUserPresentInVoters: votersList.contains(currentUser),
    isContentVoted: isVoted,
    currentUser: currentUser,
    postInfo: post,
    author: post.author,
    onVoted: () {
      // Refresh UI or fetch new vote data
    },
  ),
);
```

---

## Behavior

- The sheet displays a list of voters with avatars.
- If the current user is not logged in, trying to upvote will prompt a login message.
- If the user has already voted, a message is shown.
- If eligible, the user can upvote via a dialog.
- The current user's vote is highlighted in the list.

---

## Notes

- The widget expects `postInfo.activeVotes` to be a list of objects with a `voter` property.
- The upvote action uses a `VoteDialog` for confirmation and voting.
- Designed for integration with HiveFlutterKit voting and authentication flows.

---

## Related

- `VoteDialog`
- `HiveFlutterKitPlatform`
- [AccountPostsScreen](/dhive/account-posts-screen.md)
- [CommunityScreen](/dhive/community-screen.md)
- [UserProfilePicture](/dhive/user-profile-picture.md)

---
