import 'dart:convert';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class ProfileService {
  final HiveFlutterKitPlatform hfk;
  final Function(String) showSnackBar;

  ProfileService({
    required this.hfk,
    required this.showSnackBar,
  });

  Future<String?> pickAndUploadImage() async {
    try {
      final res = await hfk.pickImageWithMaxSize(
        2000,
        "https://images.ecency.com/hs",
      );
      showSnackBar('Image uploaded: ${res.url}');
      return res.url;
    } catch (e) {
      showSnackBar('Upload failed: $e');
      return null;
    }
  }

  Future<String?> signAndBroadcastProfileImageTx(String? uploadedImageUrl, String username) async {
    if (uploadedImageUrl == null) {
      showSnackBar('Please upload an image first');
      return 'Error: No image URL provided.';
    }

    try {
      final accounts = await hfk.getAccounts([username]);
      if (accounts.isEmpty) throw Exception("Account not found");

      final account = accounts.first;
      final postingJsonMetadataStr = account.postingJsonMetadata;
      if (postingJsonMetadataStr == null || postingJsonMetadataStr.isEmpty) {
        throw Exception("No posting_json_metadata found for account");
      }

      final postingJsonMetadata = jsonDecode(postingJsonMetadataStr);
      if (postingJsonMetadata is! Map<String, dynamic>) {
        throw Exception("Invalid posting_json_metadata format");
      }

      if (postingJsonMetadata.containsKey('profile') &&
          postingJsonMetadata['profile'] is Map<String, dynamic>) {
        postingJsonMetadata['profile']['profile_image'] = uploadedImageUrl;
      } else {
        // Ensure 'profile' key exists and is a map
        postingJsonMetadata['profile'] = {'profile_image': uploadedImageUrl};
      }

      print('Updated profile_image: ${postingJsonMetadata['profile']['profile_image']}');

      final operationData = {
        "account": username,
        "json_metadata": account.jsonMetadata ?? "", // Preserve existing json_metadata
        "posting_json_metadata": jsonEncode(postingJsonMetadata),
        "extensions": [],
      };

      final dynamic operation = ["account_update2", operationData];
      final dynamic operationRequest = [operation];

      final response = await hfk.signAndBroadcastTx(operationRequest, 'posting');

      if (response != null && response['success'] == true) {
        showSnackBar('Broadcast Success');
        return response['profile']?['profile_image'] ?? 'Broadcasted successfully!';
      } else {
        final error = response?['error'] ?? 'Unknown error';
        showSnackBar('Broadcast failed: $error');
        return 'Broadcast failed: $error';
      }
    } catch (e) {
      showSnackBar('Broadcast failed: $e');
      return 'Broadcast failed: $e';
    }
  }
}
