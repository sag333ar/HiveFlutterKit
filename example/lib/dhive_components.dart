import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/ux/dhive/account_activities/account_activities.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/account_posts_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/blog_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/comments_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/community_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/replies_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/hive_post_comments.dart';
import 'package:hive_flutter_kit/ux/dhive/community_list/community_list.dart';
import 'package:hive_flutter_kit/ux/dhive/feed_screen/trending_feed_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/user_profile/user_profile_picture.dart';
import 'package:url_launcher/url_launcher.dart';

class DhiveComponents extends StatefulWidget {
  const DhiveComponents({super.key});

  @override
  State<DhiveComponents> createState() => _DhiveComponentsState();
}

class _DhiveComponentsState extends State<DhiveComponents> {
  late HiveFlutterKitPlatform hfk;

  @override
  void initState() {
    super.initState();
    hfk = HiveFlutterKitPlatform.instance;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dhive Components')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: CommunityScreen(
                                  hfk: hfk,
                                  sortBy: 'trending',
                                  tag: 'hive-163772',
                                  onTap: (discussion) async {
                                    final url = discussion.url;
                                    if (url != null) {
                                      final fullUrl = Uri.parse(
                                        'https://hive.blog$url',
                                      );
                                      if (await canLaunchUrl(fullUrl)) {
                                        await launchUrl(
                                          fullUrl,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        debugPrint('Could not launch $fullUrl');
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Community (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CommunityScreen(
                                hfk: hfk,
                                sortBy: 'hot',
                                tag: 'hive-163772',
                                onTap: (discussion) async {
                                  final url = discussion.url;
                                  if (url != null) {
                                    final fullUrl = Uri.parse(
                                      'https://hive.blog$url',
                                    );
                                    if (await canLaunchUrl(fullUrl)) {
                                      await launchUrl(
                                        fullUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      debugPrint('Could not launch $fullUrl');
                                    }
                                  }
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Community'),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: AccountPostsScreen(
                                  hfk: hfk,
                                  account: 'sagarkothari88',
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped on: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Posts (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AccountPostsScreen(
                                hfk: hfk,
                                account: 'sagarkothari88',
                                onTap: (discussion) {
                                  debugPrint('Tapped on: ${discussion.title}');
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Posts'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: CommentsScreen(
                                  hfk: hfk,
                                  account: 'sagarkothari88',
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped comment: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Comments (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CommentsScreen(
                                hfk: hfk,
                                account: 'sagarkothari88',
                                onTap: (discussion) {
                                  debugPrint(
                                    'Tapped comment: ${discussion.title}',
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Comments'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: BlogScreen(
                                  hfk: hfk,
                                  account: 'sagarkothari88',
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped on blog: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Blog (Dialog)'),
                  ),
                  SizedBox(width: 20),
                  Text("Or"),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BlogScreen(
                                hfk: hfk,
                                account: 'techcoderx',
                                onTap: (discussion) {
                                  debugPrint(
                                    'Tapped on blog: ${discussion.title}',
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Blog'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: RepliesScreen(
                                  hfk: hfk,
                                  account: 'sagarkothari88',
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped reply: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Replies (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RepliesScreen(
                                hfk: hfk,
                                account: 'sagarkothari88',
                                onTap: (discussion) {
                                  debugPrint(
                                    'Tapped reply: ${discussion.title}',
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Replies'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: TrendingFeedScreen(
                                  hfk: hfk,
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped feed item: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Feed (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TrendingFeedScreen(
                                hfk: hfk,
                                onTap: (discussion) {
                                  debugPrint(
                                    'Tapped feed item: ${discussion.title}',
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Feed'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: UserProfilePicture(
                                    username: 'sagarkothari88',
                                    hfk: hfk,
                                    showDetails: true,
                                    onTap: () {
                                      debugPrint('Profile picture tapped!');
                                    },
                                  ),
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Profile (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('User Profile'),
                                ),
                                body: Center(
                                  child: UserProfilePicture(
                                    username: 'sagarkothari88',
                                    hfk: hfk,
                                    // showDetails: true,
                                    // showBars:false,
                                    // onTap: () {
                                    //   debugPrint('Tapped from full screen');
                                    // },
                                  ),
                                ),
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Profile'),
                  ),
                ],
              ),
              const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => Dialog(
                                insetPadding: EdgeInsets.zero,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: CommunitiesList(
                                    onSelectCommunity: (community) async {
                                      debugPrint(
                                        'Selected community: ${community.name}',
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    hfk: hfk,
                                  ),
                                ),
                              ),
                        );
                      },
                      child: const Text('Communities List'),
                    ),
                    ElevatedButton(
                child: Text('Get Account History'),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountActivities(
                        hfk: hfk,
                        account: 'sagarkothari88',
                        isFilter: true,
                      ),
                    ),
                  );
                }
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HivePostComments(
                            author: 'sagarkothari88', // Example author
                            permlink: 'fuhitntzfw', // Example permlink
                          ),
                    ),
                  );
                },
                child: const Text('Show HivePostComments'),
              ),
        ],
      ),
    );
  }
}