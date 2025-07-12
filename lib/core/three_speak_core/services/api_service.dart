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

  Future<List<ThreeSpeakVideo>> getUserVideos(String username) async {
    var request = http.Request(
      'GET',
      Uri.parse('https://studio.3speak.tv/mobile/api/feed/user/@$username'),
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

  Future<List<ThreeSpeakVideo>> getHomeVideos() async {
    var request = http.Request(
      'GET',
      Uri.parse(' https://studio.3speak.tv/mobile/api/feed/home'),
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

  Future<List<ThreeSpeakVideo>> getTrendingVideos() async {
    var request = http.Request(
      'GET',
      Uri.parse('https://studio.3speak.tv/mobile/api/feed/trending'),
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

  Future<List<ThreeSpeakVideo>> getNewVideos() async {
    var request = http.Request(
      'GET',
      Uri.parse('https://studio.3speak.tv/mobile/api/feed/new'),
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

  Future<List<ThreeSpeakVideo>> getFirstUploadsVideos() async {
    var request = http.Request(
      'GET',
      Uri.parse('https://studio.3speak.tv/mobile/api/feed/first'),
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

  Future<List<ThreeSpeakVideo>> getVideoDetails(String username, String permlink) async {
    var request = http.Request(
      'GET',
      Uri.parse('https://studio.3speak.tv/mobile/api/video/@:$username/:$permlink'),
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

  Future<List<ThreeSpeakVideo>> getCommunityVideos(String community) async {
    var request = http.Request(
      'GET',
      Uri.parse('https://studio.3speak.tv/mobile/api/feed/community/@:$community'),
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
}
