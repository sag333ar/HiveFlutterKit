# Threespeak Community Screen

The `ThreespeakCommnuityScreen` is a comprehensive community profile and feed screen for the ThreeSpeak platform. It provides a tabbed interface for exploring community videos, about info, team members, and all community members.

---

## Screenshots

### Videos Tab
![Community Videos Tab](./screenshots/community_videos_tab.png)

### About Tab
![Community About Tab](./screenshots/community_about_tab.png)

### Team Tab
![Community Team Tab](./screenshots/community_team_tab.png)

### Members Tab
![Community Members Tab](./screenshots/community_members_tab.png)

---

## Features

- 🎬 **Community Video Feed** – Displays videos posted in the community using `ThreeSpeakVideoFeed`
- 📝 **About Tab** – Shows community description and metadata
- 👥 **Team Tab** – Lists community team members and their roles
- 👤 **Members Tab** – Paginated, scrollable list of all community members
- ❤️ **Favorite System** – Add/remove community from favorites
- 🔗 **Social Sharing** – RSS feed and community URL sharing
- 🚨 **Reporting** – Built-in report functionality

## Widget Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `communityId` | `String` | ✅ | The unique ID of the community (e.g., `hive-12345`). |
| `title` | `String` | ✅ | The display name/title of the community. |
| `onTapVideosTab` | `void Function(String, String)?` | ❌ | Called when the "Videos" tab is selected. |
| `onTapAboutTab` | `void Function(String, String)?` | ❌ | Called when the "About" tab is selected. |
| `onTapTeamTab` | `void Function(String, String)?` | ❌ | Called when the "Team" tab is selected. |
| `onTapMembersTab` | `void Function(String, String)?` | ❌ | Called when the "Members" tab is selected. |
| `onTapBookmark` | `void Function(String, String)?` | ❌ | Called when the user bookmarks/unbookmarks the community. |
| `onTapRssFeed` | `void Function(String, String)?` | ❌ | Called when the RSS feed icon is tapped. |
| `onTapShare` | `void Function(String, String)?` | ❌ | Called when the share icon is tapped. |
| `onTapReport` | `void Function(String, String)?` | ❌ | Called when the "Report" option is selected. |
| `onTapVideoItem` | `void Function(GQLFeedItem item)?` | ❌ | Called when a video item is tapped. |
| `onTapVideoReport` | `void Function(String, String)?` | ❌ | Called when the "Report" option is selected from a video item. |
| `onTapAuthor` | `void Function(String)?` | ❌ | Called when a user avatar is tapped. |

## Basic Usage

```dart
ThreespeakCommnuityScreen(
  communityId: 'hive-12345',
  title: 'My Community',
  onTapVideosTab: (id, tab) => print('Videos tab selected'),
  onTapAboutTab: (id, tab) => print('About tab selected'),
  onTapTeamTab: (id, tab) => print('Team tab selected'),
  onTapMembersTab: (id, tab) => print('Members tab selected'),
  onTapBookmark: (id, action) => print('Bookmark toggled'),
  onTapRssFeed: (id, action) => print('RSS feed tapped'),
  onTapShare: (id, action) => print('Share tapped'),
  onTapReport: (id, action) => print('Report tapped'),
  onTapVideoItem: (item) => print('Video tapped: ${item.permlink}'),
  onTapVideoReport: (author, permlink) => print('Video report: $author/$permlink'),
  onTapAuthor: (username) => print('Author tapped: $username'),
)
```

## Tab Structure

### 1. 🎥 Videos Tab
- Shows community video feed using `ThreeSpeakVideoFeed`
- Supports grid/list layouts and direct video playback

### 2. 📝 About Tab
- Displays community description, creation date, and metadata

### 3. 👥 Team Tab
- Lists team members and their roles in a responsive grid

### 4. 👤 Members Tab
- Shows all community members in a paginated, scrollable grid
- Loads more members as you scroll

## AppBar Actions

- **Favorite Toggle**: Add/remove community from favorites
- **RSS Share**: Share community RSS feed
- **Profile Share**: Share community profile URL
- **Report Menu**: Report community

## Notes

- The widget is designed for seamless integration in ThreeSpeak-style apps.
- All tabs and actions are customizable via the provided callbacks.
- The Members tab supports infinite scroll/pagination for large communities.

---
