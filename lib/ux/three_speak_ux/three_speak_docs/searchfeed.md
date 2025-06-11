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

## Basic Usage

### Simple Implementation
```dart
SearchScreen(
  currentuser: 'current_username',
)
```

### Navigation Integration
```dart
late HiveFlutterKitPlatform hfk;
String username = await hfk.getCurrentUser();
username = username.replaceAll('"', '');
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SearchScreen(
      currentUser: username
    ),
  ),
);
```
## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currentUser` | `String` | ✅ | Username of the currently logged-in user |

## Search Functionality

### Input Handling
- **Minimum Length**: 4 characters required to trigger search
- **Debounce Timer**: 800ms delay to prevent excessive API calls
- **Real-time Updates**: UI updates immediately on input change
- **Input Validation**: Trims whitespace and validates length

### Search Process Flow
1. User types in search field
2. Timer cancels previous search request
3. UI updates immediately
4. If input < 4 characters, shows empty state
5. If input ≥ 4 characters, starts 800ms timer
6. Timer completes → triggers search API call
7. Results display in `ThreeSpeakFeedList`

This component provides a complete search experience for the ThreeSpeak platform with optimized performance, intuitive user interface, and seamless integration with video playback functionality.