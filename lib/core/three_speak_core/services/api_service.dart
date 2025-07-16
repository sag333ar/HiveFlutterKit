import 'dart:convert';
import 'package:hive_flutter_kit/core/three_speak_core/models/studio_video_model.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';

class ApiService {
  Future<Map<String, dynamic>> handleLogin(LoginModel result) async {
    final url = Uri.parse('${server.domain}/mobile/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "challenge": result.challenge,
        "proof": result.proof,
        "publicKey": result.publicKey,
        "username": result.username,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login API error: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> handleUpvote({
    required String author,
    required String permlink,
    required int weight,
    required String authToken,
  }) async {
    final url = Uri.parse('${server.domain}/mobile/vote');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'authorization': authToken},
      body: jsonEncode({
        "author": author,
        "permlink": permlink,
        "weight": weight,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Unknown API error',
      );
    }
  }

  Future<Map<String, dynamic>> handleComment({
    required String author,
    required String permlink,
    required String body,
    required String authToken,
  }) async {
    final url = Uri.parse('${server.domain}/mobile/comment');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'authorization': authToken},
      body: jsonEncode({
        "author": author,
        "permlink": permlink,
        "comment": body,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Unknown API error',
      );
    }
  }

  Future<List<ThreeSpeakVideo>> getUserVideos(String username, {int skip = 0}) async {
    var request = http.Request(
      'GET',
      Uri.parse('${server.kThreeSpeakApiUrl}/feed/user/@$username?skip=$skip'),
    );
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      return ThreeSpeakVideo.threeSpeakVideosFromJsonString(string);
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Something went wrong';
    }
  }

  Future<List<ThreeSpeakVideo>> getHomeVideos({int skip = 0}) async {
    var request = http.Request(
      'GET',
      Uri.parse('${server.kThreeSpeakApiUrl}/feed/home?skip=$skip'),
    );
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      return ThreeSpeakVideo.threeSpeakVideosFromJsonString(string);
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Something went wrong';
    }
  }

  Future<List<ThreeSpeakVideo>> getTrendingVideos({int skip = 0}) async {
  final url = Uri.parse('${server.kThreeSpeakApiUrl}/feed/trending?skip=$skip');
  final request = http.Request('GET', url);

  final response = await request.send();
  if (response.statusCode == 200) {
    final string = await response.stream.bytesToString();
    return ThreeSpeakVideo.threeSpeakVideosFromJsonString(string);
  } else {
    throw response.reasonPhrase ?? 'Something went wrong';
  }
}


  Future<List<ThreeSpeakVideo>> getNewVideos({int skip = 0}) async {
    var request = http.Request(
      'GET',
      Uri.parse('${server.kThreeSpeakApiUrl}/feed/new?skip=$skip'),
    );
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      return ThreeSpeakVideo.threeSpeakVideosFromJsonString(string);
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Something went wrong';
    }
  }

  Future<List<ThreeSpeakVideo>> getFirstUploadsVideos({int skip = 0}) async {
    var request = http.Request(
      'GET',
      Uri.parse('${server.kThreeSpeakApiUrl}/feed/first?skip=$skip'),
    );
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      return ThreeSpeakVideo.threeSpeakVideosFromJsonString(string);
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Something went wrong';
    }
  }

  Future<ThreeSpeakVideo> getVideoDetails(
    String username,
    String permlink,
    {int skip = 0}
  ) async {
    final uri = Uri.parse(
      '${server.kThreeSpeakApiUrl}/video/@$username/$permlink?skip=$skip',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ThreeSpeakVideo.fromJson(json);
    } else {
      print(
        'Failed to load video: ${response.statusCode} ${response.reasonPhrase}',
      );
      throw response.reasonPhrase ?? 'Something went wrong';
    }
  }

  Future<List<ThreeSpeakVideo>> getCommunityVideos(String community,{int skip = 0}) async {
    final uri = Uri.parse(
      '${server.kThreeSpeakApiUrl}/feed/community/@$community?skip=$skip',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final string = response.body;
      return ThreeSpeakVideo.threeSpeakVideosFromJsonString(string);
    } else {
      print('Failed: ${response.statusCode} ${response.reasonPhrase}');
      throw response.reasonPhrase ?? 'Something went wrong';
    }
  }

  Future<List<ThreeSpeakVideo>> getRelatedVideos(String username, {int skip = 0}) async {
    var request = http.Request(
      'GET',
      Uri.parse('${server.kThreeSpeakApiUrl}/feed/@$username?skip=$skip'),
    );
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      return ThreeSpeakVideo.threeSpeakVideosFromJsonString(string);
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Something went wrong';
    }
  }
  ///api/feed/@:username/:community/:language
}
