---
title: ⚙️ Extra Utilities
sidebar_label: ⚙️ Extra Utilities
slug: /extra-utilities
---

## ⚙️ Extra utilities that Hive Flutter Kit has to offer

---

### Upload Image
`uploadImage({required Uint8List imageBytes, required String fileName, required String token, required String uploadUrlSever})`

*   **Description:** Uploads an image to a specified server.
*   **Parameters:**
    *   `imageBytes` (required Uint8List): The byte data of the image.
    *   `fileName` (required String): The name of the file (e.g., "image.jpg").
    *   `token` (required String): An authentication token or signed message required by the upload server.
    *   `uploadUrlSever` (required String): The base URL of the image upload server.
*   **Returns:** `Future<String>`: A future that resolves to the URL of the uploaded image.
*   **Throws:** `Exception` if the upload fails or the server returns an error.

---

### Pick Image With Max Size
`pickImageWithMaxSize(int maxDimension, String uploadUrlSever)`

*   **Description:** Allows the user to pick an image from the gallery, checks its dimensions, signs a message (presumably for authentication with the upload server), and then uploads it using `uploadImage`.
*   **Parameters:**
    *   `maxDimension` (`int`): The maximum allowed width or height for the image.
    *   `uploadUrlSever` (`String`): The base URL of the image upload server.
*   **Returns:** `Future<String>`: A future that resolves to the URL of the uploaded image.
*   **Throws:** `Exception` if no image is selected, if image decoding fails, if the image is too large, or if signing/uploading fails.

---
