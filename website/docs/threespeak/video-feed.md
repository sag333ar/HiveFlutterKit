---
title: Video Feed
sidebar_label: Video Feed
slug: /video-feed
---

# 3Speak Video Feed

![Videos Feed Component Preview](/img/threespeak/firstuploads.png)

The `ThreeSpeakVideoFeed` with `feedType: ThreeSpeakVideoFeedType.firstUploads` displays a grid/list of first uploads from the creators of ThreeSpeak platform.

**Feed Types:**

- `trending` - Trending videos from the 3Speak platform
- `newUploads` - Newly uploaded videos on the 3Speak platform
- `hot` - Hot videos based on engagement metrics
- `firstUploads` - First uploads from creators on the 3Speak platform
- `related` - Shows videos related to a specific video (requires `author` & `permlink` parameter)
- `userFeed` - Shows videos from a specific user (requires `author` parameter)
- `search` - Shows videos based on a search query (requires `query` parameter)

## Usage

### trending, newUploads, hot, and firstUploads Feed

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.firstUploads,
  onTapVideoItem: (item) {
    debugPrint('User tapped on video item: ${item.author}/${item.permlink}');
    navigateToVideoPlayerScreen(item);
  },
)
```

### Related Feed

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.related,
  relatedAuthor: relatedAuthor,
  relatedPermlink: relatedPermlink,
  onTapVideoItem: (item) {
    debugPrint('User tapped on video item: ${item.author}/${item.permlink}');
    navigateToVideoPlayerScreen(item);
  },
)
```

### Optional Navigation Function

```dart
void navigateToVideoPlayerScreen(GQLFeedItem item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VideoPlayerScreen(
        item: item,
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
}
```

## Features

- 🚀 **Smart Layout** - Automatically switches between grid and list view based on screen width
- ♻️ **Pull-to-Refresh** - Built-in refresh functionality
- 🖼️ **Optimized Thumbnails** - Efficient image loading with placeholder
- 📊 **Engagement Metrics** - Displays view counts, upvotes, and timestamps
- 🔍 **Visibility Detection** - Only renders visible items for performance

### Screenshots for other feed types

#### Trending Feed
![Trending Feed](/img/threespeak/trending.png)

#### Related Feed
![Related Feed](/img/threespeak/related.png)

#### New Uploads Feed
![New Uploads Feed](/img/threespeak/newuploads.png)

#### First Uploads Feed
![First Uploads Feed](/img/threespeak/firstuploads.png)

### Search screen
![Search Screen](/img/threespeak/searchscreen.png)

### User Feed
![User Feed](/img/threespeak/userfeed.png)
