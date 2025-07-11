import 'package:flutter/material.dart';

void showVideoOptionsBottomSheet(BuildContext context, String videoId, Function(String) onDeleteConfirmed) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Video'),
              onTap: () {
                Navigator.pop(context);
                print('Edit video: $videoId');
                // TODO: Implement actual edit functionality or callback
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Video'),
              onTap: () {
                Navigator.pop(context);
                print('Share video: $videoId');
                // TODO: Implement actual share functionality or callback
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Video',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                showDeleteConfirmationDialog(context, videoId, onDeleteConfirmed);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

void showDeleteConfirmationDialog(BuildContext context, String videoId, Function(String) onDeleteConfirmed) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Video'),
        content: const Text(
          'Are you sure you want to delete this video? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onDeleteConfirmed(videoId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
