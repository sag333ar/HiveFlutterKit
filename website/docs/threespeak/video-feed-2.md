---
title: 🎬 👀 Studio Feed
sidebar_label: 🎬 👀 Studio Feed
slug: /video-feed-2
---

# 🎬 👀 3Speak Video (Studio Feed)

![Videos Feed Component Preview](/img/threespeak/studio-feed.png)

The `VideoFeed` widget is a responsive and extensible component for rendering videos from the 3Speak platform. It supports several feed types (like trending, home, new videos, etc.), adaptive layouts for mobile and desktop, and full control over item interactions via callbacks.

---

## ✅ Core Functionality

* **Feed source:** Videos are fetched from the 3Speak API (`ApiService`) based on `ApiVideoFeedType`.
* **Responsive layout:**

  * **Wide screens (≥ 600dp):** Grid view using `GridView.builder`.
  * **Narrow screens (< 600dp):** List view using `VideoListview`, optimized for visibility handling.
* **Caching:** Static in-memory caching to avoid redundant API calls.
* **Refresh:** Pull-to-refresh and manual refresh support.
* **UI States:** Built-in loading, error, and empty state handling.

---

## 🎯 Feed Types (`ApiVideoFeedType`)

| Feed Type      | Description                                                      |
| -------------- | ---------------------------------------------------------------- |
| `home`         | Default feed, likely personalized or curated content.            |
| `trending`     | Currently trending videos.                                       |
| `newVideos`    | Latest uploaded content.                                         |
| `firstUploads` | First videos ever uploaded by creators.                          |
| `user`         | Videos by a specific user. Requires `username`.                  |
| `community`    | Videos from a specific 3Speak community. Requires `communityId`. |
| `related`    | Videos from a specific Username. Requires `username`. |

> ❗️**Note:** Only the above 6 types are supported in the provided code. Types like `related`, `search`, or `hot` are not present in the current `VideoFeed` class.

---

## ✨ Example Usage

```dart
VideoFeed(
  feedType: ApiVideoFeedType.trending,
  onTapVideoItem: (video) => debugPrint('Tapped: ${video.title}'),
  onTapAuthor: (video) => debugPrint('Author: ${video.author}'),
  onTapReport: (video) => debugPrint('Report: ${video.permlink}'),
  onTapUpvote: (video) => debugPrint('Upvote: ${video.permlink}'),
  onTapComment: (video) => debugPrint('Comment: ${video.permlink}'),
  isPayoutValueVisible: true,
)
```

### User Feed

```dart
VideoFeed(
  feedType: ApiVideoFeedType.user,
  username: 'my-hive-username',
  onTapVideoItem: ...,
  onTapAuthor: ...,
  onTapReport: ...,
  onTapUpvote: ...,
  onTapComment: ...,
)
```
### Related Feed

```dart
VideoFeed(
  feedType: ApiVideoFeedType.related,
  username: 'my-hive-username',
  onTapVideoItem: ...,
  onTapAuthor: ...,
  onTapReport: ...,
  onTapUpvote: ...,
  onTapComment: ...,
)
```

### Community Feed

```dart
VideoFeed(
  feedType: ApiVideoFeedType.community,
  communityId: 'hive-12345',
  onTapVideoItem: ...,
  onTapAuthor: ...,
  onTapReport: ...,
  onTapUpvote: ...,
  onTapComment: ...,
)
```
---

## 🧾 Parameters

| Parameter              | Type                             | Required | Description                                             |
| ---------------------- | -------------------------------- | -------- | ------------------------------------------------------- |
| `feedType`             | `ApiVideoFeedType`               | ✅        | Source/type of video feed to display.                   |
| `username`             | `String?`                        | ⚠️ Cond  | Required when `feedType == ApiVideoFeedType.user`.      |
| `communityId`          | `String?`                        | ⚠️ Cond  | Required when `feedType == ApiVideoFeedType.community`. |
| `onTapVideoItem`       | `void Function(ThreeSpeakVideo)` | ✅        | Called when a video card is tapped.                     |
| `onTapAuthor`          | `void Function(ThreeSpeakVideo)` | ✅        | Called when the author’s avatar or name is tapped.      |
| `onTapReport`          | `void Function(ThreeSpeakVideo)` | ✅        | Called when the report (options) icon is tapped.        |
| `onTapUpvote`          | `void Function(ThreeSpeakVideo)` | ✅        | Called when the upvote button is tapped.                |
| `onTapComment`         | `void Function(ThreeSpeakVideo)` | ✅        | Called when the comment button is tapped.               |
| `isPayoutValueVisible` | `bool?`                          | ❌        | Whether to show estimated payout value on video cards.  |
| `shouldShowBackButton` | `bool?`                          | ❌        | If `true`, shows a back button in the `AppBar`.         |
| `onTapBackButton`      | `VoidCallback?`                  | ❌        | Called when the back button is tapped.                  |

---

## 🔥 Features

* **Caching**: Memory-based cache to improve performance and reduce API calls.
* **Refresh**: Pull-to-refresh and refresh button support.
* **Adaptability**: Responsive switch between grid and list views.
* **Visibility Optimization**: Uses `VideoListview` for scroll-based optimization on narrow screens.
* **Flexible Actions**: Full callback support for video, author, and engagement actions.
* **Clean UX States**: Loading, error, and no-content views handled internally.

---

## 🧭 Optional Navigation Example

```dart
void openVideoPlayer(BuildContext context, ThreeSpeakVideo video) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VideoPlayerScreen(
        video: video,
        onTapBackButton: () => Navigator.pop(context),
      ),
    ),
  );
}
```

Use it like this:

```dart
onTapVideoItem: (video) => openVideoPlayer(context, video),
```
---
## See Also
- [VideoPlayerScreen](/docs/video-player) - For playing individual videos from the feed.
- [ThreeSpeakTrendingTags](/docs/trending-tags) - For displaying a list of trending tags, which can then be used to filter this video feed (using `feedType: ThreeSpeakVideoFeedType.trendingTagFeed`).
- `VideoCard` widget (internal component) - The UI element used to display each video in the feed.