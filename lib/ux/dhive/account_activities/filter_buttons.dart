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
  final Color? fontColor;

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
    this.fontColor,
  });

  bool _isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    if (!isFilter) return const SizedBox.shrink();

    final bool isDark = _isDarkMode(context);
    final _fontColor = fontColor ?? (isDark ? Colors.white : Colors.black);

    // Use provided colors or fallback to defaults
    final _votesColor =
        votesColor ?? (isDark ? Colors.blue.shade900 : Colors.blue.shade200);
    final _commentsColor =
        commentsColor ??
        (isDark ? Colors.green.shade900 : Colors.green.shade200);
    final _repliesColor =
        repliesColor ?? (isDark ? Colors.teal.shade900 : Colors.teal.shade200);
    final _rewardsColor =
        rewardsColor ??
        (isDark ? Colors.amber.shade700 : Colors.amber.shade200);
    final _otherColor =
        otherColor ?? (isDark ? Colors.grey.shade800 : Colors.grey.shade400);
    final _authorRewardColor =
        authorRewardColor ??
        (isDark ? Colors.amber.shade800 : Colors.amber.shade300);
    final _curationRewardColor =
        curationRewardColor ??
        (isDark ? Colors.purple.shade800 : Colors.purple.shade200);
    final _benefactorRewardColor =
        benefactorRewardColor ??
        (isDark ? Colors.orange.shade800 : Colors.orange.shade200);

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: _fontColor,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(
              Icons.thumb_up_alt_rounded,
              color: Colors.blue.shade700,
            ),
            title: Text('Votes', style: TextStyle(color: _fontColor)),
            selected: selectedActivity == ActivityFilter.votes,
            selectedTileColor: _votesColor,
            onTap: () => onActivityChanged(ActivityFilter.votes),
          ),
          ListTile(
            leading: Icon(Icons.comment_rounded, color: Colors.green.shade700),
            title: Text('Comments', style: TextStyle(color: _fontColor)),
            selected: selectedActivity == ActivityFilter.comments,
            selectedTileColor: _commentsColor,
            onTap: () => onActivityChanged(ActivityFilter.comments),
          ),
          ListTile(
            leading: Icon(Icons.reply_rounded, color: Colors.teal.shade700),
            title: Text('Replies', style: TextStyle(color: _fontColor)),
            selected: selectedActivity == ActivityFilter.replies,
            selectedTileColor: _repliesColor,
            onTap: () => onActivityChanged(ActivityFilter.replies),
          ),
          ExpansionTile(
            leading: Icon(
              Icons.emoji_events_rounded,
              color: Colors.amber.shade700,
            ),
            title: Text('Rewards', style: TextStyle(color: _fontColor)),
            initiallyExpanded: selectedActivity == ActivityFilter.rewards,
            onExpansionChanged: (expanded) {
              onActivityChanged(expanded ? ActivityFilter.rewards : null);
            },
            children: [
              CheckboxListTile(
                title: Text(
                  'Author Rewards',
                  style: TextStyle(color: _fontColor),
                ),
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
                title: Text(
                  'Curation Rewards',
                  style: TextStyle(color: _fontColor),
                ),
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
                title: Text(
                  'Benefactor Rewards',
                  style: TextStyle(color: _fontColor),
                ),
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
            title: Text('Other', style: TextStyle(color: _fontColor)),
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
          label: Text('Votes', style: TextStyle(color: _fontColor)),
          selected: selectedActivity == ActivityFilter.votes,
          onSelected: (v) => onActivityChanged(v ? ActivityFilter.votes : null),
          selectedColor: _votesColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: Text('Comments', style: TextStyle(color: _fontColor)),
          selected: selectedActivity == ActivityFilter.comments,
          onSelected:
              (v) => onActivityChanged(v ? ActivityFilter.comments : null),
          selectedColor: _commentsColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: Text('Replies', style: TextStyle(color: _fontColor)),
          selected: selectedActivity == ActivityFilter.replies,
          onSelected:
              (v) => onActivityChanged(v ? ActivityFilter.replies : null),
          selectedColor: _repliesColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: Text('Rewards', style: TextStyle(color: _fontColor)),
          selected: selectedActivity == ActivityFilter.rewards,
          onSelected:
              (v) => onActivityChanged(v ? ActivityFilter.rewards : null),
          selectedColor: _rewardsColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: Text('Other', style: TextStyle(color: _fontColor)),
          selected: selectedActivity == ActivityFilter.other,
          onSelected: (v) => onActivityChanged(v ? ActivityFilter.other : null),
          selectedColor: _otherColor,
        ),
      ];

      final rewardChildren = [
        FilterChip(
          label: Text('Author Rewards', style: TextStyle(color: _fontColor)),
          selected: selectedRewardFilters.contains(RewardFilter.author),
          onSelected: (v) => onRewardFilterToggled(RewardFilter.author),
          selectedColor: _authorRewardColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: Text('Curation Rewards', style: TextStyle(color: _fontColor)),
          selected: selectedRewardFilters.contains(RewardFilter.curation),
          onSelected: (v) => onRewardFilterToggled(RewardFilter.curation),
          selectedColor: _curationRewardColor,
        ),
        const SizedBox(width: 8, height: 8),
        FilterChip(
          label: Text(
            'Benefactor Rewards',
            style: TextStyle(color: _fontColor),
          ),
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
