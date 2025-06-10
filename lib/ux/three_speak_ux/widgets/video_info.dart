import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/hive_post_info.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/provider/user_favourite_provider.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/upvote_bottomsheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/comments/video_details_comments.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/favourite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoInfo extends StatefulWidget {
  final String title;
  final String author;
  final DateTime? createdAt;
  final GQLFeedItem video;
  final HivePostInfoPostResultBody? postInfo;
  final String currentUser;
  final LoginModel? loggedInUser;
  final UserFavoriteProvider userFavouriteProvider;
  final void Function(LoginModel? user)? onUserChanged;
  final void Function()? onLogout;
  final Future<void> Function()? reloadHiveInfo;
  final bool Function() isUserVoted;
  final void Function()? onTapComment;
  final void Function(String body)? onComment;
  final void Function(Discussion comment)? onUpvoteComment;
  final void Function(Discussion comment)? onReplyComment;
  final void Function()? onShare;
  final void Function(bool isLiked)? onBookmark;
  final void Function()? onTapAuthor; 

  const VideoInfo({
    super.key,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.video,
    required this.postInfo,
    required this.currentUser,
    required this.loggedInUser,
    required this.userFavouriteProvider,
    this.onUserChanged,
    this.onLogout,
    this.reloadHiveInfo,
    required this.isUserVoted,
    this.onTapComment,
    this.onComment,
    this.onUpvoteComment,
    this.onReplyComment,
    this.onShare,
    this.onBookmark,
    this.onTapAuthor, 
  });

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> {
  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final postInfo = widget.postInfo;
    final _currentUser = widget.currentUser;
    final isUserVoted = widget.isUserVoted();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (widget.onTapAuthor != null) {
                    widget.onTapAuthor!();
                  }
                  // else {
                  //   // Default: do nothing or implement navigation to author profile
                  // }
                },
                child: ClipOval(
                  child: CachedNetworkImage(
                    height: 40,
                    width: 40,
                    imageUrl: server.userOwnerThumb(widget.author),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '@${widget.author}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 16),
                          Text(
                            widget.createdAt != null
                                ? timeago.format(widget.createdAt!)
                                : 'Unknown',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 20,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              // TODO: Add info action
                            },
                            child: Icon(
                              Icons.info,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (widget.onTapComment != null) {
                                    widget.onTapComment!();
                                  } else {
                                    // Default logic
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return FractionallySizedBox(
                                          heightFactor: 0.95,
                                          child: VideoDetailsComments(
                                            author:
                                                video.author?.username ??
                                                'sagarkothari88',
                                            permlink:
                                                video.permlink ?? 'ctbtwcxbbd',
                                            onComment: widget.onComment,
                                            onUpvoteComment: widget.onUpvoteComment,
                                            onReplyComment: widget.onReplyComment,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Icon(
                                  Icons.comment,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${video.stats?.numComments ?? 0}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () async {
                                  final aioha = HiveFlutterKitPlatform.instance;
                                  if (postInfo != null) {
                                    List<String> voters = [];
                                    bool currentUserPresentInVoters = false;

                                    if (_currentUser.isNotEmpty) {
                                      int userNameInVotesIndex = postInfo
                                          .activeVotes
                                          .indexWhere(
                                            (element) =>
                                                element.voter == _currentUser,
                                          );
                                      if (userNameInVotesIndex != -1) {
                                        currentUserPresentInVoters = true;
                                        voters.add(_currentUser);
                                        for (
                                          int i = 0;
                                          i < postInfo.activeVotes.length;
                                          i++
                                        ) {
                                          if (i != userNameInVotesIndex) {
                                            voters.add(
                                              postInfo.activeVotes[i].voter,
                                            );
                                          }
                                        }
                                      } else {
                                        postInfo.activeVotes.forEach((element) {
                                          voters.add(element.voter);
                                        });
                                      }
                                    } else {
                                      postInfo.activeVotes.forEach((element) {
                                        voters.add(element.voter);
                                      });
                                    }

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (context) {
                                        return UpvoteBottomSheet(
                                          aioha: aioha,
                                          voters: voters,
                                          currentUserPresentInVoters:
                                              currentUserPresentInVoters,
                                          isUserVoted: isUserVoted,
                                          currentUser: _currentUser,
                                          postInfo: postInfo,
                                          author: widget.author,
                                          onVoted:
                                              () =>
                                                  widget.reloadHiveInfo
                                                      ?.call() ??
                                                  Navigator.pop(context),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Icon(
                                  isUserVoted
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  size: 16,
                                  color:
                                      isUserVoted ? Colors.blue : Colors.grey,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${video.stats?.numVotes ?? 0}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              if (widget.onShare != null) {
                                widget.onShare!();
                              } else {
                                Share.share(
                                  "https://3speak.tv/user/${widget.author}/${video.permlink}",
                                );
                              }
                            },
                            child: Icon(
                              Icons.share,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          FavouriteWidget(
                            toastType: "Video",
                            isLiked: widget.userFavouriteProvider
                                .isUserPresentLocally(widget.author),
                            onAdd: () {
                              if (widget.onBookmark != null) {
                                widget.onBookmark!(true);
                              } else {
                                widget.userFavouriteProvider
                                    .storeLikedUserLocally(widget.author);
                              }
                            },
                            onRemove: () {
                              if (widget.onBookmark != null) {
                                widget.onBookmark!(false);
                              } else {
                                widget.userFavouriteProvider
                                    .storeLikedUserLocally(widget.author);
                              }
                            },
                            iconSize: 16,
                            iconColor: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
