import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/account_history.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'filter_buttons.dart';

class AccountActivities extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final String account;
  final bool? isFilter;
  final Color? votesColor;
  final Color? commentsColor;
  final Color? repliesColor;
  final Color? rewardsColor;
  final Color? otherColor;
  final Color? authorRewardColor;
  final Color? curationRewardColor;
  final Color? benefactorRewardColor;

  const AccountActivities({
    super.key,
    required this.hfk,
    required this.account,
    this.isFilter,
    this.votesColor,
    this.commentsColor,
    this.repliesColor,
    this.rewardsColor,
    this.otherColor,
    this.authorRewardColor,
    this.curationRewardColor,
    this.benefactorRewardColor,
  });

  @override
  State<AccountActivities> createState() => _AccountActivitiesState();
}

class _AccountActivitiesState extends State<AccountActivities> {
  late Future<List<AccountHistoryOp>> _futureHistory;
  ActivityFilter? _selectedActivity;
  Set<RewardFilter> _selectedRewardFilters = {};

  @override
  void initState() {
    super.initState();
    _futureHistory = _fetchAccountHistory();
  }

  Future<List<AccountHistoryOp>> _fetchAccountHistory() async {
    try {
      return await widget.hfk.getAccountHistory(
        widget.account,
        index: -1,
        limit: 100,
        start: null,
        stop: null,
      );
    } catch (e) {
      // Rethrow to handle in FutureBuilder
      throw Exception('Failed to fetch account history: $e');
    }
  }

  bool _matchesActivityFilter(AccountHistoryOp op) {
    final detail = op.detail;
    if (detail?.op == null || detail!.op!.length != 2) return false;
    final opType = detail.op![0]?.toString() ?? '';
    switch (_selectedActivity) {
      case ActivityFilter.votes:
        return opType == 'vote';
      case ActivityFilter.comments:
        return opType == 'comment';
      case ActivityFilter.replies:
        // A reply is a comment with a non-empty parent_author
        if (opType == 'comment') {
          final payload = detail.op![1];
          if (payload is Map &&
              payload['parent_author'] != null &&
              payload['parent_author'].toString().isNotEmpty) {
            return true;
          }
        }
        return false;
      case ActivityFilter.rewards:
        return opType == 'author_reward' ||
            opType == 'curation_reward' ||
            opType == 'benefactor_reward';
      case ActivityFilter.other:
        return !(opType == 'vote' ||
            opType == 'comment' ||
            opType == 'author_reward' ||
            opType == 'curation_reward' ||
            opType == 'benefactor_reward');
      case null:
        return true;
    }
  }

  bool _matchesRewardFilter(AccountHistoryOp op) {
    if (_selectedActivity != ActivityFilter.rewards ||
        _selectedRewardFilters.isEmpty)
      return true;
    final detail = op.detail;
    if (detail?.op == null || detail!.op!.length != 2) return false;
    final opType = detail.op![0]?.toString() ?? '';
    if (_selectedRewardFilters.contains(RewardFilter.author) &&
        opType == 'author_reward')
      return true;
    if (_selectedRewardFilters.contains(RewardFilter.curation) &&
        opType == 'curation_reward')
      return true;
    if (_selectedRewardFilters.contains(RewardFilter.benefactor) &&
        opType == 'benefactor_reward')
      return true;
    return false;
  }

  IconData _activityIcon(String opType) {
    switch (opType) {
      case 'vote':
        return Icons.thumb_up_alt_rounded;
      case 'comment':
        return Icons.comment_rounded;
      case 'author_reward':
        return Icons.emoji_events_rounded;
      case 'curation_reward':
        return Icons.star_rounded;
      case 'benefactor_reward':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _activityColor(String opType) {
    switch (opType) {
      case 'vote':
        return Colors.blue.shade100;
      case 'comment':
        return Colors.green.shade100;
      case 'author_reward':
        return Colors.amber.shade100;
      case 'curation_reward':
        return Colors.purple.shade100;
      case 'benefactor_reward':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  String _formatTimeAgo(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dt = DateTime.tryParse(timestamp);
      if (dt == null) return timestamp;
      return timeago.format(dt, locale: 'en_short');
    } catch (_) {
      return timestamp;
    }
  }

  Widget _buildActivityList(List<AccountHistoryOp> history) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final op = history[index];
        final detail = op.detail;
        String opType = '';
        dynamic opPayload;
        if (detail?.op != null && detail!.op!.length == 2) {
          opType = detail.op![0]?.toString() ?? '';
          opPayload = detail.op![1];
        }
        final icon = _activityIcon(opType);
        final cardColor = _activityColor(opType);
        final block = detail?.block?.toString() ?? '-';
        final timeAgo = _formatTimeAgo(detail?.timestamp);
        String subtitle = '';
        if (opType == 'vote' && opPayload is Map) {
          subtitle =
              'Voted ${opPayload['weight']} for ${opPayload['author']}/${opPayload['permlink']}';
        } else if (opType == 'comment' && opPayload is Map) {
          subtitle = 'Commented: ${opPayload['title'] ?? ''}';
        } else if (opType.endsWith('_reward') && opPayload is Map) {
          subtitle = 'Reward: ${opPayload['reward'] ?? ''}';
        } else if (opPayload is Map && opPayload['permlink'] != null) {
          subtitle = 'Permlink: ${opPayload['permlink']}';
        } else {
          subtitle = opPayload?.toString() ?? '';
        }
        return Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.blueGrey.shade700),
            ),
            title: Text(
              opType.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                    child: Text(subtitle, style: const TextStyle(fontSize: 14)),
                  ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.confirmation_number,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Block $block',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            dense: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account Activities'),
          backgroundColor: Colors.blue.shade700,
          elevation: 1,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
            final showFilter = widget.isFilter ?? true;
            return Container(
              color: Colors.grey.shade100,
              child:
                  isDesktop
                      ? showFilter
                          ? Row(
                            children: [
                              // Activity List (80%)
                              Expanded(
                                flex: 4,
                                child: FutureBuilder<List<AccountHistoryOp>>(
                                  future: _futureHistory,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    }
                                    final history =
                                        (snapshot.data ?? [])
                                            .where(_matchesActivityFilter)
                                            .where(_matchesRewardFilter)
                                            .toList();
                                    if (history.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No account history found.',
                                        ),
                                      );
                                    }
                                    return _buildActivityList(history);
                                  },
                                ),
                              ),
                              // Filter Panel (20%)
                              Container(
                                width: constraints.maxWidth * 0.2,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 16,
                                ),
                                color: Colors.white,
                                child: SingleChildScrollView(
                                  child: FilterButtons(
                                    isFilter: showFilter,
                                    isDesktop: true,
                                    selectedActivity: _selectedActivity,
                                    selectedRewardFilters:
                                        _selectedRewardFilters,
                                    onActivityChanged: (activity) {
                                      setState(() {
                                        _selectedActivity = activity;
                                        if (activity !=
                                            ActivityFilter.rewards) {
                                          _selectedRewardFilters.clear();
                                        }
                                      });
                                    },
                                    onRewardFilterToggled: (reward) {
                                      setState(() {
                                        if (_selectedRewardFilters.contains(
                                          reward,
                                        )) {
                                          _selectedRewardFilters.remove(reward);
                                        } else {
                                          _selectedRewardFilters.add(reward);
                                        }
                                      });
                                    },
                                    votesColor: widget.votesColor,
                                    commentsColor: widget.commentsColor,
                                    repliesColor: widget.repliesColor,
                                    rewardsColor: widget.rewardsColor,
                                    otherColor: widget.otherColor,
                                    authorRewardColor: widget.authorRewardColor,
                                    curationRewardColor:
                                        widget.curationRewardColor,
                                    benefactorRewardColor:
                                        widget.benefactorRewardColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : // Desktop, no filter: show activities full width
                          FutureBuilder<List<AccountHistoryOp>>(
                            future: _futureHistory,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }
                              final history =
                                  (snapshot.data ?? [])
                                      .where(_matchesActivityFilter)
                                      .where(_matchesRewardFilter)
                                      .toList();
                              if (history.isEmpty) {
                                return const Center(
                                  child: Text('No account history found.'),
                                );
                              }
                              return _buildActivityList(history);
                            },
                          )
                      : Column(
                        children: [
                          if (showFilter) ...[
                            const SizedBox(height: 8),
                            FilterButtons(
                              isFilter: showFilter,
                              isDesktop: false,
                              selectedActivity: _selectedActivity,
                              selectedRewardFilters: _selectedRewardFilters,
                              onActivityChanged: (activity) {
                                setState(() {
                                  _selectedActivity = activity;
                                  if (activity != ActivityFilter.rewards) {
                                    _selectedRewardFilters.clear();
                                  }
                                });
                              },
                              onRewardFilterToggled: (reward) {
                                setState(() {
                                  if (_selectedRewardFilters.contains(reward)) {
                                    _selectedRewardFilters.remove(reward);
                                  } else {
                                    _selectedRewardFilters.add(reward);
                                  }
                                });
                              },
                              votesColor: widget.votesColor,
                              commentsColor: widget.commentsColor,
                              repliesColor: widget.repliesColor,
                              rewardsColor: widget.rewardsColor,
                              otherColor: widget.otherColor,
                              authorRewardColor: widget.authorRewardColor,
                              curationRewardColor: widget.curationRewardColor,
                              benefactorRewardColor:
                                  widget.benefactorRewardColor,
                            ),
                            const Divider(),
                          ],
                          Expanded(
                            child: FutureBuilder<List<AccountHistoryOp>>(
                              future: _futureHistory,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }
                                final history =
                                    (snapshot.data ?? [])
                                        .where(_matchesActivityFilter)
                                        .where(_matchesRewardFilter)
                                        .toList();
                                if (history.isEmpty) {
                                  return const Center(
                                    child: Text('No account history found.'),
                                  );
                                }
                                return _buildActivityList(history);
                              },
                            ),
                          ),
                        ],
                      ),
            );
          },
        ),
      ),
    );
  }
}
