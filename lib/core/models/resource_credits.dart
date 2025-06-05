import 'dart:convert';

class ResourceCredits {
  double? percentage;

  ResourceCredits({this.percentage});

  factory ResourceCredits.fromJson(dynamic json) => ResourceCredits(
    percentage:
        json is double
            ? json
            : json is String
            ? double.tryParse(json)
            : null,
  );

  Map<String, dynamic> toJson() => {"percentage": percentage};

  static ResourceCredits fromJsonString(String str) =>
      ResourceCredits.fromJson(json.decode(str));

  static String toJsonString(ResourceCredits data) =>
      json.encode(data.toJson());
}
