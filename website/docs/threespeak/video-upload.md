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

-   **Purpose**: Allows the user to pick and upload a thumbnail image for the video that was just uploaded.
-   **Receives**: Video URL, filename, original filename, size, duration, owner, token, and the `onUploadSuccess` callback from `VideoUploadScreen`.
-   **Functionality**:
    -   Uses `image_picker` to select an image.
    -   Uploads the image to a 3Speak endpoint (likely `server.kThreeSpeakThumbnailUploadUrl`).
    -   On successful thumbnail upload, navigates to `UploadInfoScreen`.

### `UploadInfoScreen`
![Upload Info Screen Preview](/img/threespeak/image-2.png)
*(Screenshot of the Upload Info Screen)*

-   **Purpose**: Allows the user to enter the video's title, description, tags, and set other publishing options.
-   **Receives**: Video filename, thumbnail URL (from previous step), owner, token, and the `onUploadSuccess` callback.
-   **Functionality**:
    -   Provides text fields for metadata.
    -   On submission, makes a final API call to 3Speak (likely `server.kVideoEncoreMessageAPiUrl`) to associate the metadata with the uploaded video and thumbnail, effectively publishing or preparing the video for publishing.
    -   If this final API call is successful, it invokes the `onUploadSuccess` callback (originally passed to `VideoUploadScreen`) with the API response.

---

## See Also

-   [ThreeSpeakLoginScreen](/docs/login) - For obtaining the `token` required by `VideoUploadScreen`.
-   [ThreeSpeakVideoFeed](/docs/video-feed-1) - For displaying video feeds.
-   [VideoPlayerScreen](/docs/video-player) - For playing uploaded videos.
-   `another_tus_client` package (for TUS protocol).
-   `file_picker` package (for picking video files).
-   `image_picker` package (used in `ThumbnailUploadScreen`).
