import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/upload_info_screen.dart';
import 'package:another_tus_client/another_tus_client.dart';
import 'package:http/http.dart' as http;

// Global endpoints
const String kThreeSpeakUploadUrl = 'https://uploads.3speak.tv/files/';
const String kThreeSpeakApiUrl = 'https://studio.3speak.tv/mobile/api';

class ThumbnailUploadScreen extends StatefulWidget {
  final String uploadUrl;
  final String oFilename;
  final String filename;
  final int size;
  final double duration;
  final String owner;
  final String token;
  final UploadSuccessCallback? onUploadSuccess;

  const ThumbnailUploadScreen({
    super.key,
    required this.uploadUrl,
    required this.oFilename,
    required this.size,
    required this.duration,
    required this.owner,
    required this.filename,
    required this.token,
    this.onUploadSuccess,
  });

  @override
  State<ThumbnailUploadScreen> createState() => _ThumbnailUploadScreenState();
}

class _ThumbnailUploadScreenState extends State<ThumbnailUploadScreen> {
  XFile? _thumbnailFile;
  String _status = 'Generating thumbnail...';
  bool _isUploading = false;
  double _uploadProgress = 0.0; // Add this line

  final GlobalKey _previewContainer = GlobalKey();
  Uint8List? _thumbnailBytes;
  bool _isCustomThumbnail = false;

  final double thumbnailHeight = 180.0;
  final double thumbnailAspectRatio = 16 / 9;

  Future<void> _pickThumbnail() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final bytes = file.bytes!;

        final XFile pickedFile = XFile.fromData(
          bytes,
          name: file.name,
          mimeType: 'image/${file.extension}',
        );

        if (mounted) {
          setState(() {
            _thumbnailFile = pickedFile;
            _thumbnailBytes = bytes;
            _status = 'Custom thumbnail selected';
            _isCustomThumbnail = true;
          });
        }
      }
    } catch (e) {
      setState(() => _status = 'Error selecting thumbnail: $e');
    }
  }

  Future<void> _handleNext() async {
    if (_thumbnailFile == null) return;

    setState(() {
      _isUploading = true;
      _status = 'Processing thumbnail...';
      _uploadProgress = 0.0;
    });

    try {
      final client = TusClient(_thumbnailFile!, store: TusMemoryStore());

      await client.upload(
        uri: Uri.parse(kThreeSpeakUploadUrl),
        onProgress: (progress, _) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress / 100.0;
              _status = 'Uploading thumbnail: ${progress.toInt()}%';
            });
          }
        },
      );

      final thumbnailUrl = client.uploadUrl.toString();
      final thumbnailFilename = thumbnailUrl.replaceAll(
        kThreeSpeakUploadUrl,
        '',
      );

      final response = await http.post(
        Uri.parse('$kThreeSpeakApiUrl/upload_info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'filename': widget.filename,
          'oFilename': widget.oFilename,
          'size': widget.size,
          'duration': widget.duration,
          'thumbnail': thumbnailFilename,
          'owner': widget.owner,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resp = jsonDecode(response.body);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UploadInfoScreen(
                videoId: resp['_id'],
                thumbnail: thumbnailFilename,
                token: widget.token,
                owner: widget.owner,
                onUploadSuccess: widget.onUploadSuccess,
              ),
            ),
          );
        }
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error: $e';
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pick your thumbnail"),
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
              // Use this block to show the thumbnail preview (video frame) if not custom
              if (!_isCustomThumbnail) ...[
                Center(
                  child: SizedBox(
                    height: thumbnailHeight,
                    width: thumbnailHeight * thumbnailAspectRatio,
                    child: Stack(
                      children: [
                        // Placeholder content
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to pick a thumbnail",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tap area
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (_isUploading) ? null : _pickThumbnail,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Thumbnail preview or loading
              if (_thumbnailBytes != null)
                Center(
                  child: Column(
                    children: [
                      if (_isCustomThumbnail)
                        InkWell(
                          onTap: (_isUploading) ? null : _pickThumbnail,
                          child: SizedBox(
                            height: thumbnailHeight,
                            width: thumbnailHeight * thumbnailAspectRatio,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _thumbnailBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap above to change thumbnail",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              // Upload progress indicator
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
                const SizedBox(height: 12),
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
            onPressed:
                (_isUploading || _thumbnailBytes == null) ? null : _handleNext,
            child: Text(
              _isUploading ? "Uploading..." : "Next",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
