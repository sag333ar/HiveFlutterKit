import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class HfkEquivalents extends StatefulWidget {
  const HfkEquivalents({super.key});

  @override
  State<HfkEquivalents> createState() => _HfkEquivalentsState();
}

class _HfkEquivalentsState extends State<HfkEquivalents> {

  late HiveFlutterKitPlatform hfk;

  @override
  void initState() {
    super.initState();
    hfk = HiveFlutterKitPlatform.instance;
  }

  Future<void> _getChainPropertieshfk() async {
    try {
      var result = await hfk.getChainProperties();
      debugPrint("hfk Chain Properties: $result");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chain Properties: $result')));
    } catch (e) {
      debugPrint('hfk getChainProperties error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chain Properties Error: $e')));
    }
  }

  Future<void> _getDiscussionshfk() async {
    try {
      final result = await hfk.getDiscussions(
        'trending',
        limit: 20,
        tag: '',
        startAuthor: null,
        startPermlink: null,
        observer: '',
      );
      for (var discussion in result) {
        final metadata = discussion.jsonMetadata;
        debugPrint('--- ${discussion.title} ---');
        debugPrint('--- ${discussion.community} ---');
        debugPrint('--- ${discussion.communityTitle} ---');
        debugPrint('Uplovte Count : ${discussion.stats?.totalVotes}');
        debugPrint('App: ${metadata?.app}');
        debugPrint('Tags: ${metadata?.tags?.join(', ') ?? 'none'}');
        debugPrint(
          'First image: ${metadata?.image?.isNotEmpty == true ? metadata!.image!.first : 'none'}',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched discussions (see debug output)')),
      );
    } catch (e) {
      debugPrint('hfk getDiscussions error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Discussions Error: $e')));
    }
  }

  Future<void> _getAccountshfk() async {
    try {
      var result = await hfk.getAccounts(['sagarkothari88']);
      for (var account in result) {
        debugPrint("Account: ${account.posting?.accountAuths}");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched accounts (see debug output)')),
      );
    } catch (e) {
      debugPrint('hfk getAccounts error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Accounts Error: $e')));
    }
  }

  Future<void> _getAccountPostshfk() async {
    try {
      String username = 'sagarkothari88';
      String sort = 'comments';
      var result = await hfk.getAccountPosts(
        username,
        limit: 20,
        sort,
        // observer: 'shaktimaaan',
        // startAuthor: 'sagarkothari88',
        // startPermlink: 're-sagarkothari88-20250204t071809647',
      );
      if (result.isEmpty) {
        debugPrint('No posts found.');
      } else {
        for (var post in result) {
          debugPrint('--- Post Debug Start ---');
          debugPrint('Author: ${post.author}');
          debugPrint('Title: ${post.title}');
          debugPrint('Permlink: ${post.permlink}');
          debugPrint('Author Reputation: ${post.authorReputation}');
          debugPrint('FirstRebloggedBy: ${post.firstRebloggedBy ?? "null"}');
          debugPrint('FirstRebloggedOn: ${post.firstRebloggedOn ?? "null"}');
          debugPrint('PendingPayoutValue: ${post.pendingPayoutValue}');
          debugPrint(
            'TotalPendingPayoutValue: ${post.totalPendingPayoutValue}',
          );
          debugPrint('Promoted: ${post.promoted}');
          debugPrint('RootTitle: ${post.rootTitle}');
          debugPrint('URL: ${post.url}');
          debugPrint('ActiveVotes Count: ${post.activeVotes?.length ?? 0}');
          debugPrint('Replies Count: ${post.replies?.length ?? 0}');
          debugPrint('RebloggedBy Count: ${post.rebloggedBy?.length ?? 0}');
          debugPrint('Beneficiaries Count: ${post.beneficiaries?.length ?? 0}');
          debugPrint('Payout : ${post.payout ?? 0}');
          debugPrint('Uplovte Count : ${post.stats?.totalVotes}');
          debugPrint('--- Post Debug End ---\n');
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched account posts (see debug output)')),
      );
    } catch (e) {
      debugPrint('hfk getAccountPosts error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get AccountPosts Error: $e')));
    }
  }

  Future<void> _getVotingPowerhfk() async {
    try {
      var result = await hfk.getVotingPower('sagarkothari88');
      debugPrint(
        "Voting Power: ${result.downvotePower}, ${result.upvotePower}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Voting Power: ${result.downvotePower}, ${result.upvotePower}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('hfk getVotingPower error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Voting Power Error: $e')));
    }
  }

  Future<void> _getResourceCreditshfk() async {
    try {
      var result = await hfk.getResourceCredits('sagarkothari88');
      debugPrint("Resources Credits Percentage: ${result.percentage}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resources Credits Percentage: ${result.percentage}'),
        ),
      );
    } catch (e) {
      debugPrint('hfk getResourceCredits error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Resource Credits Error: $e')));
    }
  }

  Future<void> _getCommentsListhfk() async {
    try {
      String author = 'cositav'; // Replace with actual video author
      String permlink = 'miwbidtw'; // Replace with actual video permlink

      final comments = await hfk.getCommentsList(author, permlink);

      if (comments.isEmpty) {
        debugPrint('No comments found.');
      } else {
        debugPrint('--- Comments Start ---');
        for (var comment in comments) {
          debugPrint('Author: ${comment.author}');
          debugPrint('Body: ${comment.body}'); // Full comment
          debugPrint('Permlink: ${comment.permlink}');
          debugPrint('Reputation: ${comment.authorReputation}');
          debugPrint('---');
        }
        debugPrint('--- Comments End ---');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${comments.length} comments')),
      );
    } catch (e) {
      debugPrint('hfk getCommentsList error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Comments Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hive Flutter Kit Equivalents')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- hfk equivalents for dhive UI ---
              ElevatedButton(
                child: Text('Get Chain Properties (hfk)'),
                onPressed: _getChainPropertieshfk,
              ),
              ElevatedButton(
                child: Text('Get Discussions (hfk)'),
                onPressed: _getDiscussionshfk,
              ),
              ElevatedButton(
                child: Text('Get Accounts (hfk)'),
                onPressed: _getAccountshfk,
              ),
              ElevatedButton(
                child: Text('Get AccountPosts (hfk)'),
                onPressed: _getAccountPostshfk,
              ),
              ElevatedButton(
                child: Text('Get Voting power (hfk)'),
                onPressed: _getVotingPowerhfk,
              ),
              ElevatedButton(
                child: Text('Resources Credits Percentage (hfk)'),
                onPressed: _getResourceCreditshfk,
              ),
              ElevatedButton(
                child: Text('Get Comments (hfk)'),
                onPressed: _getCommentsListhfk,
              ),

              // --- End hfk equivalents ---
          ],
        ),
      ),
    );
  }
}