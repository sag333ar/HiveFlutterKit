class FollowersData {
  final List<dynamic>? followers;
  final int? count;
  final String? error;

  FollowersData({this.followers, this.count, this.error});

  factory FollowersData.fromJson(Map<String, dynamic> json) {
    return FollowersData(
      followers: json['followers'] ?? [],
      count: json['count'] ?? 0,
      error: json['error'],
    );
  }

  factory FollowersData.empty() => FollowersData(followers: [], count: 0);
}
