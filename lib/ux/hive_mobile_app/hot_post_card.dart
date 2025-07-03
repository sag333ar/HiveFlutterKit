import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';

class HotPostCard extends StatelessWidget {
  final Discussion post;

  const HotPostCard({super.key, required this.post});

  String getCORSImageUrl(String originalUrl) {
  if (kIsWeb) {
    // Return a placeholder or empty string instead of loading the blocked image
    return 'https://via.placeholder.com/300x200.png?text=No+Image';
  } else {
    return originalUrl;
  }
}


  String get imageUrl {
    final body = post.body ?? '';
    final exp = RegExp(r'(https?:\/\/.*\.(?:png|jpg|jpeg|gif|webp))');
    final match = exp.firstMatch(body);
    final originalUrl =
        match?.group(0) ??
        'https://via.placeholder.com/300x200.png?text=No+Image';

    return getCORSImageUrl(originalUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Image (Fixed height with full width)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Body content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author & tag
                Text(
                  '@${post.author}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  post.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Payout
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 14,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "\$${post.pendingPayoutValue?.amount ?? '0.00'}",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Votes & comments
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 14,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${post.stats?.totalVotes ?? 0}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.comment_outlined,
                          size: 14,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${post.stats?.totalVotes ?? 0}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
