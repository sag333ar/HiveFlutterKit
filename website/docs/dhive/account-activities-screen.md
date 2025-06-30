---
title: AccountActivities Widget
---

## AccountActivities Widget

The `AccountActivities` widget displays a list of account activities for a given Hive account. It allows users to view various types of activities such as votes, comments, replies, and rewards. The widget also provides filtering capabilities to narrow down the displayed activities.

### Parameters

The `AccountActivities` widget accepts the following parameters:

*   `hfk` (required): An instance of `HiveFlutterKitPlatform` used to fetch account history data.
*   `account` (required): The username of the Hive account whose activities are to be displayed.
*   `isFilter` (optional, bool): Determines whether the filter buttons are visible. Defaults to `true`.
*   `votesColor` (optional, Color): Custom color for vote activities.
*   `commentsColor` (optional, Color): Custom color for comment activities.
*   `repliesColor` (optional, Color): Custom color for reply activities.
*   `rewardsColor` (optional, Color): Custom color for reward activities.
*   `otherColor` (optional, Color): Custom color for other types of activities.
*   `authorRewardColor` (optional, Color): Custom color for author reward activities.
*   `curationRewardColor` (optional, Color): Custom color for curation reward activities.
*   `benefactorRewardColor` (optional, Color): Custom color for benefactor reward activities.
*   `fontColor` (optional, Color): Custom color for text elements.
*   `backgroundColors` (optional, List<Color>): A list of two colors for the background gradient. Defaults to a dark or light theme based on the current context.

### Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart'; // Assuming hfk is available here
import 'package:your_app/path_to/account_activities.dart'; // Adjust path as necessary

class MyScreen extends StatelessWidget {
  final HiveFlutterKitPlatform hfk = HiveFlutterKit(); // Initialize your hfk instance
  final String accountName = 'guest123'; // Example account

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Activities for $accountName'),
      ),
      body: AccountActivities(
        hfk: hfk,
        account: accountName,
      ),
    );
  }
}
```

### Filtering

The widget includes built-in filtering capabilities:

*   **ActivityFilter**: Users can filter activities by type:
    *   `votes`: Shows only vote operations.
    *   `comments`: Shows only comment operations (excluding replies).
    *   `replies`: Shows only reply operations (comments with a `parent_author`).
    *   `rewards`: Shows only reward-related operations (`author_reward`, `curation_reward`, `benefactor_reward`).
    *   `other`: Shows all other types of operations not covered by the above.
    *   If no activity filter is selected, all activities are shown.

*   **RewardFilter**: When `ActivityFilter.rewards` is selected, users can further filter by specific reward types:
    *   `author`: Shows only author rewards.
    *   `curation`: Shows only curation rewards.
    *   `benefactor`: Shows only benefactor rewards.
    *   Multiple reward filters can be selected simultaneously. If no reward filter is selected while the `rewards` activity filter is active, all reward types are shown.

The filter buttons are displayed by default (`isFilter: true`). They can be hidden by setting `isFilter: false`. The layout of the filter buttons adapts based on whether the app is running on a desktop or mobile-sized screen.

### Dependencies and Setup

*   **`hive_flutter_kit`**: This widget relies on the `hive_flutter_kit` package to fetch account history data. Ensure this package is correctly installed and set up in your Flutter project.
*   **`timeago`**: Used for formatting timestamps into a human-readable "time ago" format.
*   **`flutter/material.dart`**: Standard Flutter Material components.

Ensure that an instance of `HiveFlutterKitPlatform` is properly initialized and passed to the `AccountActivities` widget. The widget handles fetching the data asynchronously and displays loading and error states appropriately.
