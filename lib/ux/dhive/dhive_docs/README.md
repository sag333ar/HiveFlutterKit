# Dhive Widget Documentation

The Dhive widget is a Flutter component designed to interact with the Hive blockchain. It provides various UI elements and functionalities for displaying Hive content, user profiles, and facilitating user interactions.

## Overall Architecture

The widget is structured into several key components:

- **Screens:** These are top-level widgets that represent different views within the application, such as `TrendingFeedScreen`, `BlogScreen`, `CommentsScreen`, etc.
- **Common Views:** Reusable UI components like `ViewList` and `ViewComments` are used across different screens to maintain consistency.
- **User Profile:** Components like `UserProfilePicture` are dedicated to displaying user-specific information.
- **Common Enums:** The `ViewMode` enum (`lib/ux/dhive/common/enum.dart`) defines different layout options for displaying content.

## Components and Screens

### 1. TrendingFeedScreen

- **Purpose:** Displays a feed of trending posts from the Hive blockchain.
- **Functionality:**
    - Fetches and displays a list of discussions (posts) sorted by "trending".
    - Implements infinite scrolling to load more posts as the user scrolls.
    - Allows users to interact with posts through tapping, upvoting, downvoting, commenting, and reblogging.
- **Key Input Parameters:**
    - `dhive`: An instance of `HiveFlutterKitPlatform` for interacting with the Hive blockchain.
    - `onTap`: Callback function when a post is tapped.
    - `onAuthorTap`: Callback function when an author's name is tapped.
    - `onCategoryTap`: Callback function when a category is tapped.
    - `onUpvoteTap`: Callback function for upvoting.
    - `onDownVoteTap`: Callback function for downvoting.
    - `onCommentTap`: Callback function for commenting.
    - `onReblogTap`: Callback function for reblogging.
- **Usage Example:**
  ```dart
  TrendingFeedScreen(
    dhive: hiveFlutterKit, // Your HiveFlutterKitPlatform instance
    onTap: (discussion) {
      // Handle post tap
    },
    // ... other callbacks
  )
  ```
  **ScreenShots**
  ![List View ](trending-feed-1.png)
  ![Grid View](trending-feed-2.png)
  ![Large Preview](trending-feed-3.png)

### 2. UserProfilePicture

- **Purpose:** Displays a user's profile picture, username, and key statistics.
- **Functionality:**
    - Fetches and displays the user's avatar.
    - Shows the username.
    - Displays voting power (upvote and downvote) and resource credits percentage.
    - Optionally shows more details on tap.
- **Key Input Parameters:**
    - `username`: The Hive username of the user.
    - `dhive`: An instance of `HiveFlutterKitPlatform`.
    - `showDetails`: Boolean to initially show/hide detailed stats (default: `false`).
    - `showDetailsDisabled`: Boolean to disable the tap-to-show-details functionality (default: `false`).
    - `upvoteColor`: Color for the upvote power bar (default: `Colors.green`).
    - `downvoteColor`: Color for the downvote power bar (default: `Colors.red`).
    - `resourceCreditsColor`: Color for the resource credits bar (default: `Colors.blue`).
    - `showBars`: Boolean to show/hide the power bars (default: `true`).
    - `onTap`: Optional callback function when the profile picture area is tapped. If provided, it overrides the default behavior of toggling details.
- **Usage Example:**
  ```dart
  UserProfilePicture(
    username: "someuser",
    dhive: hiveFlutterKit, // Your HiveFlutterKitPlatform instance
    showDetails: true,
  )
  ```
  **ScreenShots**
  ![UserProfile](userProfile.png)

### 3. Account Post Screens

This set of screens is designed to display different types of posts related to a specific Hive account or community.

#### a. `AccountPostsScreen`
- **Purpose:** Displays a general list of posts for a given account. (Further details would require inspecting the file if specific parameters are needed).
- **ScreenShots**
  ![List View ](image.png)
  ![Grid View](image-1.png)
  ![Large Preview](image-2.png)


#### b. `BlogScreen`
- **Purpose:** Displays posts in a blog format, typically for a specific user.
- **Key Input Parameters (Assumed, verify by inspection if needed):**
    - `dhive`: `HiveFlutterKitPlatform` instance.
    - `username`: The username whose blog posts are to be displayed.
    - Callbacks for interactions similar to `TrendingFeedScreen`.
- **ScreenShots**
  ![List View ](image-3.png)
  ![Grid View](image-4.png)
  ![Large Preview](image-5.png)

#### c. `CommentsScreen`
- **Purpose:** Displays comments made on a specific post or by a specific user.
- **Key Input Parameters (Assumed, verify by inspection if needed):**
    - `dhive`: `HiveFlutterKitPlatform` instance.
    - `author` (optional): The author of the comments.
    - `permlink` (optional): The permlink of the post for which comments are displayed.
    - Callbacks for interactions.
- **ScreenShots**
  ![List View ](image-6.png)
  ![Grid View](image-7.png)
  ![Large Preview](image-8.png)

#### d. `CommunitySpecificScreen`
- **Purpose:** Displays posts related to a specific Hive community.
- **Key Input Parameters (Assumed, verify by inspection if needed):**
    - `dhive`: `HiveFlutterKitPlatform` instance.
    - `communityName`: The name of the community.
    - Callbacks for interactions.
- **ScreenShots**
  ![List View ](image-9.png)
  ![Grid View](image-10.png)
  ![Large Preview](image-11.png)

#### e. `RepliesScreen`
- **Purpose:** Displays replies to an account's posts or comments.
- **Key Input Parameters (Assumed, verify by inspection if needed):**
    - `dhive`: `HiveFlutterKitPlatform` instance.
    - `username`: The username whose replies are to be displayed.
    - Callbacks for interactions.
- **ScreenShots**
  ![List View ](image-12.png)
  ![Grid View](image-13.png)
  ![Large Preview](image-14.png)

### 4. ViewList

- **Purpose:** A reusable widget for displaying a list of Hive discussions.
- **Functionality:**
    - Renders a scrollable list of discussion items.
    - Integrates with a `ScrollController` to support infinite scrolling and pull-to-refresh.
    - Displays loading indicators when fetching more data.
    - Allows customization of tap actions on various parts of the discussion item.
- **Key Input Parameters:**
    - `discussions`: A list of `Discussion` objects to display.
    - `isLoadingMore`: Boolean indicating if more data is currently being loaded.
    - `hasMore`: Boolean indicating if there is more data to load.
    - `scrollController`: The `ScrollController` for the list view.
    - `amoutValues`: A list of strings representing payout values for each discussion.
    - `onTap`: Callback function when a discussion item is tapped.
    - `onAuthorTap`: Callback function when an author's name is tapped.
    - `onCategoryTap`: Callback function when a category is tapped.
    - `onUpvoteTap`: Callback function for upvoting.
    - `onDownVoteTap`: Callback function for downvoting.
    - `onCommentTap`: Callback function for commenting.
    - `onReblogTap`: Callback function for reblogging.
- **Usage Example:**
  ```dart
  // Typically used within screens like TrendingFeedScreen

  ViewList(
    discussions: discussionList,
    isLoadingMore: isLoading,
    hasMore: hasMoreData,
    scrollController: _scrollController,
    amoutValues: payoutValues,
    // ... other callbacks
  )
  ```

### 5. ViewComments

### 6. BlogList

**Note:** The specific parameters and detailed functionality for these screens would require individual inspection of their source code. The documentation above provides a general overview.

## Enums

### ViewMode

- **Path:** `lib/ux/dhive/common/enum.dart`
- **Purpose:** Defines different layout options for displaying lists of content.
- **Values:**
    - `list`: Displays items in a traditional list format.
    - `grid`: Displays items in a grid layout.
    - `large`: Displays items in a larger, more detailed format (e.g., cards with more content visible).

**Note:** The exact visual representation of each mode depends on how it's implemented in the respective list view components (e.g., `ViewList`).
