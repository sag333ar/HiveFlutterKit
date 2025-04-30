import 'dart:convert';

class CurrentUserModel {
  final String? username;
  final String? error;

  CurrentUserModel({
    this.username,
    this.error,
  });

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) =>
      CurrentUserModel(
        username: json['username'] as String?,
        error: json['error'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'error': error,
      };

  static CurrentUserModel fromJsonString(String str) =>
      CurrentUserModel.fromJson(json.decode(str));

  static String toJsonString(CurrentUserModel data) =>
      json.encode(data.toJson());
}
