import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/communities_models/request/community_details_request.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/communities_models/response/community_details_response_models.dart';
import 'package:hive_flutter_kit/core/three_speak_core/seconds_to_duration.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/loading_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/retry.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class CommunityAboutWidget extends StatefulWidget {
  const CommunityAboutWidget({
    Key? key,
    required this.communityId,
  }) : super(key: key);
  final String communityId;

  @override
  State<CommunityAboutWidget> createState() => _CommunityAboutWidgetState();
}

class _CommunityAboutWidgetState extends State<CommunityAboutWidget> {
  Future<CommunityDetailsResponse>? _details;

  @override
  void initState() {
    super.initState();
    _details = _fetchDetails();
  }

  Future<CommunityDetailsResponse> _fetchDetails() async {
    // Use bridge API directly, similar to _loadDetails from your reference
    const hiveApiUrl = 'api.hive.blog'; // or your preferred Hive API node
    var client = http.Client();
    var body = CommunityDetailsRequest.forName(widget.communityId).toJsonString();
    var response = await client.post(Uri.parse('https://$hiveApiUrl'), body: body);
    if (response.statusCode == 200) {
      return CommunityDetailsResponse.fromString(response.body);
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  String _generateMarkDown(CommunityDetailsResponse data) {
    return "## About:\n${data.result.about}\n\n"
        "## Information:\n${data.result.description}\n\n"
        "## Flags:\n${data.result.flagText}\n\n"
        "## Total Authors:\n${data.result.numAuthors}\n\n"
        "## Subscribers:\n${data.result.subscribers}\n\n"
        "## Created At:\n${Utilities.parseAndFormatDateTime(data.result.createdAt)}";
  }

  Widget _descriptionMarkDown(String markDown) {
    return Markdown(
      data: Utilities.removeAllHtmlTags(markDown),
      onTapLink: (text, url, title) {
        launchUrl(Uri.parse(url ?? 'https://google.com'));
      },
    );
  }

  Widget _about() {
    return FutureBuilder(
      future: _details,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RetryScreen(
            error: snapshot.error?.toString() ?? 'Something went wrong',
            onRetry: () {
              setState(() {
                _details = _fetchDetails();
              });
            },
          );
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          CommunityDetailsResponse data = snapshot.data! as CommunityDetailsResponse;
          return _descriptionMarkDown(_generateMarkDown(data));
        } else {
          return const LoadingScreen(
            title: 'Loading Data',
            subtitle: 'Please wait',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _about(),
    );
  }
}
