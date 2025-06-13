import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/provider/content_favourite_provider.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/upvote_bottomsheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/hive_post_comments.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/favourite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoInfo extends StatefulWidget {
  final String title;
  final String author;
  final String permlink;
  final DateTime? createdAt;
  final GQLFeedItem video;
  final Discussion? postInfo;
  final String? currentUser;
  final bool isContentVoted;
  final void Function(String, String)? onTapComment;
  final void Function(String, String)? onTapUpvote;
  final void Function(String, String)? onTapShare;
  final void Function(String, String)? onTapBookmark;
  final void Function(String)? onTapAuthor;
  final void Function(String, String)? onTapInfo;

  const VideoInfo({
    super.key,
    required this.title,
    required this.author,
    required this.permlink,
    required this.createdAt,
    required this.video,
    required this.postInfo,
    required this.currentUser,
    required this.isContentVoted,
    this.onTapComment,
    this.onTapUpvote,
    this.onTapShare,
    this.onTapBookmark,
    this.onTapAuthor,
    this.onTapInfo,
  });

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

String extractFirstIfList(dynamic input) {
  if (input is List && input.isNotEmpty) {
    return input.first.toString(); // or input.first as String if you're sure
  }
  return input.toString(); // fallback for single strings or numbers
}

class _VideoInfoState extends State<VideoInfo> {
  final HiveFlutterKitPlatform hfk = HiveFlutterKitPlatform.instance;
  var contentFavoriteProvider = ContentFavoriteProvider();
  @override
  Widget build(BuildContext context) {
    final video = widget.video;
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
                    widget.onTapAuthor!(widget.author);
                  }
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
                              if (widget.onTapInfo != null) {
                                widget.onTapInfo!(
                                  widget.author,
                                  widget.permlink,
                                );
                              }
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
                                    widget.onTapComment!(
                                      widget.author,
                                      widget.permlink,
                                    );
                                  } else {
                                    // Default logic
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return FractionallySizedBox(
                                          heightFactor: 0.95,
                                          child: HivePostComments(
                                            author: widget.author,
                                            permlink: widget.permlink,
                                            onComment: null,
                                            onUpvoteComment: null,
                                            onReplyComment: null,
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
                                  if (widget.onTapUpvote != null) {
                                    widget.onTapUpvote!(
                                      widget.author,
                                      widget.permlink,
                                    );
                                    return;
                                  }
                                  if (widget.postInfo != null &&
                                      widget.currentUser != null) {
                                    List<String> voters = [];
                                    bool currentUserPresentInVoters = false;
                                    var activeVotes =
                                        widget.postInfo?.activeVotes ?? [];

                                    if (widget.currentUser!.isNotEmpty) {
                                      int userNameInVotesIndex = activeVotes
                                          .indexWhere(
                                            (element) =>
                                                element.voter ==
                                                widget.currentUser!,
                                          );
                                      if (userNameInVotesIndex != -1) {
                                        currentUserPresentInVoters = true;
                                        voters.add(widget.currentUser!);
                                        for (
                                          int i = 0;
                                          i < activeVotes.length;
                                          i++
                                        ) {
                                          if (i != userNameInVotesIndex) {
                                            voters.add(activeVotes[i].voter);
                                          }
                                        }
                                      } else {
                                        activeVotes.forEach((element) {
                                          voters.add(element.voter);
                                        });
                                      }
                                    } else {
                                      activeVotes.forEach((element) {
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
                                          hfk: hfk,
                                          voters: voters,
                                          currentUserPresentInVoters:
                                              currentUserPresentInVoters,
                                          isContentVoted: widget.isContentVoted,
                                          currentUser: widget.currentUser ?? "",
                                          postInfo: widget.postInfo,
                                          author: widget.author,
                                          onVoted: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Icon(
                                  widget.isContentVoted
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  size: 16,
                                  color:
                                      widget.isContentVoted
                                          ? Colors.blue
                                          : Colors.grey,
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
                              if (widget.onTapShare != null) {
                                widget.onTapShare!(
                                  widget.author,
                                  widget.permlink,
                                );
                              } else {
                                Share.share(
                                  "https://3speak.tv/user/${widget.author}/${widget.permlink}",
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
                            isLiked: contentFavoriteProvider
                                .isContentPresentLocally(
                                  extractFirstIfList(widget.author),
                                  extractFirstIfList(widget.permlink),
                                ),
                            onAdd: () {
                              contentFavoriteProvider.storeLikedContentLocally(
                                extractFirstIfList(widget.author),
                                extractFirstIfList(widget.permlink),
                              );
                            },
                            onRemove: () {
                              contentFavoriteProvider.storeLikedContentLocally(
                                extractFirstIfList(widget.author),
                                extractFirstIfList(widget.permlink),
                              );
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
