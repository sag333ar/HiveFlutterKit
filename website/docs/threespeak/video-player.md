---
title: Video Player
sidebar_label: Video Player
slug: /video-player
---

# Video Player Screen Component

![Video Player Preview](/img/threespeak/videoplayer.png)

A comprehensive Flutter video player screen, specifically designed for 3Speak videos published on the Hive blockchain. It features adaptive layouts for mobile and web/desktop, integrates video playback with Hive post information (like votes and comments), and allows for a related video feed display.

## Overview

The `VideoPlayerScreen` is a stateful widget that provides a rich user experience for watching 3Speak videos. It handles:
-   Fetching video details if only `author` and `permlink` are provided.
-   Initializing and controlling video playback using `chewie` and `video_player`.
-   Resolving IPFS video URLs with platform-specific optimizations.
-   Fetching associated Hive post information (e.g., vote counts, current user's vote status) using `HiveFlutterKitPlatform`.
-   Displaying video metadata and engagement actions through an internal `VideoInfo` widget.
-   Dynamically adjusting its layout for optimal viewing on different screen sizes.
-   Displaying a customizable feed of related videos beneath the player.

## Initialization

You can initialize `VideoPlayerScreen` in two ways:

1.  **With `GQLFeedItem`**: Provide a complete `item` object (typically obtained from a `ThreeSpeakVideoFeed`).
    ```dart
    VideoPlayerScreen(
      item: yourGQLFeedItem,
      onTapBackButton: () => Navigator.of(context).pop(),
      videoFeed: () => ThreeSpeakVideoFeed(
        feedType: ThreeSpeakVideoFeedType.related,
        relatedAuthor: yourGQLFeedItem.author?.username,
        relatedPermlink: yourGQLFeedItem.permlink,
        // ... other necessary callbacks for ThreeSpeakVideoFeed
      ),
      // ... other optional callbacks
    )
    ```

2.  **With `author` and `permlink`**: Provide the Hive `author` and `permlink` of the video post. The widget will then fetch the `GQLFeedItem` data itself.
    ```dart
    VideoPlayerScreen(
      author: "someauthor",
      permlink: "somepermlink",
      onTapBackButton: () => Navigator.of(context).pop(),
      videoFeed: () => ThreeSpeakVideoFeed(
        feedType: ThreeSpeakVideoFeedType.related,
        relatedAuthor: "someauthor",
        relatedPermlink: "somepermlink",
        // ... other necessary callbacks for ThreeSpeakVideoFeed
      ),
      // ... other optional callbacks
    )
    ```

> **Assertion**: The widget asserts that you must provide *either* a `item` (GQLFeedItem) *or* both `author` and `permlink`, but not both sets of parameters.

---

## Usage Example

```dart
// Assuming 'tappedItem' is a GQLFeedItem from a feed
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VideoPlayerScreen(
      item: tappedItem, // Or use author & permlink
      shouldShowBackButton: true,
      onTapBackButton: () {
        Navigator.of(context).pop();
      },
      videoFeed: () {
        // This function should return a widget, typically another ThreeSpeakVideoFeed
        // configured to show related videos.
        return ThreeSpeakVideoFeed(
          feedType: ThreeSpeakVideoFeedType.related,
          relatedAuthor: tappedItem.author?.username,
          relatedPermlink: tappedItem.permlink,
          onTapVideoItem: (relatedItem) {
            // Example: Push a new VideoPlayerScreen for the related item
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  item: relatedItem,
                  shouldShowBackButton: true,
                  onTapBackButton: () => Navigator.of(context).pop(),
                  videoFeed: () { /* ... configure related feed for this new item ... */ },
                ),
              ),
            );
          },
          // Provide all required callbacks for ThreeSpeakVideoFeed
          onTapAuthor: (item) => debugPrint('Author tapped: ${item.author}'),
          onTapReport: (item) => debugPrint('Report tapped: ${item.permlink}'),
          onTapUpvote: (item) => debugPrint('Upvote tapped: ${item.permlink}'),
          onTapComment: (item) => debugPrint('Comment tapped: ${item.permlink}'),
        );
      },
      // Optional callbacks for actions on the main video's info panel:
      onTapComment: (author, permlink) {
        debugPrint('Main video comment: $author/$permlink');
        // Implement navigation to comments section or show a comment dialog
      },
      onTapUpvote: (author, permlink) {
        debugPrint('Main video upvote: $author/$permlink');
        // Implement upvote logic
      },
      onTapShare: (author, permlink) {
        debugPrint('Main video share: $author/$permlink');
        // Implement share functionality
      },
      onTapBookmark: (author, permlink) {
        debugPrint('Main video bookmark: $author/$permlink');
        // Implement bookmark logic
      },
      onTapAuthor: (username) {
        debugPrint('Main video author tapped: $username');
        // Navigate to author's profile
      },
      onTapInfo: (author, permlink) {
        debugPrint('Main video info tapped: $author/$permlink');
        // Show more details or metadata
      },
    ),
  ),
);
```

---

## Widget Parameters

| Parameter             | Type                                                      | Required | Description                                                                                                                                    |
|-----------------------|-----------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------|
| `item`                | `GQLFeedItem?`                                            | Cond.    | Complete feed item data. Provide this OR `author` & `permlink`.                                                                                  |
| `author`              | `String?`                                                 | Cond.    | The author of the video post. Required if `item` is not provided.                                                                                |
| `permlink`            | `String?`                                                 | Cond.    | The permlink of the video post. Required if `item` is not provided.                                                                              |
| `onTapBackButton`     | `VoidCallback`                                            | ✅        | Callback for the AppBar's back button. Typically `Navigator.of(context).pop()`.                                                                  |
| `shouldShowBackButton`| `bool`                                                    | ✅        | If `true`, displays a back button in the AppBar.                                                                                               |
| `videoFeed`           | `ThreeSpeakVideoFeed Function()`                          | ✅        | A function that returns a widget (usually a `ThreeSpeakVideoFeed`) to display related or suggested videos below the main player and info panel.    |
| `onTapComment`        | `void Function(String author, String permlink)?`          | ❌        | Called when the comment button in the `VideoInfo` panel is tapped.                                                                               |
| `onTapUpvote`         | `void Function(String author, String permlink)?`          | ❌        | Called when the upvote button in the `VideoInfo` panel is tapped.                                                                                |
| `onTapShare`          | `void Function(String author, String permlink)?`          | ❌        | Called when the share button in the `VideoInfo` panel is tapped.                                                                                 |
| `onTapBookmark`       | `void Function(String author, String permlink)?`          | ❌        | Called when the bookmark button in the `VideoInfo` panel is tapped.                                                                              |
| `onTapAuthor`         | `void Function(String username)?`                         | ❌        | Called when the author's name/avatar in the `VideoInfo` panel is tapped.                                                                         |
| `onTapInfo`           | `void Function(String author, String permlink)?`          | ❌        | Called when an info/details button in the `VideoInfo` panel is tapped.                                                                           |

*Cond.* = Conditionally Required.

---

## Features

### 🎬 Advanced Video Playback
-   Utilizes `chewie` for a full-featured video player UI (controls, fullscreen, etc.).
-   Supports HLS streaming.
-   **IPFS URL Resolution**: Automatically resolves `ipfs://` URLs to a public gateway (`https://ipfs-3speak.b-cdn.net/ipfs/`).
    -   **Web**: Uses `manifest.m3u8` for adaptive streaming.
    -   **Android**: Optimizes by attempting to use `480p/index.m3u8`.
    -   **Other Platforms**: Defaults to `manifest.m3u8`.
-   Auto-plays video on initialization.
-   Maintains a 16:9 aspect ratio for the player.

### 💬 Hive Integration & Social Features
-   **Post Information**: Fetches and displays Hive post details (`Discussion` object from `hive_flutter_kit`) such as title, author, creation date, and potentially vote counts/status via the internal `VideoInfo` widget.
-   **Current User Context**: Fetches the current Hive username using `hfk.getCurrentUser()` to determine vote status (e.g., if the current user has already voted on the video).
-   **Interactive Callbacks**: Provides callbacks for common social actions (comment, upvote, share, bookmark, author tap, info tap) allowing for custom app-specific implementations.

### 📱 Responsive and Adaptive Layout
-   **Mobile View (< 800dp width)**: Video player at the top, followed by the `VideoInfo` panel, and then the `videoFeed` widget taking the remaining space.
-   **Wide Screen View (>= 800dp width)**: A centered layout where the video player and `VideoInfo` panel are constrained in width (max 1800px, typical 1600px) and displayed within a `SingleChildScrollView`. The `videoFeed` is also constrained and placed below.
-   The AppBar displays the video title and a back button (if `shouldShowBackButton` is true).

### 🔄 Dynamic Content Loading & Updates
-   If `author` and `permlink` are provided, it fetches the full `GQLFeedItem` on initialization.
-   If the `author` or `permlink` props change, the player and associated data are re-initialized to load the new video.
-   Loads Hive post information (`Discussion`) asynchronously.

### 🧩 Modular Design
-   Uses `VideoInfo` as an internal component to display metadata and action buttons related to the video.
-   The `videoFeed` parameter allows embedding any widget, but is designed for a `ThreeSpeakVideoFeed` to show related content, creating a continuous viewing experience.

---

## See Also
- [ThreeSpeakVideoFeed](/threespeak/video-feed) - Often used for the `videoFeed` parameter or to navigate to this screen.
- `GQLFeedItem` (model from `hive_flutter_kit`) - The data structure for video items.
- `Discussion` (model from `hive_flutter_kit`) - The data structure for Hive post details.
- `chewie` and `video_player` Flutter packages.

