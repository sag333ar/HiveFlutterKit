import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/communities_models/request/community_details_request.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/communities_models/response/community_details_response_models.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/custom_circle_avatar.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/loading_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/retry.dart';
import 'package:http/http.dart' as http;

class CommunityTeamWidget extends StatefulWidget {
  const CommunityTeamWidget({
    Key? key,
    required this.communityId,
  }) : super(key: key);
  final String communityId;

  @override
  State<CommunityTeamWidget> createState() => _CommunityTeamWidgetState();
}

class _CommunityTeamWidgetState extends State<CommunityTeamWidget> {
  Future<CommunityDetailsResponse>? _details;

  @override
  void initState() {
    super.initState();
    _details = _fetchDetails();
  }

  Future<CommunityDetailsResponse> _fetchDetails() async {
    const hiveApiUrl = 'api.hive.blog';
    var client = http.Client();
    var body = CommunityDetailsRequest.forName(widget.communityId).toJsonString();
    var response = await client.post(Uri.parse('https://$hiveApiUrl'), body: body);
    if (response.statusCode == 200) {
      return CommunityDetailsResponse.fromString(response.body);
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

 Widget _teamGrid(List<List<String>> team) {
  return LayoutBuilder(
    builder: (context, constraints) {
      int crossAxisCount;
      double width = constraints.maxWidth;

      if (width < 600) {
        crossAxisCount = 2;
      } else if (width < 900) {
        crossAxisCount = 4;
      } else {
        crossAxisCount = 6;
      }

      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.8,
        ),
        itemCount: team.length,
        itemBuilder: (context, index) {
          final member = team[index];
          final username = member[0];
          final role = member.length > 1 ? member[1] : '';

          return Card(
            elevation: 1.5,
            margin: EdgeInsets.zero, // eliminate default margin
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  CustomCircleAvatar(
                    height: 42,
                    width: 42,
                    url: server.userOwnerThumb(username),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (role.isNotEmpty)
                          Text(
                            role,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget _team() {
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
          if (data.result.team.isEmpty) {
            return const Center(child: Text('No team members found.'));
          }
          return _teamGrid(data.result.team);
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
      body: _team(),
    );
  }
}
