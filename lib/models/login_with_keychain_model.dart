class LoginWithKeychainModel {
  final bool? success;
  final String? username;
  final String? proof;
  final String? publicKey;
  final String? challenge;

  LoginWithKeychainModel({
    this.success,
    this.username,
    this.proof,
    this.publicKey,
    this.challenge
  });

  factory LoginWithKeychainModel.fromJson(Map<String, dynamic> json) {
    return LoginWithKeychainModel(
      success: json['success'] as bool?,
      username: json['username'] as String?,
      proof: json['proof'] as String?,
      publicKey: json['publicKey'] as String?,
      challenge: json['result'] as String?,
    );
  }
}
