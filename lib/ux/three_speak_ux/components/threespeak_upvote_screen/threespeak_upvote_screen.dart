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
          builder:
              (context) => FractionallySizedBox(
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

                        Navigator.of(context).pop(); // Close bottom sheet

                        if (response['success'] == true) {
                          if (onVoted != null) {
                            onVoted!(
                              response['success'],
                              "Upvote Success: Successfully upvoted $author/$permlink",
                            );
                          }
                        } else {
                          if (onVoted != null) {
                            onVoted!(
                              false,
                              "Upvote Failed: Could not upvote $author/$permlink",
                            );
                          }
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        if (onVoted != null) onVoted!(false, e.toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Upvote Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
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
