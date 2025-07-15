---
title: 🧑‍💻 3Speak Current User Account
sidebar_label: 🧑‍💻 Current User Account
slug: /threespeak-current-user-account
---

# 🧑‍💻 3Speak Current User Account

The `ThreeSpeakCurrentUserAccount` widget is a comprehensive screen that displays the videos associated with the currently logged-in 3Speak user. It provides a tabbed interface to view videos that are ready to be published, already published videos, and videos that are currently being encoded.

---

<!-- ### Screenshot of the ThreeSpeakCurrentUserAccount Screen -->
<!-- (Leave space for screenshot here) -->

### Overview

`ThreeSpeakCurrentUserAccount` is a stateful widget that serves as a user's personal video management hub. It fetches and categorizes the user's videos from the 3Speak API and presents them in three distinct tabs:
-   **Publish Now**: Videos that have been uploaded and are ready for manual publishing.
-   **My Videos**: Videos that are already published on the blockchain.
-   **Encoding**: Videos that are currently in the 3Speak encoding pipeline.

### Usage Example

```dart
// String userToken = "user_3speak_jwt_token";
// String hiveUsername = "users_hive_username";

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ThreeSpeakCurrentUserAccount(
      token: userToken,
      username: hiveUsername,
      onPublish: (username, permlink) {
        // Handle publish action
      },
      onViewMyVideo: (username, permlink) {
        // Handle view video action
      },
      onLogout: () {
        // Handle logout
      },
    ),
  ),
);
```

### Widget Parameters

| Parameter                 | Type                    | Required | Description                                                                                                                                                             |
|---------------------------|-------------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `token`                   | `String?`               | ❌        | The JWT authentication token for the user. If null, the widget will display an error message.                                                                         |
| `username`                | `String`                | ✅        | The Hive username of the user.                                                                                                                                          |
| `onTabChanged`            | `OnTabChangedCallback?` | ❌        | A callback function that is triggered when the user switches between tabs.                                                                                              |
| `onLogout`                | `VoidCallback?`         | ❌        | A callback function for handling the logout action.                                                                                                                     |
| `onPublish`               | `OnPublishCallback?`    | ❌        | A callback for when the user taps the "Publish" button on a video in the "Publish Now" tab. It provides the `username` and `permlink` of the video.                      |
| `onViewMyVideo`           | `OnViewMyVideoCallback?`| ❌        | A callback for when the user taps the "View" button on a video in the "My Videos" tab. It provides the `username` and `permlink`.                                          |
| `onViewDetails`           | `OnViewDetailsCallback?`| ❌        | A callback for when the user taps the "Details" button on a video in the "Encoding" tab.                                                                                |
| `onMoreOptions`           | `OnMoreOptionsCallback?`| ❌        | A callback for when the user taps the more options icon on a video card. It provides the `videoId`.                                                                     |
| `onTapBackButton`         | `VoidCallback?`         | ❌        | A callback for handling the back button tap.                                                                                                                            |
| `shouldShowBackButton`    | `bool`                  | ❌        | Whether to show the back button in the app bar. Defaults to `true`.                                                                                                     |
| `shouldShowPublishButton` | `bool`                  | ❌        | Whether to show the "Publish" button for videos in the "Publish Now" tab. Defaults to `false`.                                                                          |

### Features

-   **📈 Tabbed Video Lists**: Organizes user videos into three categories for easy management.
-   **🔄 Pull-to-Refresh**: Users can refresh the video lists by pulling down.
-   **🖼️ Rich Video Cards**: Each video is displayed with its thumbnail, title, owner, and status.
-   **🎨 Status-Based Coloring**: The status of each video is highlighted with a color-coded tag.
-   **🎬 Action Buttons**: Provides context-aware buttons like "Publish," "View," and "Details" based on the video's status.
-   **🔐 Authentication Handling**: Gracefully handles cases where the authentication token is missing.
-   **⚠️ Error Display**: Shows a user-friendly error message if fetching videos fails, with a "Retry" button.
-   **🚪 Logout Functionality**: Includes a logout button in the app bar.
