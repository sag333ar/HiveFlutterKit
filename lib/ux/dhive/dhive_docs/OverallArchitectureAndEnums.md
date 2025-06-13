# Overall Architecture and Enums

This document provides a high-level overview of the architecture and enum definitions used in the `hive_flutter_kit` UI system. These structures are designed to help developers quickly build user interfaces for interacting with the Hive blockchain.

---

## 🧱 Overall Architecture

The UI framework is organized into multiple component layers for modularity and reusability:

### Screens

Top-level widgets that represent complete user-facing views in the application.

* `AccountPostsScreen`
* `BlogScreen`
* `CommentsScreen`   
* `CommunityScreen`   
* `RepliesScreen`
* `TrendingFeedScreen`
* `UserProfilePicture`

These widgets fetch data from the Hive blockchain using the `HiveFlutterKitPlatform` and provide a consistent entry point for different types of feeds or views.

### Common Views

Reusable, lower-level components shared across screens to maintain design consistency and reduce redundancy.

* `ViewList`: Renders content in list, grid, or large card formats.
* `ViewComments`: Handles threaded comment/reply rendering.
* `BlogList`: Handles blog rendering.

## 🔢 Enums

### ViewMode

Defines the layout behavior for list-based widgets, such as feeds or comment sections.

* **Location:** `lib/ux/dhive/common/enum.dart`

#### Values

* `list`: Items are shown in a vertical list format.
* `grid`: Items are arranged in a grid with multiple columns.
* `large`: Each item is presented in a larger, card-style format with more metadata visible.

> **Note:** These modes are interpreted by components like `ViewList` and may be visually styled differently depending on the screen context.

---

## See Also

* `UserProfilePicture`
* `TrendingFeedScreen`
* `RepliesScreen`
* `HiveFlutterKitPlatform`
* `Discussion` Model
