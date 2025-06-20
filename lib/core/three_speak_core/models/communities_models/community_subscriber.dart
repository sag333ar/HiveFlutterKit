import 'dart:convert';

class CommunitySubscriber {
  final String username;
  final String role;
  final String? extra;
  final String subscribedAt;

  CommunitySubscriber({
    required this.username,
    required this.role,
    this.extra,
    required this.subscribedAt,
  });

  factory CommunitySubscriber.fromList(List<dynamic> arr) {
    return CommunitySubscriber(
      username: arr[0] as String,
      role: arr[1] as String,
      extra: arr[2] as String?,
      subscribedAt: arr[3] as String,
    );
  }

  static List<CommunitySubscriber> listFromJsonString(String jsonString) {
    final List<dynamic> data = jsonString.isNotEmpty ? (jsonDecode(jsonString) as List) : [];
    return data.map((arr) => CommunitySubscriber.fromList(arr)).toList();
  }
}
