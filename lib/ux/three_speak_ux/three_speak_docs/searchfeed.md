# Search Screen Component

![Search Screen Preview](./searchscreen.png)

The `SearchScreen` component provides a comprehensive search interface for the ThreeSpeak platform, allowing users to search for videos with real-time search functionality, debounced input handling, and integrated video playback.

## Features

- 🔍 **Real-time Search** - Dynamic search with debounced input handling
- ⚡ **Performance Optimized** - 800ms debounce prevents excessive API calls
- 👤 **User Preview** - Shows user avatar when searching for usernames
- 🎬 **Video Integration** - Seamless video playback navigation
- 🧹 **Smart Input Handling** - Clear button and input validation
- 📱 **Responsive Design** - Adaptive layout for all screen sizes
- ⌨️ **Keyboard Friendly** - Optimized text input experience
- 🔄 **State Management** - Efficient state handling with timers
- 📊 **Feed Integration** - Uses `ThreeSpeakFeedList` for results display
- 🎯 **Minimum Character Requirement** - Prevents unnecessary searches

## Component Architecture

### Main Structure
```
SearchScreen
├── AppBar (Custom search input)
│   ├── TextField (Search input)
│   ├── PrefixIcon (User avatar for usernames)
│   └── SuffixIcon (Clear button)
└── Body (Search results)
    ├── Empty State (< 4 characters)
    └── ThreeSpeakFeedList (Search results)
```

### Key Components

#### 1. **Custom AppBar**
- **TextField Integration**: Search input directly in app bar
- **Dynamic Icons**: User avatar preview and clear functionality
- **Visual Feedback**: Real-time UI updates based on input

#### 2. **ThreeSpeakFeedList Integration**
- **Feed Type**: `ThreeSpeakFeedType.search`
- **Search Term**: Dynamic search query
- **Video Navigation**: Direct integration with video player

#### 3. **Debounced Search**
- **Timer Management**: 800ms delay for API optimization
- **Input Validation**: Minimum 4 characters required
- **State Synchronization**: Efficient state updates

## Basic Usage

### Simple Implementation
```dart
SearchScreen(
  loggedInUser: 'current_username',
)
```

### Navigation Integration
```dart
// Navigate to search screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SearchScreen(
      loggedInUser: currentUser.username,
    ),
  ),
);
```
## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `loggedInUser` | `String` | ✅ | Username of the currently logged-in user |

## Search Functionality

### Input Handling
- **Minimum Length**: 4 characters required to trigger search
- **Debounce Timer**: 800ms delay to prevent excessive API calls
- **Real-time Updates**: UI updates immediately on input change
- **Input Validation**: Trims whitespace and validates length

### Search Process Flow
1. User types in search field
2. Timer cancels previous search request
3. UI updates immediately (prefix/suffix icons)
4. If input < 4 characters, shows empty state
5. If input ≥ 4 characters, starts 800ms timer
6. Timer completes → triggers search API call
7. Results display in `ThreeSpeakFeedList`

### Search States
```dart
// Empty state (< 4 characters)
if (text.isEmpty) {
  return const Center(
    child: Text('Search videos by typing at least 4 characters.'),
  );
}

// Active search state (≥ 4 characters)
return ThreeSpeakFeedList(
  feedType: ThreeSpeakFeedType.search,
  searchTerm: text,
  onTapVideoItem: _handleVideoTap,
);
```

## Video Integration

### Video Playback Navigation
```dart
onTapVideoItem: (item) {
  final videoUrl = getVideoUrl(item);
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
      ),
    ),
  );
}
```

This component provides a complete search experience for the ThreeSpeak platform with optimized performance, intuitive user interface, and seamless integration with video playback functionality.