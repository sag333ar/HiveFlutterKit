---
title: 🎬 🔼 Video Upload
sidebar_label: 🎬 🔼 Video Upload
slug: /video-upload
---

# 🎬 🔼 3Speak Video Upload Workflow

The video upload process for 3Speak within HiveFlutterKit is a multi-step workflow facilitated by three main screen widgets:
1.  `VideoUploadScreen`: For picking and uploading the video file.
2.  `ThumbnailUploadScreen`: For uploading a custom thumbnail for the video.
3.  `UploadInfoScreen`: For adding title, description, tags, and other metadata before finalizing the video post.

This document focuses on `VideoUploadScreen`, the initial step in this workflow.

---

## `VideoUploadScreen`

![Video Upload Screen Preview](/img/threespeak/image.png)
*(Screenshot of the Video Upload Screen)*

This Flutter widget provides a user-friendly interface for selecting and uploading a video file to the 3Speak platform. It supports web and mobile, handles file type validation, shows upload progress, and navigates to the thumbnail upload step upon successful video upload.

### Overview

`VideoUploadScreen` is a stateful widget that allows users to:
-   Pick a video file using `file_picker`. Supported formats are `.mp4` and `.mov`.
-   View the name of the selected file and its size.
-   See a preview of the video (if a `VideoPlayerController` can be initialized for it).
-   Upload the video to the 3Speak server (`https://studio.3speak.tv/tus/`) using the TUS resumable upload protocol via the `another_tus_client` package.
-   Monitor the upload progress with a linear progress bar and percentage display.
-   Automatically navigate to `ThumbnailUploadScreen` upon successful video file upload, passing along necessary data like the video URL, filename, size, and duration.

### Usage Example

```dart
// Typically, you'd get the token after a user logs in via ThreeSpeakLoginScreen
// String userToken = "user_3speak_jwt_token";
// String hiveUsername = "users_hive_username";

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VideoUploadScreen(
      owner: hiveUsername, // The Hive username of the video owner
      token: userToken,    // The 3Speak JWT token for authentication
      onUploadSuccess: (response) {
        // This callback is triggered after the *entire* upload workflow is complete
        // (i.e., after UploadInfoScreen successfully posts the video details).
        // 'response' is the Map<String, dynamic> from the final API call in UploadInfoScreen.
        debugPrint('Entire video upload workflow successful!');
        debugPrint('API Response: $response');
        // Example: Show a success message or navigate to the user's videos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video successfully published: ${response['permlink']}')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst); // Go back to initial screen
      },
    ),
  ),
);
```

### Widget Parameters

| Parameter         | Type                               | Required | Description                                                                                                                                        |
|-------------------|------------------------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `owner`           | `String`                           | ✅        | The Hive username of the person uploading the video. This is used when finalizing the video details in subsequent steps.                             |
| `token`           | `String`                           | ✅        | The JWT authentication token obtained from 3Speak (e.g., after logging in via `ThreeSpeakLoginScreen`). This token is used to authorize the upload.    |
| `onUploadSuccess` | `UploadSuccessCallback?`           | ❌        | (Type: `void Function(Map<String, dynamic> response)?`) Callback invoked after the *entire* upload workflow (video, thumbnail, info) is successfully completed. The `response` object contains the final API response from 3Speak after publishing the video details. |

### Features

-   **📤 Cross-Platform File Picking**: Uses `file_picker` to allow video selection on web and mobile (Android/iOS).
-   **🎞️ Format Validation**: Restricts selection to `.mp4` and `.mov` video files.
-   **📊 Upload Progress**: Real-time feedback with a linear progress bar and percentage.
-   **🔄 Resumable Uploads**: Leverages the TUS protocol, which inherently supports resumable uploads (though `another_tus_client` configuration for persistence might be needed for full app-restart resumability).
-   **🖼️ Video Preview**: Attempts to initialize a `VideoPlayerController` to show a preview of the selected video and determine its duration.
-   **⚙️ Automatic Workflow Navigation**:
    -   On successful video file upload, it automatically pushes `ThumbnailUploadScreen`.
    -   It passes essential data like `uploadUrl` (TUS endpoint for the uploaded file), `filename` (server-generated), `oFilename` (original filename), `size`, `duration`, `owner`, and `token` to the next screen.
-   **💅 Clean UI**: Simple interface with clear "Pick video" and "Next" (or "Upload") buttons, and status messages.

### Workflow Steps Handled by `VideoUploadScreen`

1.  **Initialization**: Displays the UI with a "Pick video" button.
2.  **File Selection**: User taps "Pick video".
    -   `FilePicker.platform.pickFiles` is called.
    -   Validates file extension (`.mp4` or `.mov`).
    -   Updates state with `_selectedFile`, `_originalFileName`, `_fileSize`.
    -   Initializes `_videoController` to get `_videoDuration` and show a preview.
3.  **Upload Trigger**:
    -   User taps "Next" (or upload might start automatically after picking, as per current code).
    -   `_uploadFile()` is called.
4.  **TUS Upload**:
    -   A `TusClient` is initialized.
    -   `client.upload()` is called against `server.kThreeSpeakUploadUrl`.
    -   `onProgress` callback updates `_uploadProgress`.
    -   `onComplete` callback:
        -   Sets status to "Upload complete!".
        -   Extracts `videoUrl` and `videoFilename`.
        -   `Navigator.pushReplacement` to `ThumbnailUploadScreen`, passing all collected video data and authentication details.
5.  **Error Handling**: Catches exceptions during upload and updates `_status` to show an error message.

---
## Subsequent Screens in the Workflow

### `ThumbnailUploadScreen`

![Thumbnail Upload Screen Preview](/img/threespeak/image-1.png)
*(Screenshot of the Thumbnail Upload Screen)*

This widget is the second step in the 3Speak video upload workflow. It allows the user to select or generate a thumbnail for their video and upload it.

#### Overview

`ThumbnailUploadScreen` is a stateful widget that:
-   Receives the uploaded video's data from `VideoUploadScreen`.
-   Allows the user to pick a custom thumbnail from their device using `file_picker`.
-   Displays a preview of the selected thumbnail.
-   Uploads the thumbnail to the 3Speak server using the TUS protocol.
-   Shows upload progress for the thumbnail.
-   Upon successful upload, it sends the video and thumbnail information to the 3Speak API to link them.
-   Navigates to `UploadInfoScreen` on success.

#### Usage Example

This screen is intended to be pushed by `VideoUploadScreen` and is not typically instantiated directly.

#### Widget Parameters

| Parameter         | Type                               | Required | Description                                                                                                                                        |
|-------------------|------------------------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `uploadModel`     | `ThreeSpeakVideoUploadModel`       | ✅        | A model containing all the data from the previous step, including video URL, filename, size, duration, owner, and token.                            |
| `onThumbnailUpload`| `OnThumbnailUploadCallback`        | ✅        | A callback function that is executed upon successful thumbnail upload. It passes the updated `ThreeSpeakVideoUploadModel` to the next screen.      |

#### Features

-   **🖼️ Custom Thumbnail Selection**: Users can pick their own image file to be used as a thumbnail.
-   **📤 TUS-Based Upload**: Ensures reliable and resumable uploads for the thumbnail file.
-   **📊 Progress Indication**: Provides visual feedback on the thumbnail upload progress.
-   **🔗 API Integration**: Communicates with the 3Speak backend to associate the thumbnail with the video.
-   **Seamless Workflow**: Automatically transitions to the final step, `UploadInfoScreen`.

### `UploadInfoScreen`

![Upload Info Screen Preview](/img/threespeak/image-2.png)
*(Screenshot of the Upload Info Screen)*

This is the final screen in the video upload process, where the user adds all the metadata for the video.

#### Overview

`UploadInfoScreen` is a stateful widget where users can:
-   Enter the video's title, description, and tags.
-   Mark the content as NSFW (Not Safe for Work).
-   Choose reward options (e.g., 50%/50% or 100% Power Up).
-   Add beneficiaries to share post rewards.
-   Schedule the video for future publication.
-   Publish the video immediately.

#### Usage Example

This screen is part of the navigation flow from `ThumbnailUploadScreen`.

#### Widget Parameters

| Parameter         | Type                               | Required | Description                                                                                                                                        |
|-------------------|------------------------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `uploadModel`     | `ThreeSpeakVideoUploadModel`       | ✅        | The model containing all video and thumbnail data from the previous steps.                                                                         |
| `onUploadComplete`| `OnUploadCompleteCallback`         | ✅        | A callback function that is executed when the video is successfully published. It returns the final API response.                                 |

#### Features

-   **📝 Full Metadata Entry**: Comprehensive form for all necessary video details.
-   **🔞 NSFW Content Flag**: A simple checkbox to mark content as not safe for work.
-   **💰 Reward Options**: Switch to control post reward distribution (Power Up vs. liquid rewards).
-   **🤝 Beneficiaries Support**: Interface to add and manage reward beneficiaries.
-   **🗓️ Scheduling**: A date and time picker to schedule video publication.
-   **🚀 Immediate Publishing**: Option to publish the video right away.
-   **✅ Final API Call**: Submits all the information to the 3Speak backend to finalize the post.

---

## See Also

-   [ThreeSpeakLoginScreen](/docs/login) - For obtaining the `token` required by `VideoUploadScreen`.
-   [ThreeSpeakVideoFeed](/docs/video-feed-1) - For displaying video feeds.
-   [VideoPlayerScreen](/docs/video-player) - For playing uploaded videos.
-   `another_tus_client` package (for TUS protocol).
-   `file_picker` package (for picking video files).
-   `image_picker` package (used in `ThumbnailUploadScreen`).
