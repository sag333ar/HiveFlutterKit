---
title: 🎬 🔥 Trending Tags
sidebar_label: 🎬 🔥 Trending Tags
slug: /trending-tags
---

# 🎬 🔥 3Speak Trending Tags

![Trending Tags Preview Placeholder](/img/threespeak/trending_tags_placeholder.png)
<!-- TODO: Replace with actual screenshot of ThreeSpeakTrendingTags -->

The `ThreeSpeakTrendingTags` widget fetches and displays a list of currently trending tags from the 3Speak platform. It presents these tags in a responsive grid layout, allowing users to tap on a tag to trigger a custom action, typically navigating to a feed of videos associated with that tag.

## Overview

`ThreeSpeakTrendingTags` is a stateful widget that:
-   Fetches a list of trending tags using the 3Speak GQL API upon initialization.
-   Displays each tag within a `Card`, showing the tag name (e.g., "#gaming"), its trending score, and a visual circular progress indicator representing its popularity relative to other tags.
-   The color of the progress indicator (green, orange, red) changes based on the tag's score.
-   Handles loading and error states during data fetching.
-   The primary interaction is through the `onTapTag` callback, which is invoked when a user taps on any tag card.

The visual presentation is handled by an internal `TrendingTags` widget, which arranges the tags in a `GridView` that adapts to screen width.

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_trending_tags.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart'; // For navigation example
import 'package:hive_flutter_kit/core/common/enum.dart'; // For ThreeSpeakVideoFeedType

class TrendingTagsScreen extends StatelessWidget {
  const TrendingTagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3Speak Trending Tags'),
      ),
      body: ThreeSpeakTrendingTags(
        onTapTag: (tag) {
          debugPrint('Tapped tag: $tag');
          // Example: Navigate to a video feed for the selected tag
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('#$tag Videos')),
                body: ThreeSpeakVideoFeed(
                  feedType: ThreeSpeakVideoFeedType.trendingTagFeed,
                  tag: tag,
                  // Provide all required callbacks for ThreeSpeakVideoFeed
                  onTapVideoItem: (item) {
                    debugPrint('Tapped video: ${item.title}');
                    // Navigate to your video player screen
                  },
                  onTapAuthor: (item) => debugPrint('Author: ${item.author}'),
                  onTapReport: (item) => debugPrint('Report: ${item.permlink}'),
                  onTapUpvote: (item) => debugPrint('Upvote: ${item.permlink}'),
                  onTapComment: (item) => debugPrint('Comment: ${item.permlink}'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## Widget Parameters

| Parameter | Type                          | Required | Description                                                                 |
|-----------|-------------------------------|----------|-----------------------------------------------------------------------------|
| `onTapTag`| `void Function(String tag)`   | ✅        | Callback invoked when a tag is tapped. It receives the tapped tag as a `String`. |

Currently, the `ThreeSpeakTrendingTags` widget does not expose direct parameters for customizing the appearance (e.g., background colors, text styles of the tags). The styling is self-contained within the internal `TrendingTags` display widget.

## Features

-   **🚀 Automatic Data Fetching**: Fetches the latest trending tags from 3Speak when the widget is initialized.
-   **📊 Score Visualization**: Displays each tag with its name and trending score. A circular progress indicator visually represents the tag's score relative to the highest scoring tag, with color coding (green for high, orange for medium, red for low scores) to indicate its trending intensity.
-   **📱 Responsive Grid Layout**: Tags are displayed in a `GridView` that adjusts the number of columns based on the screen width, ensuring a good viewing experience on both mobile and larger screens.
-   **👆 Interactive Callbacks**: The `onTapTag` callback allows developers to define custom actions when a tag is selected, such as navigating to a list of videos associated with that tag.
-   **⏳ Loading and Error States**: Shows a loading indicator while fetching tags and displays an error message if the data cannot be retrieved or if no tags are found.

## How it Works

1.  When `ThreeSpeakTrendingTags` is added to the widget tree, its `initState` method calls `_fetchFeed`.
2.  `_fetchFeed` uses `GQLCommunicator().getTrendingTags()` to request the list of trending tags from the 3Speak API.
3.  During fetching, a `CircularProgressIndicator` is displayed.
4.  If an error occurs, an error message is shown.
5.  If successful, the fetched tags (instances of `TrendingTagResponseDataTrendingTag`) are passed to the internal `TrendingTags` widget.
6.  The `TrendingTags` widget renders these tags in a responsive grid. Each tag card includes the tag name (e.g., "#news"), its score, and the visual score indicator.
7.  When a user taps on a tag card, the `onTapTag` callback (provided to `ThreeSpeakTrendingTags`) is executed with the string value of the tapped tag.

---

## See Also

-   [ThreeSpeakVideoFeed](/docs/video-feed) - Can be used in conjunction with `ThreeSpeakTrendingTags` to display videos for a selected tag using `feedType: ThreeSpeakVideoFeedType.trendingTagFeed`.
-   `GQLCommunicator` (internal) - Used for API communication.
-   `TrendingTagResponseDataTrendingTag` (internal model) - The data structure for individual tag items.
