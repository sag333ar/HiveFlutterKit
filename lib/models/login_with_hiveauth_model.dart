import 'dart:convert';
class LoginWithHiveAuthModel {
  final bool? success;
  final String? username;
  final String? proof;
  final String? publicKey;
  final String? challenge;

  LoginWithHiveAuthModel({
    this.success,
    this.username,
    this.proof,
    this.publicKey,
    this.challenge
  });

  factory LoginWithHiveAuthModel.fromJson(Map<String, dynamic> json) {
    return LoginWithHiveAuthModel(
      success: json['success'] as bool?,
      username: json['username'] as String?,
      proof: json['proof'] as String?,
      publicKey: json['publicKey'] as String?,
      challenge: json['result'] as String?,
    );
  }
  static LoginWithHiveAuthModel fromJsonString(String str) =>
      LoginWithHiveAuthModel.fromJson(json.decode(str));
}
