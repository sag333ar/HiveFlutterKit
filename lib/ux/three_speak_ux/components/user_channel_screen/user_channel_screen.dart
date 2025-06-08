import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/provider/user_favourite_provider.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/user_channel_screen/user_channel_following.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/user_channel_screen/user_channel_profile.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_feed_list.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/custom_circle_avatar.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/favourite.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/video_player.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/get_video_url.dart';
import 'package:share_plus/share_plus.dart';

class UserChannelScreen extends StatefulWidget {
  const UserChannelScreen({Key? key, required this.owner, this.loginModel})
    : super(key: key);

  final String owner;
  final LoginModel? loginModel;

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
              userFavouriteProvider.storeLikedUserLocally(widget.owner);
            },
            onRemove: () {
              userFavouriteProvider.storeLikedUserLocally(widget.owner);
            },
          ),
          IconButton(
            onPressed: () async {
              Share.share("https://3speak.tv/rss/${widget.owner}.xml");
            },
            icon: Icon(Icons.rss_feed),
          ),
          IconButton(
            onPressed: () async {
              Share.share("https://3speak.tv/user/${widget.owner}");
            },
            icon: Icon(Icons.share),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Add your report logic here if needed
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
          //ReportPopUpMenu(type: Report.user, author: widget.owner),
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
            onTapAuthor: (item) {
              // Optionally handle author tap, or leave null for default
            },
            onTapVideoItem: (item) {
              final videoUrl = getVideoUrl(item);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => VideoPlayerScreen(
                        videoUrl: videoUrl ?? '',
                        title: item.title ?? 'Untitled',
                        author: item.author?.username ?? 'Unknown',
                        permlink: item.permlink ?? 'Unknown',
                        createdAt: item.createdAt,
                        item: item,
                      ),
                ),
              );
            },
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
