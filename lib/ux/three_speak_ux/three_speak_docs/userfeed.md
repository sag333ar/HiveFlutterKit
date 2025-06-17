# User Feed Component

![User Feed Preview](./userfeed.png)

The `UserChannelScreen` is a comprehensive user profile screen component for the ThreeSpeak platform that displays a creator's channel information, videos, and social connections in a tabbed interface.

## Features

- 🎬 **Video Feed Integration** - Displays user's video content using `ThreeSpeakVideoFeed`
- 📱 **Tabbed Navigation** - Four distinct tabs for different content types
- 👤 **Profile Display** - Shows user avatar, username, and profile information
- ❤️ **Favorite System** - Built-in favorite/unfavorite functionality for users
- 🔗 **Social Sharing** - RSS feed and profile URL sharing capabilities
- 👥 **Social Connections** - Followers and following lists
- 🚨 **Reporting System** - Built-in report functionality

## Widget Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `owner` | `String` | ✅ | The username of the channel owner whose profile and content are displayed. |
| `onTapVideoIcon` | `void Function(String author, String permlink)?` | ❌ | Triggered when the "Videos" tab is selected. |
| `onTapInfoIcon` | `void Function(String author, String permlink)?` | ❌ | Triggered when the "Info" tab is selected. |
| `onTapFollowers` | `void Function(String author, String permlink)?` | ❌ | Triggered when the "Followers" tab is selected. |
| `onTapFollowing` | `void Function(String author, String permlink)?` | ❌ | Triggered when the "Following" tab is selected. |
| `onTapBookmark` | `void Function(String author, String permlink)?` | ❌ | Triggered when the user bookmarks or unbookmarks the channel. |
| `onTapRssFeed` | `void Function(String author, String permlink)?` | ❌ | Triggered when the RSS feed icon is tapped. |
| `onTapShare` | `void Function(String author, String permlink)?` | ❌ | Triggered when the share icon is tapped. |
| `onTapReport` | `void Function(String author, String permlink)?` | ❌ | Triggered when the "Report" option is selected from the menu. |
| `onTapVideoItem` | `final void Function(GQLFeedItem item)?` | ❌ | Triggered when the particular video item is tapped. |
| `onTapVideoReport` | `void Function(String author, String permlink)?` | ❌ | Triggered when the "Report" option is selected from the video item. |
| `onTapAuthor` | `final void Function(String)?` | ❌ | Triggered when the profile avtar of the user is tapped. |

## Basic Usage

```dart
void _handleTapAuthor(BuildContext context, GQLFeedItem item) {
      final username = item.author?.username;
      if (username != null && username.isNotEmpty) {
        Navigator.push(
          context,
          builder: (context) =>  UserChannelScreen(
            owner: username,
            onTapVideoIcon: (){},
            onTapInfoIcon: (){},
            onTapFollowers: (){},
            onTapFollowing: (){},
            onTapBookmark: (){},
            onTapRssFeed: (){},
            onTapShare: (){},
            onTapReport: (){},
            onTapVideoItem: (){},
            onTapVideoReport: (){},
            onTapAuthor: (){}
          )
        ),
      }
    }

VideoCard(
    item: item,
    isVisible: isVisible,
    onTapAuthor: () => _handleTapAuthor(context, item),
  );
```
## How it works:
- item.author?.username retrieves the username of the content creator from the GQLFeedItem object.

- If a valid username exists, the function uses Flutter’s Navigator.push to open the UserChannelScreen, passing the username as the owner    parameter.

🛠️ Note:
- You don't need to manually navigate to UserChannelScreen in most cases.
- The ThreeSpeakVideoFeed component already includes a default implementation for the onTapAuthor callback.
- If no custom onTapAuthor function is provided, it will automatically open the UserChannelScreen with the tapped author's profile avtar.

## Tab Structure

### 1. 🎥 Videos Tab
- Displays user's video content using `ThreeSpeakVideoFeed`
- Smart layout switching (grid/list)
- Direct video playback integration
- Optimized thumbnail loading

### 2. ℹ️ Info Tab
- User profile information via `UserChannelProfileWidget`
- Bio, creation date, and statistics
- Comprehensive user metadata display

### 3. 👥 Followers Tab
- Lists users following this channel

### 4. 👤 Following Tab
- Lists users this channel follows

## AppBar Actions

### Core Actions
- **Favorite Toggle**: Add/remove user from favorites
- **RSS Share**: Share user's RSS feed
- **Profile Share**: Share user's profile URL
- **Report Menu**: Report user functionality

This component provides a complete user channel experience with video content, profile information, and social features, making it ideal for creator-focused platforms like ThreeSpeak.