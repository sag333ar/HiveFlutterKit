import 'dart:convert';
class LoginModel {
  final bool? success;
  final String? username;
  final String? proof;
  final String? publicKey;
  final String? challenge;

  LoginModel({
    this.success,
    this.username,
    this.proof,
    this.publicKey,
    this.challenge
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      success: json['success'] as bool?,
      username: json['username'] as String?,
      proof: json['proof'] as String?,
      publicKey: json['publicKey'] as String?,
      challenge: json['result'] as String?,
    );
  }
  static LoginModel fromJsonString(String str) =>
      LoginModel.fromJson(json.decode(str));
}
