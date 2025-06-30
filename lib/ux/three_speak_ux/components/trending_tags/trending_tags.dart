import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_tags_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/trending_tags/trending_tag_videos.dart';

class TrendingTags extends StatelessWidget {
  final List<TrendingTagResponseDataTrendingTag> tags;
  final void Function(String tag) onTapTag;
  const TrendingTags({Key? key, required this.tags, required this.onTapTag});

  @override
  Widget build(BuildContext context) {
    int maxScore = tags.isNotEmpty ? tags.first.score : 1;
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    double aspectRatio;

    if (screenWidth < 600) {
      crossAxisCount = 2; // Mobile
      aspectRatio = 0.9;
    } else if (screenWidth < 1024) {
      crossAxisCount = 3; // Tablet
      aspectRatio = 1.2;
    } else if (screenWidth < 1280) {
      crossAxisCount = 4; // Small desktop
      aspectRatio = 1.2;
    } else {
      crossAxisCount = 5; // Large desktop
      aspectRatio = 1.5;
    }

    Color getIndicatorColor(double percent) {
      if (percent >= 0.67) return Colors.green;
      if (percent >= 0.34) return Colors.orange;
      return Colors.red;
    }

    if (tags.isEmpty) {
      return const Center(child: Text('No trending tags found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tags.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) {
        final tagItem = tags[index];
        final scorePercent = maxScore > 0 ? tagItem.score / maxScore : 0;
        return InkWell(
          onTap: () {
            onTapTag(tagItem.tag);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder:
            //         (context) => TrendingTagVideos(
            //           tag: tagItem.tag,
            //           onTapVideoItem: (onTapVideoItem) => onTapTag(tagItem.tag),
            //           onTapAuthor:  (onTapAuthor) => onTapTag(tagItem.tag),
            //           onTapReport:  (onTapReport) => onTapTag(tagItem.tag),
            //           onTapUpvote:    (onTapUpvote) => onTapTag(tagItem.tag),
            //           onTapComment:   (onTapComment) => onTapTag(tagItem.tag),
            //         ),
            //   ),
            // );
          },
          child: Card(
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          value: scorePercent.toDouble(),
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            getIndicatorColor(scorePercent.toDouble()),
                          ),
                        ),
                      ),
                      Text(
                        '${(scorePercent * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getIndicatorColor(scorePercent.toDouble()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '#${tagItem.tag}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Divider(),
                  Text(
                    'Trending Score: ${tagItem.score}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
