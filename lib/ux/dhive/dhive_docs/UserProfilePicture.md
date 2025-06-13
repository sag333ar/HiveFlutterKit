# UserProfilePicture

The `UserProfilePicture` widget is designed to display a Hive user's avatar along with their username and key account statistics, such as voting power and resource credits. It is often used in headers, profile pages, or user info popups.

---

## Features

* Fetches and shows the user's profile picture.
* Displays username with account stats.
* Shows upvote/downvote power and resource credits.
* Optional detail expansion via tap.

---

## Constructor

```dart
UserProfilePicture({
  required String username,
  required HiveFlutterKitPlatform dhive,
  bool showDetails = false,
  bool showDetailsDisabled = false,
  Color upvoteColor = Colors.green,
  Color downvoteColor = Colors.red,
  Color resourceCreditsColor = Colors.blue,
  bool showBars = true,
  void Function()? onTap,
})
```

## Parameters

| Parameter              | Type                     | Default        | Description                              |
| ---------------------- | ------------------------ | -------------- | ---------------------------------------- |
| `username`             | `String`                 | —              | Hive username to fetch and display       |
| `dhive`                | `HiveFlutterKitPlatform` | —              | Instance used to fetch user data         |
| `showDetails`          | `bool`                   | `false`        | Whether to initially show detailed stats |
| `showDetailsDisabled`  | `bool`                   | `false`        | Prevents toggling stats display on tap   |
| `upvoteColor`          | `Color`                  | `Colors.green` | Color of the upvote power bar            |
| `downvoteColor`        | `Color`                  | `Colors.red`   | Color of the downvote power bar          |
| `resourceCreditsColor` | `Color`                  | `Colors.blue`  | Color of the resource credits bar        |
| `showBars`             | `bool`                   | `true`         | Whether to show all progress bars        |
| `onTap`                | `Function()?`            | `null`         | Callback on tap; overrides detail toggle |

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart';

class ProfileHeader extends StatelessWidget {
  final HiveFlutterKitPlatform dhive;

  const ProfileHeader({super.key, required this.dhive});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: UserProfilePicture(
        username: "someuser",
        dhive: dhive,
        showDetails: true,
        showDetailsDisabled: false,
        upvoteColor: Colors.green,
        downvoteColor: Colors.red,
        resourceCreditsColor: Colors.blue,
        showBars: true,
        onTap: () {
          print("Profile tapped");
        },
      ),
    );
  }
}
```

---

## Screenshot

![UserProfile](userProfile.png)

---

## Notes

* If `onTap` is provided, it disables the built-in toggle for showing/hiding detailed stats.
* Ensure that `HiveFlutterKitPlatform` is initialized before using this widget.

---

## Related

* `RepliesScreen`
* `CommunityScreen`
* `Discussion` model
* `HiveFlutterKitPlatform`
* `TrendingFeedScreen`
