---
title: 🎬 👀 Video Feed
sidebar_label: 🎬 👀 Video Feed
slug: /video-feed
---

# 🎬 👀 3Speak Video Feed

![Videos Feed Component Preview](/img/threespeak/firstuploads.png)

The `ThreeSpeakVideoFeed` widget is a versatile component for displaying various lists of videos from the ThreeSpeak platform. It supports multiple feed types, infinite scrolling (implicitly through fetching all items initially), a built-in search experience, and customizable callbacks for user interactions.

## Core Functionality

This widget fetches video data from the 3Speak GQL API based on the specified `feedType` and other relevant parameters. It then displays these videos in a responsive layout:
- **Wide screens (>= 600dp):** A grid view with an adaptive number of columns.
- **Narrow screens (< 600dp):** A list view with `VideoCard` widgets. It uses `VisibilityDetectorListView` for optimizing rendering of visible items.

## Feed Types (`ThreeSpeakVideoFeedType`)

The `feedType` parameter determines the source and nature of the videos displayed:

-   **`trending`**: Shows currently trending videos on the 3Speak platform.
-   **`newUploads`**: Displays the most recently uploaded videos.
-   **`hot`**: (Note: Currently, the implementation for `hot` feed is commented out in the source, so it might behave like an empty list or default to another feed if not explicitly handled by GQL.)
-   **`firstUploads`**: Features videos that are the first uploads from their creators.
-   **`related`**: Lists videos related to a specific video. Requires `relatedAuthor` and `relatedPermlink` parameters.
-   **`userFeed`**: Shows videos uploaded by a particular user. Requires the `username` parameter.
-   **`commnuityFeed`**: Displays videos from a specific 3Speak community. Requires the `commnuityId` parameter.
-   **`myFeed`**: Shows videos from users that the current user (specified by `username`) is following. Requires the `username` parameter.
-   **`search`**: Enables searching for videos.
    -   If `isSearch` is `true`, it provides a built-in AppBar with a search input field.
    -   If `isSearch` is `false` (default), it expects a `searchTerm` to be provided externally.
-   **`trendingTagFeed`**: Shows videos trending under a specific tag. Requires the `tag` parameter.

---

## Usage Examples

### Basic Feed (Trending, New Uploads, etc.)

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.trending, // Or .newUploads, .firstUploads
  onTapVideoItem: (tappedItem) {
    debugPrint('Tapped video: ${tappedItem.title}');
    // Navigate to VideoPlayerScreen or handle as needed
  },
  onTapAuthor: (item) => debugPrint('Author: ${item.author}'),
  onTapReport: (item) => debugPrint('Report: ${item.permlink}'),
  onTapUpvote: (item) => debugPrint('Upvote: ${item.permlink}'),
  onTapComment: (item) => debugPrint('Comment: ${item.permlink}'),
)
```

### Related Videos Feed

To show videos related to `mainAuthor/mainPermlink`:

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.related,
  relatedAuthor: 'mainAuthor',
  relatedPermlink: 'mainPermlink',
  // Add other required callbacks (onTapVideoItem, etc.)
  // ...
)
```

### User's Videos Feed

To show videos by 'someuser':

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.userFeed,
  username: 'someuser',
  // Add other required callbacks
  // ...
)
```

### My Feed (Followed Users)

To show the feed for 'currentUser':

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.myFeed,
  username: 'currentUser', // Username of the logged-in user
  // Add other required callbacks
  // ...
)
```

### Community Feed

To show videos from community 'hive-12345':

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.commnuityFeed,
  commnuityId: 'hive-12345',
  // Add other required callbacks
  // ...
)
```

### Trending Tag Feed

To show videos trending under the tag 'gaming':

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.trendingTagFeed,
  tag: 'gaming',
  // Add other required callbacks
  // ...
)
```

### Search Feed (Built-in UI)

This will render an `AppBar` with a search field.

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.search,
  isSearch: true, // Enables the built-in search AppBar
  // Add other required callbacks
  // ...
)
```
**Note:** When `isSearch: true`, the widget handles the search text input, debouncing, and fetching internally. The `searchTerm` parameter is ignored in this mode. Search is triggered when the user types at least 4 characters.

### Search Feed (External Control)

Provide `searchTerm` externally.

```dart
String _currentSearchQuery = "flutter development";

ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.search,
  searchTerm: _currentSearchQuery.length >= 4 ? _currentSearchQuery : null,
  // isSearch: false (or omitted)
  // Add other required callbacks
  // ...
)
```

---

## Widget Parameters

| Parameter         | Type                                  | Required | Description                                                                                                                               |
|-------------------|---------------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `feedType`        | `ThreeSpeakVideoFeedType`             | ✅        | Determines the type of video feed to fetch and display.                                                                                   |
| `onTapVideoItem`  | `void Function(GQLFeedItem item)`     | ✅        | Callback when a video item (card) is tapped. Receives the `GQLFeedItem` object.                                                             |
| `onTapAuthor`     | `void Function(GQLFeedItem item)`     | ✅        | Callback when the author's avatar or name on a video card is tapped.                                                                        |
| `onTapReport`     | `void Function(GQLFeedItem item)`     | ✅        | Callback when the report/more_options icon on a video card is tapped.                                                                       |
| `onTapUpvote`     | `void Function(GQLFeedItem item)`     | ✅        | Callback when the upvote icon on a video card is tapped.                                                                                    |
| `onTapComment`    | `void Function(GQLFeedItem item)`     | ✅        | Callback when the comment icon on a video card is tapped.                                                                                   |
| `isShorts`        | `bool`                                | ❌        | (Default: `false`) If `true`, fetches short-form video content (experimental or specific to API).                                         |
| `lang`            | `String?`                             | ❌        | Language code (e.g., "en", "es") to filter content by language, if supported by the API for the given `feedType`.                         |
| `isSearch`        | `bool`                                | ❌        | (Default: `false`) If `true` and `feedType` is `search`, enables the built-in search UI (AppBar with TextField).                            |
| `relatedAuthor`   | `String?`                             | Cond.    | Required if `feedType` is `related`. The author of the video for which related content is sought.                                         |
| `relatedPermlink` | `String?`                             | Cond.    | Required if `feedType` is `related`. The permlink of the video for which related content is sought.                                       |
| `username`        | `String?`                             | Cond.    | Required if `feedType` is `userFeed` or `myFeed`. The Hive username.                                                                      |
| `searchTerm`      | `String?`                             | Cond.    | Used if `feedType` is `search` and `isSearch` is `false`. The search query. Must be at least 4 characters.                                 |
| `commnuityId`     | `String?`                             | Cond.    | Required if `feedType` is `commnuityFeed`. The ID of the 3Speak community.                                                                |
| `tag`             | `String?`                             | Cond.    | Required if `feedType` is `trendingTagFeed`. The tag to fetch trending videos for.                                                        |

*Cond.* = Conditionally Required.

---
## Key Features

-   🧠 **Multiple Feed Sources**: Supports a wide range of content discovery methods through `ThreeSpeakVideoFeedType`.
-   📱 **Responsive Layout**: Adapts between list and grid views based on screen width.
-   🔍 **Integrated Search**: Offers a ready-to-use search interface when `feedType` is `search` and `isSearch` is `true`. Includes debouncing for search input.
-   🎨 **Customizable Actions**: Provides callbacks for common interactions like tapping a video, author, or action buttons (report, upvote, comment).
-   🖼️ **Video Cards**: Uses `VideoCard` widgets to display video thumbnails, titles, author information, and engagement actions.
-   🔄 **Loading & Error States**: Shows a loading indicator while fetching data and displays error messages or "No videos found" appropriately.
-   🌐 **Language Filtering**: Optional `lang` parameter for internationalization.

---

### Optional Navigation Function (Example)

```dart
void navigateToVideoPlayerScreen(BuildContext context, GQLFeedItem item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VideoPlayerScreen( // Assuming you have a VideoPlayerScreen
        item: item,
        // Other necessary parameters for VideoPlayerScreen
        onTapBackButton: () => Navigator.of(context).pop(),
        videoFeed: () => ThreeSpeakVideoFeed( // Example: Related feed in player
            feedType: ThreeSpeakVideoFeedType.related,
            relatedAuthor: item.author,
            relatedPermlink: item.permlink,
            // ... other callbacks ...
        ),
        // ... other callbacks for VideoPlayerScreen ...
      ),
    ),
  );
}
```
Call this in `onTapVideoItem`:
```dart
onTapVideoItem: (tappedItem) {
  navigateToVideoPlayerScreen(context, tappedItem);
},
```

---

### Screenshots for various feed types

*(Screenshots for Trending, Related, New Uploads, First Uploads, Search, User Feed, and Community Feed can be retained or updated as needed.)*

#### My Feed
*(Add a screenshot for My Feed if available/distinct)*

#### Trending Tag Feed
*(Add a screenshot for Trending Tag Feed if available/distinct)*

---
## See Also
- [VideoPlayerScreen](/docs/video-player) - For playing individual videos from the feed.
- [ThreeSpeakTrendingTags](/docs/trending-tags) - For displaying a list of trending tags, which can then be used to filter this video feed (using `feedType: ThreeSpeakVideoFeedType.trendingTagFeed`).
- `VideoCard` widget (internal component) - The UI element used to display each video in the feed.
