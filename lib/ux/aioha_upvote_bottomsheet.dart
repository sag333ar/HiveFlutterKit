import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/ux/aioha_upvote.dart';

class UpvoteBottomSheet extends StatelessWidget {
  final HiveFlutterKitPlatform aioha;
  final List<String> voters;
  final bool currentUserPresentInVoters;
  final bool isUserVoted;
  final String currentUser;
  final dynamic postInfo;
  final String author;
  final VoidCallback? onVoted;

  const UpvoteBottomSheet({
    Key? key,
    required this.aioha,
    required this.voters,
    required this.currentUserPresentInVoters,
    required this.isUserVoted,
    required this.currentUser,
    required this.postInfo,
    required this.author,
    this.onVoted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 30),
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Voters (${voters.length})",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (!isUserVoted)
              IconButton(
                onPressed: () {
                  if (currentUser.isEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
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

                  if (postInfo.activeVotes
                      .map((e) => e.voter)
                      .contains(currentUser)) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
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
                    builder: (context) => VoteDialog(
                      aioha: aioha,
                      author: author,
                      permlink: postInfo.permlink,
                      onVoted: () {
                        if (onVoted != null) onVoted!();
                      },
                    ),
                  );
                },
                icon: Icon(
                  Icons.thumb_up,
                  color: isUserVoted ? Colors.blue : Colors.grey,
                  size: 20,
                ),
              ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            itemCount: voters.length,
            itemBuilder: (context, index) {
              final isCurrentUser = index == 0 && currentUserPresentInVoters;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://images.hive.blog/160x40/https://images.hive.blog/u/${voters[index]}/avatar',
                  ),
                  radius: 15,
                ),
                title: Row(
                  children: [
                    Text(
                      voters[index],
                      style: TextStyle(
                        color: isCurrentUser ? Colors.blue : Colors.black,
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
              );
            },
          ),
        ),
      ],
    );
  }
}