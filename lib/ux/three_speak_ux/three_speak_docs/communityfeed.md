# Community Feed Component

![Community Feed Preview](./communityfeed.png)

The `ThreespeakCommnuityScreen` widget provides a complete community experience for the ThreeSpeak platform, including a tabbed interface for videos, about, and team sections.

## Features

- 🏘️ **Community Video Feed** - Displays all videos from a specific community using `ThreeSpeakVideoFeed`
- 📑 **About Tab** - Shows community description and metadata
- 👥 **Team Tab** - Lists community team members
- 📱 **Tabbed Navigation** - Switch between Videos, About, and Team tabs
- 🎬 **Video Integration** - Direct video playback integration
- 🔗 **Custom Callbacks** - Handle taps on videos, authors, and tabs

## Basic Usage

```dart
ThreespeakCommnuityScreen(
  communityId: 'hive-163772',
  title: 'Worldmappin',
  onTapVideoItem: (item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(item: item),
      ),
    );
  },
  // Optionally add onTapAuthor, onTapVideosTab, etc.
)
```

## Widget Parameters

| Parameter         | Type                                   | Required | Description                                      |
|-------------------|----------------------------------------|----------|--------------------------------------------------|
| `communityId`     | `String`                               | ✅       | The Hive/3Speak community id to display          |
| `title`           | `String`                               | ✅       | The display title for the community              |
| `onTapVideosTab`  | `void Function(String, String)?`       | ❌       | Called when the Videos tab is selected           |
| `onTapAboutTab`   | `void Function(String, String)?`       | ❌       | Called when the About tab is selected            |
| `onTapTeamTab`    | `void Function(String, String)?`       | ❌       | Called when the Team tab is selected             |
| `onTapVideoItem`  | `void Function(GQLFeedItem item)?`     | ❌       | Called when a video item is tapped               |
| `onTapVideoReport`| `void Function(String, String)?`       | ❌       | Called when a video report is triggered          |
| `onTapAuthor`     | `void Function(String)?`               | ❌       | Called when an author is tapped                  |

## Tab Structure

### 1. 🎥 Videos Tab
- Displays all community videos using `ThreeSpeakVideoFeed` with `feedType: ThreeSpeakVideoFeedType.commnuityFeed`
- Smart layout switching (grid/list)
- Direct video playback integration

### 2. ℹ️ About Tab
- Community description and metadata

### 3. 👥 Team Tab
- Community team members

## Example: Community Feed Only

If you only want to show the community feed (not the full tabbed screen):

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.commnuityFeed,
  commnuityId: 'hive-163772',
  onTapVideoItem: (item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(item: item),
      ),
    );
  },
)
```

This approach provides a flexible way to display community videos, either as part of a full community screen or as a standalone feed.
