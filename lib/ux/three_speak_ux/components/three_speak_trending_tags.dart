import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/graphql/gql_communicator.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_tags_response.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/trending_tags/trending_tags.dart';

class ThreeSpeakTrendingTags extends StatefulWidget {
  const ThreeSpeakTrendingTags({super.key, required this.onTapTag});
  final void Function(String tag) onTapTag;

  @override
  State<ThreeSpeakTrendingTags> createState() => _ThreeSpeakTrendingTagsState();
}

class _ThreeSpeakTrendingTagsState extends State<ThreeSpeakTrendingTags> {
  bool _loading = true;
  String? _error;
  List<String> _trendingTags = [];
  TrendingTagResponse? _trendingTagResponse;
  final GQLCommunicator _gql = GQLCommunicator();

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tagResponse = await _gql.getTrendingTags();
      setState(() {
        _trendingTagResponse = tagResponse;
        _trendingTags =
            tagResponse.data?.trendingTags?.tags?.map((e) => e.tag).toList() ??
            [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading ||
        _trendingTagResponse == null ||
        _trendingTagResponse!.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_trendingTags.isEmpty) {
      return const Center(child: Text('No trending tags found.'));
    }
    return TrendingTags(
      tags: _trendingTagResponse!.data!.trendingTags?.tags ?? [],
      onTapTag: widget.onTapTag,
    );
  }
}
