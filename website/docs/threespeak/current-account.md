---
title: Current User Account
sidebar_label: Current User Account
slug: /current-account
---

# Current User Account

### Pusblish Videos
![List View](/img/threespeak/image-3.png)

### My Videos
![Grid View](/img/threespeak/image-4.png)

### Encoding Video
![Large Preview](/img/threespeak/image-5.png)

A Flutter widget for displaying and managing the current user's 3Speak account, including video publishing, viewing, and encoding status. The `ThreeSpeakCurrentUserAccount` provides a tabbed interface for "Publish Now", "My Videos", and "Encoding" video lists, with actions for each video and account management.

## Overview

The `ThreeSpeakCurrentUserAccount` is a stateful widget that fetches the user's videos from the 3Speak API and organizes them into three categories:
- **Publish Now**: Videos ready to be published.
- **My Videos**: Videos already published.
- **Encoding**: Videos that are uploaded but still being processed.

It also provides user profile display, logout, and callback hooks for various actions.

---

## Usage Example

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ThreeSpeakCurrentUserAccount(
      token: 'your-auth-token',
      username: 'your-hive-username',
      onTabChanged: (tabIndex) {
        debugPrint('Tab changed: $tabIndex');
      },
      onLogout: () {
        debugPrint('User logged out');
      },
      onPublish: (username, permlink) {
        debugPrint('Publish video: $username/$permlink');
      },
      onViewMyVideo: (username, permlink) {
        debugPrint('View my video: $username/$permlink');
      },
      onViewDetails: (username, permlink) {
        debugPrint('View details: $username/$permlink');
      },
      onMoreOptions: (videoId) {
        debugPrint('More options for video: $videoId');
      },
      onTapBackButton: () {
        Navigator.of(context).pop();
      },
    ),
  ),
);
```

## Widget Parameters

| Parameter            | Type                                              | Required | Description                                                                                 |
|----------------------|---------------------------------------------------|----------|---------------------------------------------------------------------------------------------|
| `token`              | `String`                                          | ✅        | Authentication token for the 3Speak API.                                                    |
| `username`           | `String`                                          | ✅        | Hive username of the current user.                                                          |
| `onTabChanged`       | `void Function(int)?`                             | ❌        | Callback when the tab is changed (0: Publish Now, 1: My Videos, 2: Encoding).               |
| `onLogout`           | `VoidCallback?`                                   | ❌        | Callback when the logout button is pressed.                                                 |
| `onPublish`          | `void Function(String username, String permlink)?`| ❌        | Callback when the "Publish" button is pressed in the "Publish Now" tab.                     |
| `onViewMyVideo`      | `void Function(String username, String permlink)?`| ❌        | Callback when the "View My Video" button is pressed in the "My Videos" tab.                 |
| `onViewDetails`      | `void Function(String username, String permlink)?`| ❌        | Callback when the "View Details" button is pressed in the "Encoding" tab.                   |
| `onMoreOptions`      | `void Function(String videoId)?`                  | ❌        | Callback when the "More options" button is pressed for a video.                             |
| `onTapBackButton`    | `VoidCallback?`                                   | ❌        | Callback when the back button in the app bar is pressed.                                    |

## Features

### 👤 User Profile Display
- Shows the user's profile image and username in the app bar.

### 🗂️ Tabbed Video Management
- **Publish Now**: List of videos ready to be published, with a "Publish" button.
- **My Videos**: List of published videos, with a "View My Video" button.
- **Encoding**: List of videos being processed, with a "View Details" button.

### 🔄 Refresh & Loading
- Fetches video lists from the 3Speak API on load.
- Shows a loading indicator while fetching data.
- Displays "No videos found" if a tab is empty.

### ⚡ Actions & Callbacks
- Each video row provides action buttons for publish/view/details/more options.
- All actions are customizable via callbacks.

### 🔒 Logout
- Logout button in the app bar triggers the provided callback.

---

## Example Flow

1. User opens the account screen.
2. The widget fetches and displays videos in three tabs.
3. User can publish, view, or check details of their videos.
4. User can logout or go back using the app bar buttons.

---

## See Also

- [VideoUploadScreen](/threespeak/video-upload.md)
- [VideoPlayerScreen](/threespeak/video-player.md)
- [ThreeSpeakVideoFeed](/threespeak/video-feed.md)
