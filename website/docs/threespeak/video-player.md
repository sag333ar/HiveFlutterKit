---
title: Video Player
sidebar_label: Video Player
slug: /video-player
---

# Video Player Screen Component

![User Feed Preview](/img/threespeak/videoplayer.png)

A Flutter video player component, is designed for 3Speak Video. which is published on hive, that provides adaptive layouts for mobile and desktop/web platforms, with integrated user interaction features.

## Overview

The `VideoPlayerScreen` is a stateful widget that combines video playback capabilities with social features like voting, user authentication, and post information display. It automatically adapts its layout based on screen size and handles IPFS video URL resolution.

## Usage Example

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VideoPlayerScreen(
      item: item, // GQLFeedItem instance containing all necessary data for the video post
      // ✅ Optional Callbacks
      onTapComment: (author, permlink) {
        debugPrint('User tapped on comment button below video for $author/$permlink');
      },
      onTapUpvote: (author, permlink) {
        debugPrint('User tapped on upvote button below video for $author/$permlink');
      },
      onTapShare: (author, permlink) {
        debugPrint('User tapped on share button below video for $author/$permlink');
      },
      onTapBookmark: (author, permlink) {
        debugPrint('User tapped on bookmark button below video for $author/$permlink');
      },
      onTapAuthor: (author) {
        debugPrint('User tapped on author $author');
      },
      onTapInfo: (author, permlink) {
        debugPrint('User tapped on info button for post $author/$permlink');
      },
    ),
  ),
);
```


## Widget Parameters

| Parameter        | Type                                        | Required | Description                                                                                   |
|------------------|---------------------------------------------|----------|-----------------------------------------------------------------------------------------------|
| `item`           | `GQLFeedItem`                               | ✅        | Complete feed item data to render the video card UI.                                          |
| `onTapComment`   | `void Function(String author, String permlink)?`   | ❌        | Called when the comment button is tapped. Use this to navigate to or open the comment section of the post. |
| `onTapUpvote`    | `void Function(String author, String permlink)?`   | ❌        | Called when the upvote button is tapped. Use this to trigger your custom upvote logic.        |
| `onTapShare`     | `void Function(String author, String permlink)?`   | ❌        | Called when the share button is tapped. Useful for invoking your custom share functionality.  |
| `onTapBookmark`  | `void Function(String author, String permlink)?`   | ❌        | Called when the bookmark button is tapped. Use this to save or unsave the post in your system. |
| `onTapAuthor`    | `void Function(String username)?`                 | ❌        | Called when the author's name or avatar is tapped. Use this to navigate to the author's profile. |
| `onTapInfo`      | `void Function(String author, String permlink)?`   | ❌        | Called when the info/details button is tapped. Useful for showing additional metadata or options related to the post. |


## Features

### 🎥 Video Playback
- Supports HLS streaming with adaptive bitrate
- IPFS URL resolution with platform-specific optimization
- Auto-play functionality with full-screen support
- Aspect ratio maintained at 16:9

### 📱 Responsive Layout
- **Mobile Layout**: Stacked video player and info panel
- **Desktop/Web Layout**: Centered video player with wider container (1600px max width)
- Automatic layout switching at 800px breakpoint

### 🔁 Resolution Strategy
- **Web**: Uses manifest.m3u8 for adaptive streaming
- **Android**: Uses 480p/index.m3u8 for optimized mobile playback
- **Other platforms**: Defaults to manifest.m3u8

