import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/custom_circle_avatar.dart';

class FollowerListTile extends StatefulWidget {
  const FollowerListTile({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  State<FollowerListTile> createState() => _FollowerListTileState();
}

class _FollowerListTileState extends State<FollowerListTile>
    with AutomaticKeepAliveClientMixin<FollowerListTile> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // return _futureUserProfile();
    return ListTile(
      leading: CustomCircleAvatar(
        height: 40,
        width: 40,
        url: server.userOwnerThumb(widget.name),
      ),
      title: Text(widget.name),
      onTap: () {
        log('User tapped on hive user list item ${widget.name}');
      },
    );
  }
}
