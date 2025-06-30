import 'package:flutter/material.dart';

enum ActivityFilter { votes, comments, replies, rewards, other }

enum RewardFilter { author, curation, benefactor }

class FilterButtons extends StatelessWidget {
  final bool isFilter;
  final bool isDesktop;
  final ActivityFilter? selectedActivity;
  final Set<RewardFilter> selectedRewardFilters;
  final ValueChanged<ActivityFilter?> onActivityChanged;
  final ValueChanged<RewardFilter> onRewardFilterToggled;
  final Color? votesColor;
  final Color? commentsColor;
  final Color? repliesColor;
  final Color? rewardsColor;
  final Color? otherColor;
  final Color? authorRewardColor;
  final Color? curationRewardColor;
  final Color? benefactorRewardColor;

  const FilterButtons({
    super.key,
    required this.isFilter,
    required this.isDesktop,
    required this.selectedActivity,
    required this.selectedRewardFilters,
    required this.onActivityChanged,
    required this.onRewardFilterToggled,
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
  Widget build(BuildContext context) {
    if (!isFilter) return const SizedBox.shrink();

    // Use provided colors or fallback to defaults
    final _votesColor = votesColor ?? Colors.blue.shade200;
    final _commentsColor = commentsColor ?? Colors.green.shade200;
    final _repliesColor = repliesColor ?? Colors.teal.shade200;
    final _rewardsColor = rewardsColor ?? Colors.amber.shade200;
    final _otherColor = otherColor ?? Colors.grey.shade400;
    final _authorRewardColor = authorRewardColor ?? Colors.amber.shade300;
    final _curationRewardColor = curationRewardColor ?? Colors.purple.shade200;
    final _benefactorRewardColor =
        benefactorRewardColor ?? Colors.orange.shade200;

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(
              Icons.thumb_up_alt_rounded,
              color: Colors.blue.shade700,
            ),
            title: const Text('Votes'),
            selected: selectedActivity == ActivityFilter.votes,
            selectedTileColor: _votesColor,
            onTap: () => onActivityChanged(ActivityFilter.votes),
          ),
          ListTile(
            leading: Icon(Icons.comment_rounded, color: Colors.green.shade700),
            title: const Text('Comments'),
            selected: selectedActivity == ActivityFilter.comments,
            selectedTileColor: _commentsColor,
            onTap: () => onActivityChanged(ActivityFilter.comments),
          ),
          ListTile(
            leading: Icon(Icons.reply_rounded, color: Colors.teal.shade700),
            title: const Text('Replies'),
            selected: selectedActivity == ActivityFilter.replies,
            selectedTileColor: _repliesColor,
            onTap: () => onActivityChanged(ActivityFilter.replies),
          ),
          ExpansionTile(
            leading: Icon(
              Icons.emoji_events_rounded,
              color: Colors.amber.shade700,
            ),
            title: const Text('Rewards'),
            initiallyExpanded: selectedActivity == ActivityFilter.rewards,
            onExpansionChanged: (expanded) {
              onActivityChanged(expanded ? ActivityFilter.rewards : null);
            },
            children: [
              CheckboxListTile(
                title: const Text('Author Rewards'),
                value: selectedRewardFilters.contains(RewardFilter.author),
                onChanged:
                    selectedActivity == ActivityFilter.rewards
                        ? (v) => onRewardFilterToggled(RewardFilter.author)
                        : null,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                activeColor: _authorRewardColor,
              ),
              CheckboxListTile(
                title: const Text('Curation Rewards'),
                value: selectedRewardFilters.contains(RewardFilter.curation),
                onChanged:
                    selectedActivity == ActivityFilter.rewards
                        ? (v) => onRewardFilterToggled(RewardFilter.curation)
                        : null,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                activeColor: _curationRewardColor,
              ),
              CheckboxListTile(
                title: const Text('Benefactor Rewards'),
                value: selectedRewardFilters.contains(RewardFilter.benefactor),
                onChanged:
                    selectedActivity == ActivityFilter.rewards
                        ? (v) => onRewardFilterToggled(RewardFilter.benefactor)
                        : null,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                activeColor: _benefactorRewardColor,
              ),
            ],
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline_rounded,
              color: Colors.grey.shade700,
            ),
            title: const Text('Other'),
            selected: selectedActivity == ActivityFilter.other,
            selectedTileColor: _otherColor,
            onTap: () => onActivityChanged(ActivityFilter.other),
          ),
        ],
      );
    } else {
      // Mobile: horizontal chips
      final children = [
        FilterChip(
          label: const Text('Votes'),
          selected: selectedActivity == ActivityFilter.votes,
          onSelected: (v) => onActivityChanged(v ? ActivityFilter.votes : null),
          selectedColor: _votesColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: const Text('Comments'),
          selected: selectedActivity == ActivityFilter.comments,
          onSelected:
              (v) => onActivityChanged(v ? ActivityFilter.comments : null),
          selectedColor: _commentsColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: const Text('Replies'),
          selected: selectedActivity == ActivityFilter.replies,
          onSelected:
              (v) => onActivityChanged(v ? ActivityFilter.replies : null),
          selectedColor: _repliesColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: const Text('Rewards'),
          selected: selectedActivity == ActivityFilter.rewards,
          onSelected:
              (v) => onActivityChanged(v ? ActivityFilter.rewards : null),
          selectedColor: _rewardsColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: const Text('Other'),
          selected: selectedActivity == ActivityFilter.other,
          onSelected: (v) => onActivityChanged(v ? ActivityFilter.other : null),
          selectedColor: _otherColor,
        ),
      ];

      final rewardChildren = [
        FilterChip(
          label: const Text('Author Rewards'),
          selected: selectedRewardFilters.contains(RewardFilter.author),
          onSelected: (v) => onRewardFilterToggled(RewardFilter.author),
          selectedColor: _authorRewardColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: const Text('Curation Rewards'),
          selected: selectedRewardFilters.contains(RewardFilter.curation),
          onSelected: (v) => onRewardFilterToggled(RewardFilter.curation),
          selectedColor: _curationRewardColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: const Text('Benefactor Rewards'),
          selected: selectedRewardFilters.contains(RewardFilter.benefactor),
          onSelected: (v) => onRewardFilterToggled(RewardFilter.benefactor),
          selectedColor: _benefactorRewardColor,
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 8),
                ...children,
                const SizedBox(width: 8),
              ],
            ),
          ),
          if (selectedActivity == ActivityFilter.rewards)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  ...rewardChildren,
                  const SizedBox(width: 8),
                ],
              ),
            ),
        ],
      );
    }
  }
}
