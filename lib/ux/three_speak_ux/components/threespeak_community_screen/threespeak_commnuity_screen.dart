import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_community_screen/community_about.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_community_screen/community_favourite_provider.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_community_screen/community_team.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_community_screen/communty_members.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/custom_circle_avatar.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/favourite.dart';
import 'package:share_plus/share_plus.dart';

class ThreespeakCommnuityScreen extends StatefulWidget {
  const ThreespeakCommnuityScreen({
    super.key,
    required this.communityId,
    required this.title,
    this.onTapVideosTab,
    this.onTapAboutTab,
    this.onTapTeamTab,
    this.onTapMembersTab,
    this.onTapBookmark,
    this.onTapRssFeed,
    this.onTapShare,
    this.onTapReport,
    this.onTapVideoItem,
    this.onTapVideoReport,
    this.onTapAuthor,
  });
  final String communityId;
  final String title;
  final void Function(String, String)? onTapVideosTab;
  final void Function(String, String)? onTapAboutTab;
  final void Function(String, String)? onTapTeamTab;
  final void Function(String, String)? onTapMembersTab;
  final void Function(String, String)? onTapBookmark;
  final void Function(String, String)? onTapRssFeed;
  final void Function(String, String)? onTapShare;
  final void Function(String, String)? onTapReport;
  final void Function(GQLFeedItem item)? onTapVideoItem;
  final void Function(String, String)? onTapVideoReport;
  final void Function(String)? onTapAuthor;

  @override
  _ThreespeakCommnuityScreenState createState() =>
      _ThreespeakCommnuityScreenState();
}

class _ThreespeakCommnuityScreenState extends State<ThreespeakCommnuityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var currentIndex = 0;
  final communityFavouriteProvider = CommunityFavouriteProvider();

  static List<Tab> tabs = [
    Tab(text: 'Videos'),
    Tab(text: 'About'),
    Tab(text: 'Team'),
    Tab(text: 'Members'),
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
          widget.onTapVideosTab?.call(widget.communityId, "videos");
          break;
        case 1:
          widget.onTapAboutTab?.call(widget.communityId, "about");
          break;
        case 2:
          widget.onTapTeamTab?.call(widget.communityId, "team");
          break;
        case 3:
          widget.onTapMembersTab?.call(widget.communityId, "members");
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
              url: server.userOwnerThumb(widget.communityId),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          FavouriteWidget(
            toastType: "community",
            isLiked: communityFavouriteProvider.isUserPresentLocally(
              widget.communityId,
            ),
            onAdd: () {
              if (widget.onTapBookmark != null) {
                widget.onTapBookmark!(widget.communityId, "add_bookmark");
              } else {
                communityFavouriteProvider.storeLikedCommunityLocally(
                  widget.communityId,
                );
              }
            },
            onRemove: () {
              if (widget.onTapBookmark != null) {
                widget.onTapBookmark!(widget.communityId, "remove_bookmark");
              } else {
                communityFavouriteProvider.storeLikedCommunityLocally(
                  widget.communityId,
                  forceRemove: true,
                );
              }
            },
          ),

          IconButton(
            onPressed: () {
              if (widget.onTapRssFeed != null) {
                widget.onTapRssFeed!(widget.communityId, "rss");
              } else {
                Share.share("https://3speak.tv/rss/${widget.communityId}.xml");
              }
            },
            icon: Icon(Icons.rss_feed),
          ),

          IconButton(
            onPressed: () {
              if (widget.onTapShare != null) {
                widget.onTapShare!(widget.communityId, "share");
              } else {
                Share.share("https://3speak.tv/user/${widget.communityId}");
              }
            },
            icon: Icon(Icons.share),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Report') {
                if (widget.onTapReport != null) {
                  widget.onTapReport!(widget.communityId, "report");
                } else {
                  // fallback default report logic, if any
                  // for now, you might just show a simple dialog or snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reported ${widget.communityId}')),
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
          ThreeSpeakVideoFeed(
            feedType: ThreeSpeakVideoFeedType.commnuityFeed,
            commnuityId: widget.communityId,
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
          CommunityAboutWidget(communityId: widget.communityId),
          CommunityTeamWidget(communityId: widget.communityId),
          CommunityMembersWidget(communityId: widget.communityId),
        ],
      ),
    );
  }
}
