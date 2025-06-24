---
title: Video Feed
sidebar_label: Video Feed
slug: /video-feed
---

# 3Speak Video Feed

![Videos Feed Component Preview](/img/threespeak/firstuploads.png)

The `ThreeSpeakVideoFeed` widget displays a grid/list of videos from the ThreeSpeak platform. It supports multiple feed types, including a built-in search experience.

**Feed Types:**

- `trending` - Trending videos from the 3Speak platform
- `newUploads` - Newly uploaded videos on the 3Speak platform
- `hot` - Hot videos based on engagement metrics
- `firstUploads` - First uploads from creators on the 3Speak platform
- `related` - Shows videos related to a specific video (requires `author` & `permlink` parameter)
- `userFeed` - Shows videos from a specific user (requires `username` parameter)
- `commnuityFeed` - Shows videos from a specific community (requires `commnuityId` parameter)
- `search` - Shows videos based on a search query (supports built-in search bar with `isSearch: true`)

## Usage

### Trending, New Uploads, Hot, and First Uploads Feed

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

### User Feed

Shows all videos uploaded by a specific user. Pass the username via the `username` parameter.

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.userFeed,
  username: 'someuser', // required: username whose videos you want to show
  onTapVideoItem: (item) {
    debugPrint('User tapped on video item: ${item.author}/${item.permlink}');
    navigateToVideoPlayerScreen(item);
  },
)
```

- **Parameter:** `username` (String, required) — the Hive/3Speak username whose videos you want to display.

### Community Feed

Shows all videos from a specific community. Pass the community id via the `commnuityId` parameter.

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.commnuityFeed,
  commnuityId: 'hive-163772', // required: community id
  onTapVideoItem: (item) {
    debugPrint('User tapped on video item: ${item.author}/${item.permlink}');
    navigateToVideoPlayerScreen(item);
  },
)
```

- **Parameter:** `commnuityId` (String, required) — the Hive/3Speak community id whose videos you want to display.

### Search Feed (with built-in search bar)

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.search,
  isSearch: true, // Enables built-in search bar and handles search state
  onTapVideoItem: (item) {
    debugPrint('User tapped on video item: ${item.author}/${item.permlink}');
    navigateToVideoPlayerScreen(item);
  },
)
```

> **Note:** When `isSearch: true` and `feedType: ThreeSpeakVideoFeedType.search`, the widget displays a search bar in the app bar, handles debounce, and manages search state internally. You do **not** need to provide a `searchTerm` parameter in this mode.

### Search Feed (controlled externally)

If you want to control the search query from outside, you can use:

```dart
ThreeSpeakVideoFeed(
  feedType: ThreeSpeakVideoFeedType.search,
  searchTerm: 'hive', // must be at least 4 characters
  onTapVideoItem: (item) {
    debugPrint('User tapped on video item: ${item.author}/${item.permlink}');
    navigateToVideoPlayerScreen(item);
  },
)
```

### Example: Custom Search UI (external control)

```dart
class SearchFeedWidget extends StatefulWidget {
  @override
  State<SearchFeedWidget> createState() => _SearchFeedWidgetState();
}

class _SearchFeedWidgetState extends State<SearchFeedWidget> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search videos...',
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.trim();
            });
          },
        ),
        Expanded(
          child: ThreeSpeakVideoFeed(
            feedType: ThreeSpeakVideoFeedType.search,
            searchTerm: searchQuery.length >= 4 ? searchQuery : null,
          ),
        ),
      ],
    );
  }
}
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
- 🔍 **Integrated Search** - Use `feedType: ThreeSpeakVideoFeedType.search` and `isSearch: true` for a built-in search experience
- 👤 **User Feed** - Use `feedType: ThreeSpeakVideoFeedType.userFeed` and `username` to show a user's videos
- 🏘️ **Community Feed** - Use `feedType: ThreeSpeakVideoFeedType.commnuityFeed` and `commnuityId` to show a community's videos

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

### Community Feed
<!-- ![Community Feed](/img/threespeak/communityfeed.png) -->
