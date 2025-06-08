import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/custom_circle_avatar.dart';

class ListTileVideo extends StatelessWidget {
  const ListTileVideo({
    Key? key,
    required this.thumbnailUrl,
    required this.author,
    required this.title,
    required this.subtitle,
    required this.username,
    required this.permlink,
    required this.upVotes,
    required this.comments,
    required this.onUserTap,
  }) : super(key: key);

  final String thumbnailUrl;
  final String author;
  final String title;
  final String subtitle;
  final String username;
  final String permlink;
  final int upVotes;
  final int comments;
  final Function onUserTap;

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                );
              },
            ),
          ),
          isMobile
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            child: ClipOval(
                              child: CustomCircleAvatar(
                                height: 40,
                                width: 40,
                                url: server.userOwnerThumb(username),
                              ),
                            ),
                            onTap: () => onUserTap(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              // Add your report logic here if needed
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Report',
                                child: Text(
                                  'Report',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '@$username',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                subtitle,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildStatItem(Icons.thumb_up, upVotes.toString()),
                              const SizedBox(width: 16),
                              _buildStatItem(Icons.comment, comments.toString()),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            child: ClipOval(
                              child: CustomCircleAvatar(
                                height: 40,
                                width: 40,
                                url: server.userOwnerThumb(username),
                              ),
                            ),
                            onTap: () => onUserTap(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              // Add your report logic here if needed
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Report',
                                child: Text(
                                  'Report',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '@$username',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                subtitle,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildStatItem(Icons.thumb_up, upVotes.toString()),
                              const SizedBox(width: 16),
                              _buildStatItem(Icons.comment, comments.toString()),
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

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
