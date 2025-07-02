import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/pending_reward.dart';
import 'package:hive_flutter_kit/ux/dhive/pending_reward/calculate_total_author_values.dart';
import 'package:hive_flutter_kit/ux/dhive/pending_reward/calculated_total_curation_values.dart';
import 'package:hive_flutter_kit/ux/dhive/pending_reward/rewards_table.dart';

class PotentialRewardsWidget extends StatefulWidget {
  final String username;
  final HiveFlutterKitPlatform hfk;
  final String type; // 'author' or 'curation'

  const PotentialRewardsWidget({
    super.key,
    required this.username,
    required this.hfk,
    required this.type,
  });

  @override
  State<PotentialRewardsWidget> createState() => _PotentialRewardsWidgetState();
}

class _PotentialRewardsWidgetState extends State<PotentialRewardsWidget> {
  bool isLoading = true;
  List<Map<String, dynamic>> rewardsData = [];
  Map<String, String> totals = {};

  @override
  void initState() {
    super.initState();
    _fetchRewards();
  }

  Future<void> _fetchRewards() async {
    setState(() => isLoading = true);
    try {
      final isAuthor = widget.type == 'author';

      if (isAuthor) {
        final PendingAuthorRewardData data = await widget.hfk
            .getPendingAuthorRewardData(widget.username);

        final List<PendingRewardEntry> posts = data.posts ?? [];
        final List<PendingRewardEntry> comments = data.comments ?? [];
        final List<PendingRewardEntry> entries = [...posts, ...comments];

        final List<Map<String, dynamic>> formatted =
            entries.map((e) {
              final payoutDate =
                  DateTime.tryParse(e.payDate ?? '') ?? DateTime.now();
              final now = DateTime.now();
              final diff = payoutDate.difference(now);

              String payoutIn =
                  diff.inDays > 0
                      ? '${diff.inDays}d'
                      : diff.inHours > 0
                      ? '${diff.inHours}h'
                      : '${diff.inMinutes}m';

              return {
                'type': posts.contains(e) ? 'Post' : 'Comment',
                'title': e.link ?? '',
                'createdDate': e.created ?? '',
                'payoutIn': payoutIn,
                'postReward': e.amount ?? '0.000 HBD',
                'payDate': e.payDate ?? '',
              };
            }).toList();

        // Filter expired
        formatted.removeWhere((item) {
          final payDate = DateTime.tryParse(item['payDate']) ?? DateTime.now();
          return payDate.isBefore(DateTime.now());
        });

        // Sort
        formatted.sort(
          (a, b) => DateTime.parse(
            b['payDate'],
          ).compareTo(DateTime.parse(a['payDate'])),
        );

        if (mounted) {
          setState(() {
            rewardsData = formatted;
            totals = calculateTotalsAuthorReward(formatted);
            isLoading = false;
          });
        }
      } else {
        final PendingCurationRewardData data = await widget.hfk
            .getPendingCurationRewardData(widget.username);

        final List<PendingRewardEntry> entries = data.curation ?? [];

        final List<Map<String, dynamic>> formatted =
            entries.map((e) {
              final payoutDate =
                  DateTime.tryParse(e.payDate ?? '') ?? DateTime.now();
              final now = DateTime.now();
              final diff = payoutDate.difference(now);

              String payoutIn =
                  diff.inDays > 0
                      ? '${diff.inDays}d'
                      : diff.inHours > 0
                      ? '${diff.inHours}h'
                      : '${diff.inMinutes}m';

              return {
                'type': 'Post',
                'title': e.link ?? '',
                'createdDate': e.created ?? '',
                'payoutIn': payoutIn,
                'postReward': e.amount ?? '0.000 HBD',
                'payDate': e.payDate ?? '',
              };
            }).toList();

        formatted.removeWhere((item) {
          final payDate = DateTime.tryParse(item['payDate']) ?? DateTime.now();
          return payDate.isBefore(DateTime.now());
        });

        formatted.sort(
          (a, b) => DateTime.parse(
            b['payDate'],
          ).compareTo(DateTime.parse(a['payDate'])),
        );

        if (mounted) {
          setState(() {
            rewardsData = formatted;
            totals = calculateTotalsCurationReward(formatted);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading rewards: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return isLoading
        ? const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        )
        : Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.type == 'author'
                      ? 'Pending Author Rewards'
                      : 'Pending Curation Rewards',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                RewardsTable(
                  authorRewardsData: rewardsData,
                  totals: totals,
                  isMobileView: isMobile,
                ),
              ],
            ),
          ),
        );
  }
}
