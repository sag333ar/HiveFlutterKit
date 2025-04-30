import 'dart:convert';

class LogoutResultModel {
  final String? success;
  final dynamic result;
  final String? error;

  LogoutResultModel({
    this.success,
    this.result,
    this.error,
  });

  factory LogoutResultModel.fromJson(Map<String, dynamic> json) {
    return LogoutResultModel(
      success: json['success'],
      result: json['result'],
      error: json['error'],
    );
  }

  static LogoutResultModel fromJsonString(String jsonString) {
    return LogoutResultModel.fromJson(json.decode(jsonString));
  }

  String toJsonString() {
    return json.encode({
      "success": success,
      "result": result,
      "error": error,
    });
  }
}
