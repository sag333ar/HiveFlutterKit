# User Feed Component

![User Feed Preview](./userfeed.png)

The `ThreeSpeakFeedList` with `feedType: ThreeSpeakFeedType.userFeed` displays a grid/list of user feed from the creators of ThreeSpeak platform.

## Features

- 🚀 **Smart Layout** - Automatically switches between grid and list view based on screen width
- ♻️ **Pull-to-Refresh** - Built-in refresh functionality
- 🖼️ **Optimized Thumbnails** - Efficient image loading with placeholder
- 📊 **Engagement Metrics** - Displays view counts, upvotes, and timestamps
- 🔍 **Visibility Detection** - Only renders visible items for performance
# UserChannelScreen Component

The `UserChannelScreen` is a comprehensive user profile screen component for the ThreeSpeak platform that displays a creator's channel information, videos, and social connections in a tabbed interface.

## Features

- 🎬 **Video Feed Integration** - Displays user's video content using `ThreeSpeakFeedList`
- 📱 **Tabbed Navigation** - Four distinct tabs for different content types
- 👤 **Profile Display** - Shows user avatar, username, and profile information
- ❤️ **Favorite System** - Built-in favorite/unfavorite functionality for users
- 🔗 **Social Sharing** - RSS feed and profile URL sharing capabilities
- 👥 **Social Connections** - Followers and following lists
- 🚨 **Reporting System** - Built-in report functionality

## Component Architecture

### Main Screen Structure
```
UserChannelScreen
├── AppBar (with user info and actions)
├── TabBar (4 tabs)
└── TabBarView (4 tab content views)
```

### Sub-Components

#### 1. **ThreeSpeakFeedList** (Videos Tab)
- **Purpose**: Displays the user's video content feed
- **Type**: `ThreeSpeakFeedType.userFeed`
- **Features**: 
  - Grid/list view switching
  - Video thumbnail optimization
  - Tap-to-play video functionality
  - Navigation to `VideoPlayerScreen`

#### 2. **UserChannelProfileWidget** (Info Tab)
- **Purpose**: Shows detailed user profile information
- **Features**:
  - User bio display
  - Account creation date
  - Profile statistics
  - Additional user metadata

#### 3. **UserChannelFollowingWidget** (Social Tabs)
- **Purpose**: Displays followers and following lists
- **Dual Mode**: 
  - `isFollowers: true` - Shows user's followers
  - `isFollowers: false` - Shows users being followed
- **Features**:
  - User list with avatars
  - Follow/unfollow functionality
  - Social connection management

#### 4. **AppBar Components**
- **CustomCircleAvatar**: User profile picture
- **FavouriteWidget**: Favorite/unfavorite toggle
- **Share Actions**: RSS feed and profile sharing
- **Report Menu**: User reporting functionality

## Basic Usage

```dart
// Navigate to a user's channel
String username = await aioha.getCurrentUser();
username = username.replaceAll('"', '');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserChannelScreen(owner: username)),
    );
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `owner` | `String` | ✅ | The username of the channel owner |
| `loginModel` | `LoginModel?` | ❌ | Current logged-in user model for personalization |

## Tab Structure

### 1. 🎥 Videos Tab
- Displays user's video content using `ThreeSpeakFeedList`
- Smart layout switching (grid/list)
- Direct video playback integration
- Optimized thumbnail loading

### 2. ℹ️ Info Tab
- User profile information via `UserChannelProfileWidget`
- Bio, creation date, and statistics
- Comprehensive user metadata display

### 3. 👥 Followers Tab
- Lists users following this channel
- Uses `UserChannelFollowingWidget` with `isFollowers: true`
- Interactive follower management

### 4. 👤 Following Tab
- Lists users this channel follows
- Uses `UserChannelFollowingWidget` with `isFollowers: false`
- Following relationship management

## AppBar Actions

### Core Actions
- **Favorite Toggle**: Add/remove user from favorites
- **RSS Share**: Share user's RSS feed (`https://3speak.tv/rss/{username}.xml`)
- **Profile Share**: Share user's profile URL (`https://3speak.tv/user/{username}`)
- **Report Menu**: Report user functionality

### User Avatar Display
- Shows user's profile picture using `CustomCircleAvatar`
- Fetches image from `server.userOwnerThumb(username)`
- 36x36 pixel circular avatar

## Integration Points

### Video Playback
When a video is tapped in the feed:
```dart
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
```

### Favorite Management
- Uses `UserFavoriteProvider` for local storage
- Persistent favorite state across app sessions
- Toast notifications for user feedback

### Social Features
- RSS feed integration for content syndication
- Native share functionality via `share_plus` package
- Cross-platform sharing support

## Dependencies

### Core Flutter
- `flutter/material.dart` - Material Design components
- `share_plus` - Native sharing functionality

### Custom Components
- `ThreeSpeakFeedList` - Video feed display
- `UserChannelProfileWidget` - Profile information
- `UserChannelFollowingWidget` - Social connections
- `CustomCircleAvatar` - Profile picture display
- `FavouriteWidget` - Favorite toggle functionality
- `VideoPlayerScreen` - Video playback interface

### Data Management
- `UserFavoriteProvider` - Favorite user management
- `LoginModel` - User authentication data
- `ServerProxy` - API communication

## Performance Considerations

- **Tab-based Loading**: Content loads only when tabs are accessed
- **Optimized Images**: Efficient avatar and thumbnail loading
- **Memory Management**: Proper disposal of TabController
- **Lazy Loading**: Feed content loads progressively

## State Management

The component uses:
- **StatefulWidget** with **SingleTickerProviderStateMixin**
- **TabController** for tab navigation
- **UserFavoriteProvider** for favorite state management
- Local state for current tab index tracking

## Customization Options

- Tab icons and labels can be modified in the `tabs` static list
- AppBar actions can be customized or extended
- Feed display can be configured through `ThreeSpeakFeedList` parameters
- Social widgets support various display modes

This component provides a complete user channel experience with video content, profile information, and social features, making it ideal for creator-focused platforms like ThreeSpeak.