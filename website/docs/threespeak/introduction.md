---
title: Intoduction to 3Speak
sidebar_label: Introduction
slug: /introduction
---

# 3Speak Integration with HiveFlutterKit

Welcome to the 3Speak integration documentation for HiveFlutterKit! 3Speak is a decentralized video hosting and sharing platform built on the Hive blockchain. HiveFlutterKit provides a suite of Flutter widgets that make it easy to incorporate 3Speak functionalities into your applications.

This section will give you an overview of the available UI components, including various video feeds, a robust video player, user account management, video uploading, and login mechanisms. Each component is designed for seamless integration and customization. Detailed information for each widget can be found on its dedicated page.

## Key Components

### 1. Video Feeds (`ThreeSpeakVideoFeed`)

Display dynamic lists of videos from the 3Speak platform.
-   **Types**: Trending, New Uploads, First Uploads, User-specific feeds, Community feeds, My Feed (followed users), Related videos, and feeds based on specific tags.
-   **Features**: Responsive layout (list/grid), search capabilities (built-in or external), customizable interaction callbacks.

*Screenshots showcasing different feed types:*

#### Trending Feed
![Trending Feed](/img/threespeak/trending.png)

#### Related Feed (Often shown with Video Player)
![Related Feed](/img/threespeak/related.png)

#### New Uploads Feed
![New Uploads Feed](/img/threespeak/newuploads.png)

#### First Uploads Feed
![First Uploads Feed](/img/threespeak/firstuploads.png)

#### User Feed
![User Feed](/img/threespeak/userfeed.png)

<!-- Add screenshot for My Feed if available -->
<!-- ![My Feed](/img/threespeak/myfeed.png) -->

<!-- Add screenshot for Community Feed if available -->
<!-- ![Community Feed](/img/threespeak/communityfeed.png) -->

---

### 2. Video Player (`VideoPlayerScreen`)

A comprehensive screen for playing 3Speak videos.
-   **Features**: Adaptive HLS streaming, IPFS URL resolution, Hive post integration (shows votes, allows interaction via callbacks), responsive layout for mobile/web, and an area to display a related video feed.

![Video Player Screen](/img/threespeak/videoplayer.png)

---

### 3. Video Search

Integrated within `ThreeSpeakVideoFeed` when `feedType` is `search` and `isSearch` is `true`.
-   **Features**: Provides an AppBar with a search input field, debounces search queries, and displays results.

![Search Screen](/img/threespeak/searchscreen.png)

---

### 4. Video Upload Workflow (`VideoUploadScreen`, `ThumbnailUploadScreen`, `UploadInfoScreen`)

A multi-step process to upload videos, thumbnails, and associated metadata to 3Speak.
-   **`VideoUploadScreen`**: Pick and upload `.mp4` or `.mov` video files using the TUS protocol.
-   **`ThumbnailUploadScreen`**: Upload a custom thumbnail for the video.
-   **`UploadInfoScreen`**: Add title, description, tags, and finalize the post.

*Screenshots of the upload workflow:*
![Video Upload Step 1](/img/threespeak/image.png)
![Thumbnail Upload Step 2](/img/threespeak/image-1.png)
![Video Info Step 3](/img/threespeak/image-2.png)

---

### 5. User Account Management (`ThreeSpeakCurrentUserAccount`)

A widget to display and manage the logged-in user's 3Speak content.
-   **Features**: Tabbed interface for "Publish Now" (videos ready to be published), "My Videos" (published videos), and "Encoding" (videos being processed). Includes user profile display and logout functionality.

<!-- Add screenshot for ThreeSpeakCurrentUserAccount if available -->
<!-- ![Current User Account Screen](/img/threespeak/current_user_account.png) -->
![Publish Videos Tab](/img/threespeak/image-3.png)
![My Videos Tab](/img/threespeak/image-4.png)
![Encoding Videos Tab](/img/threespeak/image-5.png)


---

### 6. Login (`ThreeSpeakLoginScreen`)

Handles authentication with 3Speak using Hive credentials.
-   **Features**: Supports Hive Keychain, HiveAuth, and private posting key methods. Integrates with the 3Speak mobile login API to obtain a JWT token for authenticated actions.

![Login Screen](/img/threespeak/login.png)

---

Explore the individual documentation pages for each component to learn more about their specific parameters, usage examples, and advanced features.
