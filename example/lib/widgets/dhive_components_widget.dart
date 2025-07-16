import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/ux/dhive/account_activities/account_activities.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/hive_post_comments.dart';
import 'package:hive_flutter_kit/ux/dhive/witnesses/witnesses.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/followers.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/followings.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/witness_votes.dart';
import 'package:hive_flutter_kit/ux/dhive/proposals/proposals.dart';
import 'package:hive_flutter_kit/ux/login_screen.dart';
import 'package:hive_flutter_kit/ux/switch_user.dart';
import 'package:hive_flutter_kit/ux/dhive/community_list/community_list.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/account_posts_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/blog_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/comments_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/community_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/replies_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/feed_screen/trending_feed_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/user_profile/user_profile_picture.dart';
import 'package:url_launcher/url_launcher.dart';


class DhiveComponentsWidget extends StatelessWidget {
  final HiveFlutterKitPlatform hfk;
  final VoidCallback getChainPropertieshfk;
  final VoidCallback getDiscussionshfk;
  final VoidCallback getAccountshfk;
  final VoidCallback getAccountPostshfk;
  final VoidCallback getVotingPowerhfk;
  final VoidCallback getResourceCreditshfk;
  final VoidCallback getFollowingsData; // This was a direct call, might need to be a navigation
  final VoidCallback getFollowersData;   // Same as above
  final VoidCallback getWitnessVotesData; // Same as above
  final VoidCallback getProposalsExample; // This was navigation
  final VoidCallback getContentExample; // This was navigation
  final VoidCallback getAccountHistoryExample; // This was navigation
  final VoidCallback checkThreespeakInAccountAuths; // This seems like a general utility, but keeping here for now
  final VoidCallback getCommentsListhfk;
  final VoidCallback fetchCommunities; // Initial fetch
  final Function(bool) fetchMoreCommunities; // For loading more
  final List<CommunityItem> communities;
  final bool isLoadingCommunities;
  final bool hasMoreCommunities;
  final VoidCallback getWitnessesByVote; // This was navigation

  // Controllers and simple action callbacks from home.dart that might be needed by these Dhive actions
  final TextEditingController usernameController; // e.g. for checkThreespeakInAccountAuths
  final Function(String) showSnackBar;


  const DhiveComponentsWidget({
    super.key,
    required this.hfk,
    required this.getChainPropertieshfk,
    required this.getDiscussionshfk,
    required this.getAccountshfk,
    required this.getAccountPostshfk,
    required this.getVotingPowerhfk,
    required this.getResourceCreditshfk,
    required this.getFollowingsData,
    required this.getFollowersData,
    required this.getWitnessVotesData,
    required this.getProposalsExample,
    required this.getContentExample,
    required this.getAccountHistoryExample,
    required this.checkThreespeakInAccountAuths,
    required this.getCommentsListhfk,
    required this.fetchCommunities,
    required this.fetchMoreCommunities,
    required this.communities,
    required this.isLoadingCommunities,
    required this.hasMoreCommunities,
    required this.usernameController,
    required this.showSnackBar,
    required this.getWitnessesByVote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text("Dhive Actions / Components", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        // --- hfk equivalents for dhive UI ---
        ElevatedButton(
          child: const Text('Get Chain Properties (hfk)'),
          onPressed: getChainPropertieshfk,
        ),
        ElevatedButton(
          child: const Text('Get Discussions (hfk)'),
          onPressed: getDiscussionshfk,
        ),
        ElevatedButton(
          child: const Text('Get Accounts (hfk)'),
          onPressed: getAccountshfk,
        ),
        ElevatedButton(
          child: const Text('Get AccountPosts (hfk)'),
          onPressed: getAccountPostshfk,
        ),
        ElevatedButton(
          child: const Text('Get Voting power (hfk)'),
          onPressed: getVotingPowerhfk,
        ),
        ElevatedButton(
          child: const Text('Resources Credits Percentage (hfk)'),
          onPressed: getResourceCreditshfk,
        ),

        ElevatedButton(
          onPressed: () { // Was getFollowingsData, now direct navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Followings(hfk: hfk, account: 'sagarkothari88'), // TODO: Parameterize account
              ),
            );
          },
          child: const Text("Get Followings Screen"),
        ),
        ElevatedButton(
          onPressed: () { // Was getFollowersData, now direct navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Followers(hfk: hfk, account: 'sagarkothari88'), // TODO: Parameterize account
              ),
            );
          },
          child: const Text("Get Followers Screen"),
        ),
        ElevatedButton(
          onPressed: () { // Was getWitnessVotesData, now direct navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WitnessVotes(hfk: hfk, account: 'sagarkothari88'), // TODO: Parameterize account
              ),
            );
          },
          child: const Text("Get Witness Votes Screen"),
        ),

        ElevatedButton(
          onPressed: () { // Was getProposalsExample, now direct navigation
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProposalsScreen(
                  hfk: hfk,
                  onTapUserAvatar: (creator) => debugPrint('User avatar tapped: $creator'),
                  onTapUsername: (creator) => debugPrint('Username tapped: $creator'),
                  onTapTitle: (subject, proposalId) => debugPrint('Title tapped: $subject #$proposalId'),
                  onTapStats: (proposalId) => debugPrint('Stats tapped for proposal: $proposalId'),
                  onTapUpvote: (proposalId) => debugPrint('Upvote tapped for proposal: $proposalId'),
                  onTapVoteValue: (proposalId, voteValue) => debugPrint('Vote value tapped for proposal: $proposalId, value: $voteValue'),
                  onTapSupport: (proposalId) => debugPrint('Support tapped for proposal: $proposalId'),
                ),
              ),
            );
          },
          child: const Text("Get Proposals Screen"),
        ),

        ElevatedButton(
          child: const Text('Get Account History Screen'),
          onPressed: () { // Was getAccountHistoryExample, now direct navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountActivities(
                  hfk: hfk,
                  account: 'sagarkothari88', // TODO: Parameterize account
                  isFilter: true,
                ),
              ),
            );
          },
        ),
        ElevatedButton(onPressed: getContentExample, child: const Text('Get Content Example (dhive)')),
        ElevatedButton(
          onPressed: checkThreespeakInAccountAuths, // This might move to a general utils/AuthService later
          child: const Text('Check threespeak in accountAuths'),
        ),
        ElevatedButton(
          child: const Text('Get Comments (hfk)'),
          onPressed: getCommentsListhfk,
        ),
        ElevatedButton(
          onPressed: fetchCommunities,
          child: const Text('Fetch Communities'),
        ),
        if (communities.isNotEmpty)
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: communities.length,
                itemBuilder: (context, index) {
                  final c = communities[index];
                  return ListTile(
                    title: Text(c.title ?? c.name ?? ''),
                    subtitle: Text(c.about ?? ''),
                  );
                },
              ),
              if (hasMoreCommunities)
                ElevatedButton(
                  onPressed: () => fetchMoreCommunities(true),
                  child: isLoadingCommunities
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load More Communities'),
                ),
            ],
          ),

        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(content: SwitchUser(hfk: hfk)),
            );
          },
          child: const Text('Switch User (Dialog)'),
        ),

        // CommunityScreen Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommunityScreen(
                  hfk: hfk,
                  sortBy: 'hot', // Example, can be parameterized
                  tag: 'hive-163772', // Example, can be parameterized
                  onTap: (Discussion discussion) async {
                     final url = discussion.url;
                      if (url != null) {
                        final fullUrl = Uri.parse('https://hive.blog$url');
                        if (await canLaunchUrl(fullUrl)) {
                          await launchUrl(fullUrl, mode: LaunchMode.externalApplication);
                        } else {
                          debugPrint('Could not launch $fullUrl');
                        }
                      }
                  },
                ),
              ),
            );
          },
          child: const Text('Go to Community Screen'),
        ),

        // AccountPostsScreen Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccountPostsScreen(
                  hfk: hfk,
                  account: 'sagarkothari88', // Example
                  onTap: (Discussion discussion) => debugPrint('Tapped on: ${discussion.title}'),
                ),
              ),
            );
          },
          child: const Text('Go to Account Posts Screen'),
        ),

        // CommentsScreen Button
         ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentsScreen(
                  hfk: hfk,
                  account: 'sagarkothari88', // Example
                  onTap: (Discussion discussion) => debugPrint('Tapped comment: ${discussion.title}'),
                ),
              ),
            );
          },
          child: const Text('Go to Comments Screen'),
        ),

        // BlogScreen Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlogScreen(
                  hfk: hfk,
                  account: 'techcoderx', // Example
                  onTap: (Discussion discussion) => debugPrint('Tapped on blog: ${discussion.title}'),
                ),
              ),
            );
          },
          child: const Text('Go to Blog Screen'),
        ),

        // RepliesScreen Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RepliesScreen(
                  hfk: hfk,
                  account: 'sagarkothari88', // Example
                  onTap: (Discussion discussion) => debugPrint('Tapped reply: ${discussion.title}'),
                ),
              ),
            );
          },
          child: const Text('Go to Replies Screen'),
        ),

        // TrendingFeedScreen Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrendingFeedScreen(
                  hfk: hfk,
                  onTap: (Discussion discussion) => debugPrint('Tapped feed item: ${discussion.title}'),
                ),
              ),
            );
          },
          child: const Text('Go to Trending Feed Screen'),
        ),

        // UserProfilePicture Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('User Profile')),
                  body: Center(
                    child: UserProfilePicture(
                      username: 'sagarkothari88', // Example
                      hfk: hfk,
                    ),
                  ),
                ),
              ),
            );
          },
          child: const Text('Go to User Profile Picture Screen'),
        ),

        // LoginScreen (hfk general) Button
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                insetPadding: EdgeInsets.zero,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: LoginScreen(hfk: hfk),
                ),
              ),
            );
          },
          child: const Text('hfk Login Screen (Dialog)'),
        ),

        // CommunitiesList Button
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                insetPadding: EdgeInsets.zero,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CommunitiesList(
                    onSelectCommunity: (community) async {
                      debugPrint('Selected community: ${community.name}');
                      Navigator.of(context).pop();
                    },
                    hfk: hfk,
                  ),
                ),
              ),
            );
          },
          child: const Text('Communities List (Dialog)'),
        ),

        // HivePostComments Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HivePostComments(
                  author: 'sagarkothari88', // Example
                  permlink: 'fuhitntzfw',   // Example
                ),
              ),
            );
          },
          child: const Text('Show HivePostComments Screen'),
        ),

        // Witnesses Button
        ElevatedButton(
          onPressed: () { // Was getWitnessesByVote
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Witnesses(
                  hfk: hfk,
                  onTapWitness: (account) => showSnackBar("Tapped on ${account.name}"),
                  onTapLink: (account) => showSnackBar("Link clicked for ${account.name}"),
                  onTapCheckmark: (account) => showSnackBar("Checkmark tapped for ${account.name}"),
                ),
              ),
            );
          },
          child: const Text('Get Witnesses Screen'),
        ),
        // ... (Add other Dhive related buttons/UI sections here)
      ],
    );
  }
}
