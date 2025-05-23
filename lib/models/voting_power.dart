import 'dart:convert';

class VotingPower {
  double? upvotePower;
  double? downvotePower;

  VotingPower({this.upvotePower, this.downvotePower});

  factory VotingPower.fromJson(Map<String, dynamic> json) => VotingPower(
    upvotePower:
        json["upvotepower"] != null
            ? double.tryParse(json["upvotepower"].toString())
            : null,
    downvotePower:
        json["downvote"] != null
            ? double.tryParse(json["downvote"].toString())
            : null,
  );

  Map<String, dynamic> toJson() => {
    "upvotepower": upvotePower,
    "downvote": downvotePower,
  };

  static VotingPower fromJsonString(String str) =>
      VotingPower.fromJson(json.decode(str));

  static String toJsonString(VotingPower data) => json.encode(data.toJson());
}
