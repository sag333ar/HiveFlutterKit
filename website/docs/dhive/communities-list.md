---
title: 👥 📝 DHive's - Communities List
sidebar_label: 👥 📝 Communities List
slug: /dhive/communities-list
---

# 👥 📝 DHive's - Communities List

The `CommunitiesList` widget displays a list of Hive communities with search and infinite scrolling support. It is ideal for letting users select or browse communities interactively in your Flutter app.

---

## Screenshot

![CommunityListScreenshot](/img/dhive/image-15.png)

---

## Features

- 🔍 **Search bar** with live filtering
- 🔄 **Infinite scroll** for pagination
- ⚠️ **Error handling** and retry support
- 👆 **Tap to select** a community
- 🖼️ Shows **avatar, title, about text, and member count**

---

## Parameters

| Parameter           | Type                                   | Required | Description                                                   |
| ------------------- | -------------------------------------- | -------- | ------------------------------------------------------------- |
| `onSelectCommunity` | `Future<void> Function(CommunityItem)` | ✅       | Callback when a community is selected.                        |
| `hfk`               | `HiveFlutterKitPlatform`               | ✅       | Hive blockchain service instance for fetching community data.  |

---

## Usage Example

```dart
CommunitiesList(
  onSelectCommunity: (community) async {
    // Handle navigation or action with selected community
  },
  hfk: hiveFlutterKit,
)
```

---

## See Also

- [AccountPostsScreen](/dhive/account-posts-screen.md)
- [BlogScreen](/dhive/blog-screen.md)
- [Comments](/dhive/comments-screen.md)
- [Replies](/dhive/replies-screen.md)
- `Discussion` Model
- `CommunityItem` Model

---
