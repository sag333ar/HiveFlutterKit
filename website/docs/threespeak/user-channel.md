---
title: 🎬 👤  User Channel
sidebar_label: 🎬 👤 User Channel
slug: /user-channel
---

# 🎬 👤 3speak's User Channel 

### User channel component
![preview](/img/threespeak/userfeed.png)

## Overview

The `UserChannelScreen` is a Flutter widget that displays a user's channel page with a tabbed interface showing videos, profile information, followers, and following lists. It provides a comprehensive view of a user's channel with interactive features like bookmarking, sharing, and reporting.

```dart
UserChannelScreen(
    owner: author,
    onTapBackButton: () => context.pop(),
    shouldShowBackButton: !kIsWeb,
    videoFeed: () => 
    ThreeSpeakVideoFeed(
        username: author,
        feedType: ThreeSpeakVideoFeedType.userFeed,
        onTapVideoItem: (tappedItem) {debugPrint('Tapped video: ${tappedItem.title}');
            // Navigate to VideoPlayerScreen or handle as needed
        },
        onTapAuthor: (item) => debugPrint('Tapped author: ${item.author}'),
        onTapReport: (item) => debugPrint('Tapped report: ${item.permlink}'),
    ),
    //other callbacks
);
```

## Constructor Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `owner` | `String` | The username/identifier of the channel owner |
| `videoFeed` | `ThreeSpeakVideoFeed Function()` | Function that returns the video feed widget |
| `onTapBackButton` | `VoidCallback` | Callback function for back button tap |
| `shouldShowBackButton` | `bool` | Whether to display the back button in the app bar |

### Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onTapVideoIcon` | `void Function(String, String)?` | Callback for video tab selection |
| `onTapInfoIcon` | `void Function(String, String)?` | Callback for info tab selection |
| `onTapFollowers` | `void Function(String, String)?` | Callback for followers tab selection |
| `onTapFollowing` | `void Function(String, String)?` | Callback for following tab selection |
| `onTapBookmark` | `void Function(String, String)?` | Callback for bookmark/favorite action |
| `onTapRssFeed` | `void Function(String, String)?` | Callback for RSS feed action |
| `onTapShare` | `void Function(String, String)?` | Callback for share action |
| `onTapReport` | `void Function(String, String)?` | Callback for report action |

## Tab Structure

The screen contains four tabs:

1. **Videos Tab** (Index 0)
   - Icon: `Icons.video_camera_front_outlined`
   - Displays the video feed using the provided `videoFeed` function
   - Triggers `onTapVideoIcon` callback with parameters: `(owner, "videos")`

2. **Info Tab** (Index 1)
   - Icon: `Icons.info`
   - Shows user profile information using `UserChannelProfileWidget`
   - Triggers `onTapInfoIcon` callback with parameters: `(owner, "info")`

3. **Followers Tab** (Index 2)
   - Text: "Followers"
   - Displays followers list using `UserChannelFollowingWidget` with `isFollowers: true`
   - Triggers `onTapFollowers` callback with parameters: `(owner, "followers")`

4. **Following Tab** (Index 3)
   - Text: "Following"
   - Shows following list using `UserChannelFollowingWidget` with `isFollowers: false`
   - Triggers `onTapFollowing` callback with parameters: `(owner, "following")`

### Right Side Actions

1. **Favorite/Bookmark Button**
   - Uses `FavouriteWidget` with "User" toast type
   - Checks if user is favorited locally via `UserFavoriteProvider`
   - Add/Remove callbacks trigger `onTapBookmark` or local storage

2. **RSS Feed Button**
   - Icon: `Icons.rss_feed`
   - Triggers `onTapRssFeed` callback or shares RSS URL: `https://3speak.tv/rss/{owner}.xml`

3. **Share Button**
   - Icon: `Icons.share`
   - Triggers `onTapShare` callback or shares profile URL: `https://3speak.tv/user/{owner}`

4. **More Options Menu**
   - Icon: `Icons.more_vert`
   - Contains "Report" option in red text
   - Triggers `onTapReport` callback or shows default snackbar