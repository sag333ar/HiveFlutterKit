class FollowingsData {
  final List<dynamic>? followings;
  final int? count;
  final String? error;

  FollowingsData({this.followings, this.count, this.error});

  factory FollowingsData.fromJson(Map<String, dynamic> json) {
    return FollowingsData(
      followings: json['followings'] ?? [],
      count: json['count'] ?? 0,
      error: json['error'],
    );
  }

  factory FollowingsData.empty() => FollowingsData(followings: [], count: 0);
}
