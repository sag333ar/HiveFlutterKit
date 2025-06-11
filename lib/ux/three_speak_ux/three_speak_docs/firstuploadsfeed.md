# First Uploads Feed Component

![First Uploads Feed Preview](./firstuploads.png)

The `ThreeSpeakFeedList` with `feedType: ThreeSpeakFeedType.firstUploads` displays a grid/list of first uploads from the creators of ThreeSpeak platform.

## Features

- 🚀 **Smart Layout** - Automatically switches between grid and list view based on screen width
- ♻️ **Pull-to-Refresh** - Built-in refresh functionality
- 🖼️ **Optimized Thumbnails** - Efficient image loading with placeholder
- 📊 **Engagement Metrics** - Displays view counts, upvotes, and timestamps
- 🔍 **Visibility Detection** - Only renders visible items for performance

## Basic Usage

```dart
ThreeSpeakFeedList(
  feedType: ThreeSpeakFeedType.firstUploads,
  onTapVideoItem: (item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
      videoUrl: videoUrl ?? '',
      title: item.title ?? 'Untitled',
      author: item.author?.username ?? 'Unknown',
      permlink: item.permlink ?? 'Unknown',
      createdAt: item.createdAt,
      item: item,
      // ✅ Optional Callbacks
      isUserVoted: () {},
      onTapComment: () {},
      onComment: (body) {},
      onUpvoteComment: () {},
      onReplyComment: () {},
      onShare: () {},
      onBookmark: () {},
      onTapAuthor: () {},
      ),
      ),
    );
  },
)