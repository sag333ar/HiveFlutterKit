// user_profile_picture.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class UserProfilePictureAioha extends StatefulWidget {
  final HiveFlutterKitPlatform aioha;
  final bool showDetails;
  final bool showDetailsDisabled;
  final Color upvoteColor;
  final Color downvoteColor;
  final Color resourceCreditsColor;
  final bool showBars;
  final Function onTap;

  UserProfilePictureAioha({
    super.key,
    required this.aioha,
    this.showDetails = false,
    this.showDetailsDisabled = false,
    this.upvoteColor = Colors.green,
    this.downvoteColor = Colors.red,
    this.resourceCreditsColor = Colors.blue,
    this.showBars = true,
    required this.onTap,
  });

  @override
  State<UserProfilePictureAioha> createState() =>
      _UserProfilePictureAiohaState();
}

class _UserProfilePictureAiohaState extends State<UserProfilePictureAioha> {
  Future<String> _getCurrentUsername() {
    return widget.aioha.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getCurrentUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('User not found');
        }

        final username = snapshot.data!;
        final user = username.replaceAll('"', '');
        return Center(
          // child:
          //  UserProfilePicture(
          //   username: user,
          //   showDetails: widget.showDetails,
          //   showDetailsDisabled: widget.showDetailsDisabled,
          //   upvoteColor: widget.upvoteColor,
          //   downvoteColor: widget.downvoteColor,
          //   resourceCreditsColor: widget.resourceCreditsColor,
          //   showBars: widget.showBars,
          //   onTap: widget.onTap,
          // ),
        );
      },
    );
  }
}
