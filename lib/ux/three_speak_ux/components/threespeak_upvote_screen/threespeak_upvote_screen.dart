import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/three_speak_core/services/api_service.dart';
import 'package:hive_flutter_kit/ux/upvote.dart';
import 'package:hive_flutter_kit/ux/upvote_bottomsheet.dart';

class ThreespeakUpvoteScreen extends StatelessWidget {
  final HiveFlutterKitPlatform hfk;
  final String author;
  final String permlink;
  final bool isContentVoted;
  final String currentUser;
  final String authToken;

  final Function(bool status, String? result)? onVoted;

  const ThreespeakUpvoteScreen({
    super.key,
    required this.hfk,
    required this.author,
    required this.permlink,
    required this.isContentVoted,
    required this.currentUser,
    required this.authToken,
    this.onVoted,
  });

  @override
  Widget build(BuildContext context) {
    return UpvoteBottomSheet(
      hfk: hfk,
      author: author,
      permlink: permlink,
      isContentVoted: isContentVoted,
      currentUser: currentUser,
      onClickUpvote: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false, // Prevent dismissing while loading
          enableDrag: false, // Prevent dragging while loading
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.5,
            child: Material(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: Colors.white,
              child: VoteBottomSheet(
                hfk: hfk,
                author: author,
                permlink: permlink,
                onClickUpvoteTap: (author, permlink, weight) async {
                  final apiService = ApiService();
                  
                  try {
                    final response = await apiService.handleUpvote(
                      author: author,
                      permlink: permlink,
                      weight: weight,
                      authToken: authToken,
                    );

                    // Close the vote bottom sheet
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }

                    if (response['success'] == true) {
                      // Close the upvote bottom sheet
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                      
                      if (onVoted != null) {
                        onVoted!(
                          response['success'],
                          "Upvote Success: Successfully upvoted $author/$permlink",
                        );
                      }
                    } else {
                      // Close the upvote bottom sheet on failure too
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                      
                      if (onVoted != null) {
                        onVoted!(
                          false,
                          "Upvote Failed: Could not upvote $author/$permlink",
                        );
                      }
                    }
                  } catch (e) {
                    // Close the vote bottom sheet on error
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                    
                    if (onVoted != null) {
                      onVoted!(false, e.toString());
                    }
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Upvote Error: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}