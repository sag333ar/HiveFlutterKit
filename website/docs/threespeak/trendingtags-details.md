---
title: 🎬 🔥 Trending Tags details
sidebar_label: 🎬 🔥 Trending Tags details
slug: /trendingtags-details
---

# 🎬 🔥 3Speak Trending Tags details

![Trending Tags details Preview Placeholder](/img/threespeak/trendingtagsdetails.png)
<!-- TODO: Replace with actual screenshot of ThreeSpeakTrendingTags -->

## Overview
The `ThreeSpeakVideoFeed` with feed type ThreeSpeakVideoFeedType.trendingTagFeed is a versatile component for displaying various lists of videos from the ThreeSpeak platform for that particular tag.

## Usage Example

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.trendingTagFeed,
  tag: widget.selectedTag,
  onTapVideoItem: (tappedItem) {
    debugPrint('Tapped video: ${tappedItem.title}');
    // Navigate to VideoPlayerScreen or handle as needed
  },
  onTapAuthor: (item) => debugPrint('Author: ${item.author}'),
  onTapReport: (item) => debugPrint('Report: ${item.permlink}'),
  onTapUpvote: (item) => debugPrint('Upvote: ${item.permlink}'),
  onTapComment: (item) => debugPrint('Comment: ${item.permlink}'),
  isPayoutValueVisible: true
)
```

## Widget Parameters

| Parameter         | Type                                  | Required | Description                                                                                                                               |
|-------------------|---------------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `feedType`        | `ThreeSpeakVideoFeedType`             | ✅        | Determines the type of video feed to fetch and display.                                                                                   |
| `onTapVideoItem`  | `void Function(GQLFeedItem item)`     | ✅        | Callback when a video item (card) is tapped. Receives the `GQLFeedItem` object.                                                             |
| `onTapAuthor`     | `void Function(GQLFeedItem item)`     | ✅        | Callback when the author's avatar or name on a video card is tapped.                                                                        |
| `onTapReport`     | `void Function(GQLFeedItem item)`     | ✅        | Callback when the report/more_options icon on a video card is tapped.                                                                       |
| `onTapUpvote`     | `void Function(GQLFeedItem item)`     | ✅        | Callback when the upvote icon on a video card is tapped.                                                                                    |
| `onTapComment`    | `void Function(GQLFeedItem item)`     | ✅        | Callback when the comment icon on a video card is tapped.                                                                                   |
| `tag`             | `String?`                             | ✅    | The tag to fetch trending videos for.                                                        |
| `isPayoutValueVisible`             | `bool?`                             | ❌    |  Used if user want to show the payout value 

