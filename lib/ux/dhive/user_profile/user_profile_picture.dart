// user_profile_picture.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class UserProfilePicture extends StatefulWidget {
  final String username;
  final HiveFlutterKitPlatform hfk;
  final bool showDetails;
  final bool showDetailsDisabled;
  final Color upvoteColor;
  final Color downvoteColor;
  final Color resourceCreditsColor;
  final bool showBars;
  final Function? onTap;

  const UserProfilePicture({
    super.key,
    required this.username,
    required this.hfk,
    this.showDetails = false,
    this.showDetailsDisabled = false,
    this.upvoteColor = Colors.green,
    this.downvoteColor = Colors.red,
    this.resourceCreditsColor = Colors.blue,
    this.showBars = true,
    this.onTap,
  });

  @override
  State<UserProfilePicture> createState() => _UserProfilePictureState();
}

class _UserProfilePictureState extends State<UserProfilePicture> {
  double upvotePower = 0;
  double downvotePower = 0;
  double resourceCredits = 0;
  bool showDetails = false;

  @override
  void initState() {
    super.initState();
    showDetails = widget.showDetails;
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    try {
      await Future.delayed(
        const Duration(seconds: 1),
      ); // For simulating loading
      final voting = await widget.hfk.getVotingPower(widget.username);
      final rc = await widget.hfk.getResourceCredits(widget.username);

      setState(() {
        upvotePower = voting.upvotePower ?? 0;
        downvotePower = voting.downvotePower ?? 0;
        resourceCredits = rc.percentage ?? 0;
      });
    } catch (e) {
      debugPrint("Error fetching user stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        "https://images.hive.blog/u/${widget.username}/avatar?id=test";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              setState(() {
                showDetails = !showDetails;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${widget.username}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (widget.showBars) ...[
                      buildBar('Upvote Power', upvotePower, widget.upvoteColor),
                      buildBar(
                        'Downvote Power',
                        downvotePower,
                        widget.downvoteColor,
                      ),
                      buildBar(
                        'RC %',
                        resourceCredits,
                        widget.resourceCreditsColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDetails)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!widget.showDetailsDisabled)
                  Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[100]!],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildColoredBox(
                          Icons.arrow_upward,
                          upvotePower,
                          widget.upvoteColor,
                        ),
                        buildColoredBox(
                          Icons.arrow_downward,
                          downvotePower,
                          widget.downvoteColor,
                        ),
                        buildColoredBox(
                          Icons.flash_on,
                          resourceCredits,
                          widget.resourceCreditsColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildBar(String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Tooltip(
        message: '$label: ${percent.toInt()}%',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 120,
            height: 6,
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.grey[300],
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildColoredBox(IconData icon, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            '${value.toInt()}%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
