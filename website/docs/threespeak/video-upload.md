---
title: Video Upload
sidebar_label: Video Upload
slug: /video-upload
---

# Video Upload


### Upload Video
![List View](/img/threespeak/image.png)

### Upload Thumbnail
![Grid View](/img/threespeak/image-1.png)

### Update Info
![Large Preview](/img/threespeak/image-2.png)

A Flutter widget for uploading videos to 3Speak, supporting both web and mobile platforms. The `VideoUploadScreen` provides a user-friendly interface for picking a video file, showing upload progress, and handling navigation to the next step (thumbnail upload) after a successful upload.

## Overview

The `VideoUploadScreen` is a stateful widget that allows users to select a video file (`.mp4` or `.mov`), displays a preview and upload progress, and uploads the file to the 3Speak server using the TUS protocol. After a successful upload, it navigates to the thumbnail upload screen.

---

## Usage Example

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VideoUploadScreen(
      owner: 'your-hive-username',
      token: 'your-auth-token',
      onUploadSuccess: (videoUrl, filename) {
        debugPrint('Upload successful: $videoUrl, $filename');
      },
    ),
  ),
);
```

## Widget Parameters

| Parameter         | Type                        | Required | Description                                                                 |
|-------------------|-----------------------------|----------|-----------------------------------------------------------------------------|
| `owner`           | `String`                    | ✅        | Hive username of the uploader.                                              |
| `token`           | `String`                    | ✅        | Authentication token for the upload endpoint.                               |
| `onUploadSuccess` | `UploadSuccessCallback?`    | ❌        | Callback invoked after successful upload and thumbnail step.                |

## Features

### 📹 Video Selection
- Supports picking `.mp4` and `.mov` files.
- Works on both web and mobile platforms.
- Shows file name and basic info after selection.

### ⏫ Upload Progress
- Uses the TUS protocol for resumable uploads.
- Shows a linear progress bar and percentage during upload.
- Handles upload errors and displays status messages.

### ➡️ Next Step Navigation
- On successful upload, navigates to the thumbnail upload screen (`ThumbnailUploadScreen`).
- Passes all necessary metadata (filename, size, duration, etc.) to the next step.

### 🖼️ Video Preview
- Shows a preview of the selected video before upload (if supported by platform).

## UI Preview

<!-- TODO: Insert screenshot of the VideoUploadScreen UI here -->
<!-- ![Video Upload UI](/img/threespeak/videoupload.png) -->

---

## Example Flow

1. User taps "Pick video" and selects a `.mp4` or `.mov` file.
2. The widget shows the selected file and a preview.
3. Upload starts automatically, showing progress.
4. On completion, the user is navigated to the thumbnail upload step.

---

## See Also

- [ThreeSpeakVideoFeed](/threespeak/video-feed.md)
- [VideoPlayerScreen](/threespeak/video-player.md)
