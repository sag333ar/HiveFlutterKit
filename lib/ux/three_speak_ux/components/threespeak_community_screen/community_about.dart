import 'package:flutter/material.dart';

class CommunityAboutWidget extends StatefulWidget {
  const CommunityAboutWidget({
    Key? key,
    required this.communityId,
  }) : super(key: key);
  final String communityId;

  @override
  State<CommunityAboutWidget> createState() =>
      _CommunityAboutWidgetState();
}

class _CommunityAboutWidgetState extends State<CommunityAboutWidget>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Community ${widget.communityId}'),
      ),
      body: Center(
        child: Text(
          'Details about community ${widget.communityId} will be displayed here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
