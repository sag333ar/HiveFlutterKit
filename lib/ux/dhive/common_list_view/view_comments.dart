import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/ux/dhive/common_list_view/blog_list.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html/parser.dart' as html_parser;

class ViewComments extends StatefulWidget {
  final List<Discussion> discussions;
  final bool isLoadingMore;
  final bool hasMore;
  final ScrollController scrollController;
  final List<String>? amoutValues;
  final Function? onTap;
  final Function? onAuthorTap;
  final Function? onCategoryTap;
  final Function? onUpvoteTap;
  final Function? onDownVoteTap;
  final Function? onCommentTap;
  final Function? onReblogTap;

  const ViewComments({
    super.key,
    required this.discussions,
    required this.isLoadingMore,
    required this.hasMore,
    required this.scrollController,
    this.onTap,
    this.onAuthorTap,
    this.onCategoryTap,
    this.onUpvoteTap,
    this.onDownVoteTap,
    this.onCommentTap,
    this.onReblogTap,
    this.amoutValues,
  });

  @override
  State<ViewComments> createState() => _ViewCommentsState();
}

class _ViewCommentsState extends State<ViewComments> {
  ViewMode _viewMode = ViewMode.list;

  String? extractFirstImageUrl(String? body) {
    if (body == null || body.isEmpty) return null;
    final regex = RegExp(
      r'(https?:\/\/[^\s]+?\.(?:png|jpe?g|gif|webp))',
      caseSensitive: false,
    );
    final match = regex.firstMatch(body);
    return match?.group(0);
  }

  String extractCleanDescription(String? raw, {int maxWords = 100}) {
    if (raw == null || raw.trim().isEmpty) return ' ';
    final document = html_parser.parse(raw);
    String parsedText = document.body?.text ?? '';
    parsedText = parsedText.replaceAll(RegExp(r'https?:\/\/\S+'), '');
    parsedText =
        parsedText
            .replaceAll(RegExp(r'!\[.?\]\(.?\)'), '')
            .replaceAll(RegExp(r'\[.?\]\(.?\)'), '')
            .replaceAll(RegExp(r'[*_`#>~-]'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
    final words = parsedText
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .take(maxWords);
    return words.isEmpty
        ? 'No Description'
        : words.join(' ') + (words.length == maxWords ? '...' : '');
  }

  String formatDateOrTimeAgo(String? created) {
    if (created == null || created.isEmpty) return '';
    String dateStr = created.endsWith('Z') ? created : '${created}Z';
    DateTime dt = DateTime.tryParse(dateStr) ?? DateTime.now();
    final now = DateTime.now().toUtc();
    final diff = now.difference(dt.toUtc());
    if (diff.inDays > 30) {
      // Show as 'Mar 24, 2025'
      return "${_monthShort(dt.month)} ${dt.day}, ${dt.year}";
    } else {
      return timeago.format(dt);
    }
  }

  String _monthShort(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'List View',
              icon: Icon(
                Icons.view_list,
                color: _viewMode == ViewMode.list ? Colors.blue : null,
              ),
              onPressed: () => setState(() => _viewMode = ViewMode.list),
            ),
            if (isDesktop)
              IconButton(
                tooltip: 'Grid View',
                icon: Icon(
                  Icons.grid_view,
                  color: _viewMode == ViewMode.grid ? Colors.blue : null,
                ),
                onPressed: () => setState(() => _viewMode = ViewMode.grid),
              ),
            IconButton(
              tooltip: 'Large Preview',
              icon: Icon(
                Icons.photo_size_select_large,
                color: _viewMode == ViewMode.large ? Colors.blue : null,
              ),
              onPressed: () => setState(() => _viewMode = ViewMode.large),
            ),
          ],
        ),
        Expanded(child: _buildListView(isDesktop)),
      ],
    );
  }

  Widget _buildListView(bool isDesktop) {
    if (_viewMode == ViewMode.grid && isDesktop) {
      return LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 4;
          if (constraints.maxWidth < 1200) {
            crossAxisCount = 3;
          }
          if (constraints.maxWidth < 800) {
            crossAxisCount = 2;
          }
          return MasonryGridView.count(
            controller: widget.scrollController,
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount:
                widget.discussions.length +
                (widget.isLoadingMore || widget.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.discussions.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final discussion = widget.discussions[index];
              final amount = widget.amoutValues?[index] ?? '';
              return _buildGridCard(discussion, amount);
            },
          );
        },
      );
    } else {
      return ListView.builder(
        controller: widget.scrollController,
        itemCount:
            widget.discussions.length +
            (widget.isLoadingMore || widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.discussions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final discussion = widget.discussions[index];
          final amount = widget.amoutValues?[index] ?? '';
          if (_viewMode == ViewMode.large) {
            return _buildLargeCard(discussion, amount, isDesktop);
          }
          return _buildDiscussionCard(discussion, amount);
        },
      );
    }
  }

  Widget _buildDiscussionCard(Discussion discussion, String amount) {
    final String? bodyImage = extractFirstImageUrl(discussion.body);

    final String? imageUrl =
        discussion.jsonMetadata?.image?.isNotEmpty == true
            ? 'https://images.hive.blog/160x80/${discussion.jsonMetadata!.image!.first}'
            : bodyImage != null
            ? 'https://images.hive.blog/160x80/$bodyImage'
            : null;

    final String description =
        discussion.jsonMetadata?.description?.trim().isNotEmpty == true
            ? discussion.jsonMetadata!.description!
            : extractCleanDescription(discussion.body);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: InkWell(
              onTap: () => widget.onAuthorTap?.call(discussion),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://images.hive.blog/u/${discussion.author ?? ''}/avatar',
                ),
              ),
            ),
            title: Wrap(
              spacing: 4,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InkWell(
                  onTap: () => widget.onAuthorTap?.call(discussion),
                  child: Text(
                    discussion.author ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Text('•', style: TextStyle(color: Colors.grey)),
                InkWell(
                  onTap: () => widget.onCategoryTap?.call(discussion),
                  child: Text(
                    (discussion.communityTitle?.trim().isNotEmpty ?? false)
                        ? discussion.communityTitle!
                        : '#${discussion.category ?? ''}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const Text('•', style: TextStyle(color: Colors.grey)),
                Text(
                  formatDateOrTimeAgo(discussion.created),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => widget.onTap?.call(discussion),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Container(
                          width: 120,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (discussion.title?.isNotEmpty ?? false)
                              Text(
                                discussion.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return Padding(
                      padding: EdgeInsets.only(
                        left:
                            (isMobile || imageUrl == null || imageUrl.isEmpty)
                                ? 0
                                : 120,
                      ),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment:
                            isMobile
                                ? WrapAlignment.center
                                : WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => widget.onUpvoteTap?.call(discussion),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text('${discussion.stats?.totalVotes ?? 0}'),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => widget.onCommentTap?.call(discussion),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.comment,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text('${discussion.children ?? 0}'),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => widget.onReblogTap?.call(discussion),
                            child: const Icon(
                              Icons.repeat,
                              size: 20,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            amount,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(Discussion discussion, String amount) {
    final String? bodyImage = extractFirstImageUrl(discussion.body);

    final String? imageUrl =
        discussion.jsonMetadata?.image?.isNotEmpty == true
            ? 'https://images.hive.blog/320x160/${discussion.jsonMetadata!.image!.first}'
            : bodyImage != null
            ? 'https://images.hive.blog/320x160/$bodyImage'
            : null;

    final String description =
        discussion.jsonMetadata?.description?.trim().isNotEmpty == true
            ? discussion.jsonMetadata!.description!
            : extractCleanDescription(discussion.body);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => widget.onTap?.call(discussion),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile details in one row (same as list view)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    top: 8,
                    right: 8,
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => widget.onAuthorTap?.call(discussion),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            'https://images.hive.blog/u/${discussion.author ?? ''}/avatar',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap:
                                      () =>
                                          widget.onAuthorTap?.call(discussion),
                                  child: Text(
                                    discussion.author ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  formatDateOrTimeAgo(discussion.created),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap:
                                  () => widget.onCategoryTap?.call(discussion),
                              child: Text(
                                (discussion.communityTitle?.trim().isNotEmpty ??
                                        false)
                                    ? discussion.communityTitle!
                                    : '#${discussion.category ?? ''}',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (discussion.title?.isNotEmpty ?? false)
                        Text(
                          discussion.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap:
                                    () => widget.onUpvoteTap?.call(discussion),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${discussion.stats?.totalVotes ?? 0}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap:
                                    () => widget.onCommentTap?.call(discussion),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.comment,
                                      size: 20,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${discussion.children ?? 0}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => widget.onReblogTap?.call(discussion),
                            child: const Icon(
                              Icons.repeat,
                              size: 20,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            amount,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLargeCard(Discussion discussion, String amount, bool isDesktop) {
    final String? bodyImage = extractFirstImageUrl(discussion.body);

    final String? imageUrl =
        discussion.jsonMetadata?.image?.isNotEmpty == true
            ? 'https://images.hive.blog/640x320/${discussion.jsonMetadata!.image!.first}'
            : bodyImage != null
            ? 'https://images.hive.blog/640x320/$bodyImage'
            : null;

    final String description =
        discussion.jsonMetadata?.description?.trim().isNotEmpty == true
            ? discussion.jsonMetadata!.description!
            : extractCleanDescription(discussion.body);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: InkWell(
        onTap: () => widget.onTap?.call(discussion),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile details in one row (same as list view)
              Row(
                children: [
                  InkWell(
                    onTap: () => widget.onAuthorTap?.call(discussion),
                    child: CircleAvatar(
                      radius: isDesktop ? 32 : 24,
                      backgroundImage: NetworkImage(
                        'https://images.hive.blog/u/${discussion.author ?? ''}/avatar',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => widget.onAuthorTap?.call(discussion),
                          child: Text(
                            discussion.author ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop ? 20 : 16,
                            ),
                          ),
                        ),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        InkWell(
                          onTap: () => widget.onCategoryTap?.call(discussion),
                          child: Text(
                            (discussion.communityTitle?.trim().isNotEmpty ??
                                    false)
                                ? discussion.communityTitle!
                                : '#${discussion.category ?? ''}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        Text(
                          formatDateOrTimeAgo(discussion.created),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Large image
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: isDesktop ? 320 : 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              // Title and description
              if (discussion.title?.isNotEmpty ?? false)
                Text(
                  discussion.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 24 : 18,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: isDesktop ? 6 : 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: isDesktop ? 18 : 15,
                ),
              ),
              const SizedBox(height: 12),
              // Actions
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment:
                    isDesktop ? WrapAlignment.start : WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InkWell(
                    onTap: () => widget.onUpvoteTap?.call(discussion),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, size: 22, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('${discussion.stats?.totalVotes ?? 0}'),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.onCommentTap?.call(discussion),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.comment, size: 22, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${discussion.children ?? 0}'),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.onReblogTap?.call(discussion),
                    child: const Icon(
                      Icons.repeat,
                      size: 22,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
