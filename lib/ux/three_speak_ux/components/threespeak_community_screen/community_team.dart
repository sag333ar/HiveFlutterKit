import 'package:flutter/material.dart';

class CommunityTeamWidget extends StatefulWidget {
  const CommunityTeamWidget({
    Key? key,
    required this.communityId,
  }) : super(key: key);
  final String communityId;

  @override
  State<CommunityTeamWidget> createState() =>
      _CommunityTeamWidgetState();
}

class _CommunityTeamWidgetState extends State<CommunityTeamWidget>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Community ${widget.communityId}'),
      ),
      body: Center(
        child: Text(
          'Details team community ${widget.communityId} will be displayed here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
