import 'dart:io';
import 'package:another_tus_client/another_tus_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/thumbnail_upload_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/upload_info_screen.dart';
import 'package:video_player/video_player.dart';

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({
    super.key,
    required this.owner,
    required this.token,
    this.onUploadSuccess,
  });
  final String owner;
  final String token;
  final UploadSuccessCallback? onUploadSuccess;

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  bool encodeOnDevice = true;
  XFile? _selectedFile;
  String _status = 'No video selected';
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _originalFileName;
  int? _fileSize;
  double? _videoDuration;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: kIsWeb,
    );

    if (result != null &&
        (result.files.single.bytes != null ||
            result.files.single.path != null)) {
      final file = result.files.single;
      final fileExtension = file.extension?.toLowerCase();

      if (fileExtension != 'mp4' && fileExtension != 'mov') {
        setState(
          () =>
              _status =
                  'Unsupported video format. Only .mp4 and .mov are allowed.',
        );
        return;
      }

      setState(() {
        _selectedFile =
            kIsWeb
                ? XFile.fromData(file.bytes!, name: file.name)
                : XFile(file.path!);
        _originalFileName = file.name;
        _fileSize = file.size;
        _status = 'Selected: ${file.name}';
      });

      _videoController?.dispose();
      _videoController =
          kIsWeb
              ? VideoPlayerController.networkUrl(
                Uri.dataFromBytes(file.bytes!, mimeType: 'video/mp4'),
              )
              : VideoPlayerController.file(File(_selectedFile!.path));

      await _videoController!.initialize();
      _videoDuration = _videoController!.value.duration.inSeconds.toDouble();

      setState(() {});
      // Automatically start uploading after picking and initializing video
      await _uploadFile();
    } else {
      setState(() => _status = 'File picking cancelled');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      setState(() => _status = 'Please pick a file first');
      return;
    }

    final fileExtension = _selectedFile!.name.split('.').last.toLowerCase();
    if (fileExtension != 'mp4' && fileExtension != 'mov') {
      setState(
        () => _status = 'Video format is not suitable for this platform',
      );
      return;
    }

    final client = TusClient(_selectedFile!, store: TusMemoryStore());

    setState(() {
      _isUploading = true;
      _status = 'Uploading...';
    });

    try {
      await client.upload(
        uri: Uri.parse(server.kThreeSpeakUploadUrl),
        onProgress: (progress, _) {
          setState(() {
            _uploadProgress = progress / 100.0;
          });
        },
        onComplete: () {
          setState(() {
            _status = 'Upload complete!';
            _isUploading = false;
          });

          final videoUrl = client.uploadUrl.toString();
          final videoFilename = videoUrl.replaceAll(
            server.kThreeSpeakUploadUrl,
            '',
          );

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ThumbnailUploadScreen(
          //       uploadUrl: videoUrl,
          //       filename: videoFilename,
          //       oFilename: _originalFileName ?? '',
          //       size: _fileSize ?? 0,
          //       duration: _videoDuration ?? 0.0,
          //       owner: widget.owner,
          //       token: widget.token,
          //       onUploadSuccess: widget.onUploadSuccess,
          //     ),
          //   ),
          // );

          if (widget.onUploadSuccess != null) {
            widget.onUploadSuccess!({
              'uploadUrl': videoUrl,
              'filename': videoFilename,
              'oFilename': _originalFileName ?? '',
              'size': _fileSize ?? 0,
              'duration': _videoDuration ?? 0.0,
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _status = 'Upload failed: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pick your video"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pick Video Row
              InkWell(
                onTap: _isUploading ? null : _pickFile,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.video_collection, color: Colors.black),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Pick video",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.folder_open, color: Colors.black),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(_status),
              const SizedBox(height: 12),
              if (_isUploading) ...[
                LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${(_uploadProgress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isUploading ? null : _uploadFile,
            child: const Text("Next", style: TextStyle(color: Colors.black)),
          ),
        ),
      ),
    );
  }
}
