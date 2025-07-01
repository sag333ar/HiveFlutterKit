import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class ImageBroadcast extends StatefulWidget {
  const ImageBroadcast({super.key});

  @override
  State<ImageBroadcast> createState() => _ImageBroadcastState();
}

class _ImageBroadcastState extends State<ImageBroadcast> {
  late HiveFlutterKitPlatform hfk;

  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _isBroadcasting = false;
  String? _broadcastResult;

  @override
  void initState() {
    super.initState();
    hfk = HiveFlutterKitPlatform.instance;
  }

  Future<void> _signAndBroadcastTx() async {
    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first')),
      );
      return;
    }

    setState(() {
      _isBroadcasting = true;
      _broadcastResult = null;
    });

    try {
      // Fetch account and decode posting_json_metadata
      final username = "shaktimaaan";
      final accounts = await hfk.getAccounts([username]);
      if (accounts.isEmpty) throw Exception("Account not found");

      final account = accounts.first;
      final postingJsonMetadataStr = account.postingJsonMetadata;
      if (postingJsonMetadataStr == null || postingJsonMetadataStr.isEmpty) {
        throw Exception("No posting_json_metadata found for account");
      }

      // Decode and update profile_image
      final postingJsonMetadata = jsonDecode(postingJsonMetadataStr);
      if (postingJsonMetadata is! Map<String, dynamic>) {
        throw Exception("Invalid posting_json_metadata format");
      }

      // Update profile_image
      if (postingJsonMetadata.containsKey('profile') &&
          postingJsonMetadata['profile'] is Map<String, dynamic>) {
        postingJsonMetadata['profile']['profile_image'] = _uploadedImageUrl;
      }

      print(
        'Updated profile_image: ${postingJsonMetadata['profile']['profile_image']}',
      );

      // Prepare operation data as dynamic
      final operationData = {
        "account": username,
        "json_metadata": "",
        "posting_json_metadata": jsonEncode(postingJsonMetadata),
        "extensions": [],
      };

      // Use dynamic for operation and operationRequest
      final dynamic operation = ["account_update2", operationData];
      final dynamic operationRequest = [operation];

      final response = await hfk.signAndBroadcastTx(
        operationRequest,
        'posting',
      );

      // Handle response as dynamic
      if (response != null && response['success'] == true) {
        setState(() {
          _broadcastResult =
              response['profile']?['profile_image'] ??
              'Broadcasted successfully!';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Broadcast Success')));
      } else {
        setState(() {
          _broadcastResult =
              'Broadcast failed: ${response?['error'] ?? 'Unknown error'}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Broadcast failed: ${response?['error'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _broadcastResult = 'Broadcast failed: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Broadcast failed: $e')));
    } finally {
      setState(() {
        _isBroadcasting = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      // _isUploading = true;
      _uploadedImageUrl = null;
    });
    try {
      final res = await hfk.pickImageWithMaxSize(
        2000,
        "https://images.ecency.com/hs",
      );
      setState(() {
        _uploadedImageUrl = res.url;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image uploaded: ${res.url}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Broadcast')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              const Text(
                'Upload Profile Image and Broadcast Operation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_uploadedImageUrl != null)
                Image.network(_uploadedImageUrl!, width: 120, height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isUploading ? null : _pickAndUploadImage,
                    child:
                        _isUploading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Pick & Upload Image'),
                  ),
                ],
              ),
              if (_uploadedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Uploaded URL: $_uploadedImageUrl',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ElevatedButton(
                onPressed:
                    (_uploadedImageUrl != null && !_isBroadcasting)
                        ? _signAndBroadcastTx
                        : null,
                child:
                    _isBroadcasting
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Sign & Broadcast Tx'),
              ),
              if (_broadcastResult != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Broadcast Result: $_broadcastResult',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const Divider(),
          ],
        ),
      ),
    );
  }
}