class UploadResponse {
  final bool success;
  final String? url;
  final String message;

  UploadResponse({
    required this.success,
    required this.url,
    required this.message,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      success: json['success'] ?? false,
      url: json['url'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'url': url,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'UploadResponse(success: $success, url: $url, message: $message)';
  }
}
