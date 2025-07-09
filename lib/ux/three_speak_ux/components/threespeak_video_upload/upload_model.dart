class UploadSuccessData {
  final String uploadUrl;
  final String filename;
  final String oFilename;
  final int size;
  final double duration;

  UploadSuccessData({
    required this.uploadUrl,
    required this.filename,
    required this.oFilename,
    required this.size,
    required this.duration,
  });
}
