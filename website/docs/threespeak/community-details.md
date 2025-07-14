---
title: 🎬 🏘️ 3Speak Community details
sidebar_label: 🎬 🏘️ Community details
slug: /community-details
---

# 🎬 🏘️ 3Speak Community Details

![Community details Preview Placeholder](/img/threespeak/communitydetails.png)
<!-- TODO: Replace with actual screenshot of ThreeSpeakTrendingTags -->

## Overview
The `ThreeSpeakVideoFeed` with feed type ThreeSpeakVideoFeedType.community is a versatile component for displaying various lists of videos from the ThreeSpeak platform for that particular community.

---

## Overview

- Displays the selected community's profile image and title in the AppBar.
- Offers four tabs: **Videos**, **About**, **Team**, and **Members**.
- Allows deep integration by exposing callback functions for tab switches, bookmarking, RSS, sharing, and reporting.
- Embeds a video feed via a custom `ThreeSpeakVideoFeed` provided by the caller.
- Manages and persists favorites using `CommunityFavouriteProvider`.

---

## Usage Example

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.community,
  communityId: widget.selectedCommunityId,
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
| `commnuityId`     | `String?`                             | ✅    | The ID of the 3Speak community.                                                                |
| `isPayoutValueVisible`             | `bool?`                             | ❌    |  Used if user want to show the payout value 

