import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/provider/user_favourite_provider.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/user_channel_screen/user_channel_following.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/user_channel_screen/user_channel_profile.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_feed_list.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/custom_circle_avatar.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/favourite.dart';
import 'package:share_plus/share_plus.dart';

class UserChannelScreen extends StatefulWidget {
  const UserChannelScreen({
    super.key,
    required this.owner,
    this.onTapVideoIcon,
    this.onTapInfoIcon,
    this.onTapFollowers,
    this.onTapFollowing,
    this.onTapBookmark,
    this.onTapRssFeed,
    this.onTapShare,
    this.onTapReport,
    this.onTapVideoItem,
    this.onTapVideoReport,
    this.onTapAuthor,
  });

  final String owner;
  final void Function(String, String)? onTapVideoIcon;
  final void Function(String, String)? onTapInfoIcon;
  final void Function(String, String)? onTapFollowers;
  final void Function(String, String)? onTapFollowing;
  final void Function(String, String)? onTapBookmark;
  final void Function(String, String)? onTapRssFeed;
  final void Function(String, String)? onTapShare;
  final void Function(String, String)? onTapReport;
  final void Function(GQLFeedItem item)? onTapVideoItem;
  final void Function(String, String)? onTapVideoReport;
  final void Function(String)? onTapAuthor;

  @override
  _UserChannelScreenState createState() => _UserChannelScreenState();
}

class _UserChannelScreenState extends State<UserChannelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var currentIndex = 0;
  var userFavouriteProvider = UserFavoriteProvider();

  static List<Tab> tabs = [
    Tab(icon: Icon(Icons.video_camera_front_outlined)),
    Tab(icon: Icon(Icons.info)),
    Tab(text: 'Followers'),
    Tab(text: 'Following'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });

      final index = _tabController.index;

      switch (index) {
        case 0:
          widget.onTapVideoIcon?.call(widget.owner, "videos");
          break;
        case 1:
          widget.onTapInfoIcon?.call(widget.owner, "info");
          break;
        case 2:
          widget.onTapFollowers?.call(widget.owner, "followers");
          break;
        case 3:
          widget.onTapFollowing?.call(widget.owner, "following");
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        title: Row(
          children: [
            CustomCircleAvatar(
              height: 36,
              width: 36,
              url: server.userOwnerThumb(widget.owner),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.owner,
                style: TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          FavouriteWidget(
            toastType: "User",
            isLiked: userFavouriteProvider.isUserPresentLocally(widget.owner),
            onAdd: () {
              if (widget.onTapBookmark != null) {
                widget.onTapBookmark!(widget.owner, "add_bookmark");
              } else {
                userFavouriteProvider.storeLikedUserLocally(widget.owner);
              }
            },
            onRemove: () {
              if (widget.onTapBookmark != null) {
                widget.onTapBookmark!(widget.owner, "remove_bookmark");
              } else {
                userFavouriteProvider.storeLikedUserLocally(widget.owner);
              }
            },
          ),

          IconButton(
            onPressed: () {
              if (widget.onTapRssFeed != null) {
                widget.onTapRssFeed!(widget.owner, "rss");
              } else {
                Share.share("https://3speak.tv/rss/${widget.owner}.xml");
              }
            },
            icon: Icon(Icons.rss_feed),
          ),

          IconButton(
            onPressed: () {
              if (widget.onTapShare != null) {
                widget.onTapShare!(widget.owner, "share");
              } else {
                Share.share("https://3speak.tv/user/${widget.owner}");
              }
            },
            icon: Icon(Icons.share),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Report') {
                if (widget.onTapReport != null) {
                  widget.onTapReport!(widget.owner, "report");
                } else {
                  // fallback default report logic, if any
                  // for now, you might just show a simple dialog or snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reported ${widget.owner}')),
                  );
                }
              }
            },

            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'Report',
                    child: Text('Report', style: TextStyle(color: Colors.red)),
                  ),
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1st tab: Videos list
          ThreeSpeakFeedList(
            feedType: ThreeSpeakFeedType.userFeed,
            userChannel: widget.owner,
            onTapAuthor:
                widget.onTapAuthor != null
                    ? (item) => widget.onTapAuthor!(item.author?.username ?? '')
                    : null,
            onTapVideoItem: widget.onTapVideoItem,
            onTapReport:
                widget.onTapVideoReport != null
                    ? (item) => widget.onTapVideoReport!(
                      item.author?.username ?? '',
                      item.permlink ?? '',
                    )
                    : null,
          ),

          // 2nd tab: Bio, created at, and other info
          UserChannelProfileWidget(owner: widget.owner),
          // 3rd tab: Followers
          UserChannelFollowingWidget(owner: widget.owner, isFollowers: true),
          // 4th tab: Following
          UserChannelFollowingWidget(owner: widget.owner, isFollowers: false),
        ],
      ),
    );
  }
}
