import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/ux/upvote.dart';
import 'package:timeago/timeago.dart' as timeago;

class UpvoteBottomSheet extends StatelessWidget {
  final HiveFlutterKitPlatform hfk;
  final String author;
  final String permlink;
  final bool isContentVoted;
  final String currentUser;

  final VoidCallback? onVoted;

  const UpvoteBottomSheet({
    super.key,
    required this.hfk,
    required this.author,
    required this.permlink,
    required this.isContentVoted,
    required this.currentUser,
    this.onVoted,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActiveVote>>(
      future: hfk.getActiveVotes(author, permlink),
      builder: (context, snapshot) {
        List<ActiveVote> votes = snapshot.data ?? [];
        // Sort by time descending (most recent first)
        votes.sort((a, b) {
          DateTime? aTime, bTime;
          try {
            if (a.time != null && a.time!.isNotEmpty) {
              var aStr = a.time!;
              if (!aStr.endsWith('Z')) aStr = aStr + 'Z';
              aTime = DateTime.tryParse(aStr);
            }
            if (b.time != null && b.time!.isNotEmpty) {
              var bStr = b.time!;
              if (!bStr.endsWith('Z')) bStr = bStr + 'Z';
              bTime = DateTime.tryParse(bStr);
            }
          } catch (_) {}
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        final voters = votes.map((e) => e.voter).toList();
        final currentUserPresentInVoters =
            currentUser.isNotEmpty && voters.contains(currentUser);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                "Voters (${votes.length})",
                style: TextStyle(color: Colors.black),
              ),
              leading: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (!isContentVoted)
                  IconButton(
                    onPressed: () {
                      // Handle both "" and error json for currentUser
                      bool isNotLoggedIn =
                          currentUser.isEmpty ||
                          currentUser.trim() ==
                              '{"error":"No user is currently logged in"}';
                      if (isNotLoggedIn) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You are not logged in. Please log in first to vote for this video.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.blue,
                          ),
                        );
                        return;
                      }

                      if (votes.any((e) => e.voter == currentUser)) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You have already voted for this video',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder:
                            (context) => VoteDialog(
                              hfk: hfk,
                              author: author,
                              permlink: permlink,
                              onVoted: () {
                                if (onVoted != null) onVoted!();
                              },
                            ),
                      );
                    },
                    icon: Icon(
                      Icons.thumb_up,
                      color: isContentVoted ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                  ),
              ],
            ),
            Expanded(
              child:
                  snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 15,
                        ),
                        itemCount: votes.length,
                        itemBuilder: (context, index) {
                          final vote = votes[index];
                          final isCurrentUser = vote.voter == currentUser;
                          String? timeAgo;
                          if (vote.time != null && vote.time!.isNotEmpty) {
                            // Ensure 'Z' at the end for UTC
                            String timeStr = vote.time!;
                            if (!timeStr.endsWith('Z')) {
                              timeStr = '${timeStr}Z';
                            }
                            try {
                              final dt = DateTime.parse(timeStr);
                              timeAgo = timeago.format(dt);
                            } catch (_) {
                              timeAgo = vote.time;
                            }
                          }
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://images.hive.blog/160x40/https://images.hive.blog/u/${vote.voter}/avatar',
                              ),
                              radius: 15,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  vote.voter,
                                  style: TextStyle(
                                    color:
                                        isCurrentUser
                                            ? Colors.blue
                                            : Colors.black,
                                  ),
                                ),
                                if (isCurrentUser)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "(You've already voted for this content)",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  "${((vote.percent ?? 0) / 100).toStringAsFixed(0)}%",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(width: 12),
                                if (timeAgo != null)
                                  Text(
                                    timeAgo,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            // trailing: Text(
                            //   vote.rshares.toString(),
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }
}
