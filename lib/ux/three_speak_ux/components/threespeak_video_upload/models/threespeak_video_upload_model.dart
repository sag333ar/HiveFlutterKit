class ThreeSpeakVideoUploadModel {
  final String? uploadUrl;
  final String? filename;
  final String? originalFilename;
  final int? fileSize;
  final double? videoDuration;
  final String? thumbnailUrl;
  final String? thumbnailFilename;
  final String? videoId;
  final String owner;
  final String token;

  const ThreeSpeakVideoUploadModel({
    this.uploadUrl,
    this.filename,
    this.originalFilename,
    this.fileSize,
    this.videoDuration,
    this.thumbnailUrl,
    this.thumbnailFilename,
    this.videoId,
    required this.owner,
    required this.token,
  });

  ThreeSpeakVideoUploadModel copyWith({
    String? uploadUrl,
    String? filename,
    String? originalFilename,
    int? fileSize,
    double? videoDuration,
    String? thumbnailUrl,
    String? thumbnailFilename,
    String? videoId,
    String? owner,
    String? token,
  }) {
    return ThreeSpeakVideoUploadModel(
      uploadUrl: uploadUrl ?? this.uploadUrl,
      filename: filename ?? this.filename,
      originalFilename: originalFilename ?? this.originalFilename,
      fileSize: fileSize ?? this.fileSize,
      videoDuration: videoDuration ?? this.videoDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailFilename: thumbnailFilename ?? this.thumbnailFilename,
      videoId: videoId ?? this.videoId,
      owner: owner ?? this.owner,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadUrl': uploadUrl,
      'filename': filename,
      'originalFilename': originalFilename,
      'fileSize': fileSize,
      'videoDuration': videoDuration,
      'thumbnailUrl': thumbnailUrl,
      'thumbnailFilename': thumbnailFilename,
      'videoId': videoId,
      'owner': owner,
      'token': token,
    };
  }

  factory ThreeSpeakVideoUploadModel.fromJson(Map<String, dynamic> json) {
    return ThreeSpeakVideoUploadModel(
      uploadUrl: json['uploadUrl'],
      filename: json['filename'],
      originalFilename: json['originalFilename'],
      fileSize: json['fileSize'],
      videoDuration: json['videoDuration']?.toDouble(),
      thumbnailUrl: json['thumbnailUrl'],
      thumbnailFilename: json['thumbnailFilename'],
      videoId: json['videoId'],
      owner: json['owner'] ?? '',
      token: json['token'] ?? '',
    );
  }
}