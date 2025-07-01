import 'package:hive_flutter_kit/core/models/account_history.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/models/upload_image.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/account.dart';
import 'package:hive_flutter_kit/core/models/chain_properties.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/core/models/resource_credits.dart';
import 'package:hive_flutter_kit/core/models/voting_power.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/communities_models/community_subscriber.dart';

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:crypto/crypto.dart';

import 'hive_flutter_kit_method_channel.dart';

abstract class HiveFlutterKitPlatform extends PlatformInterface {
  /// Constructs a HiveFlutterKitPlatform.
  HiveFlutterKitPlatform() : super(token: _token);
  static final Object _token = Object();
  final ImagePicker _picker = ImagePicker();

  static HiveFlutterKitPlatform _instance = MethodChannelHiveFlutterKit();

  /// The default instance of [HiveFlutterKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelHiveFlutterKit].
  static HiveFlutterKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HiveFlutterKitPlatform] when
  /// they register themselves.
  static set instance(HiveFlutterKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<LoginModel> loginWithKeychain(String username, String proof) {
    throw UnimplementedError('loginWithKeychain has not been implemented.');
  }

  Future<LoginModel> loginWithHiveAuth(String username, String proof) {
    throw UnimplementedError('loginWithHiveAuth has not been implemented.');
  }

  Future<LoginModel> loginWithPlaintextKey(
    String username,
    String postingKey,
    String proof,
  ) {
    throw UnimplementedError('loginWithPlaintextKey has not been implemented.');
  }

  Future<String> getCurrentUser() {
    throw UnimplementedError('getCurrentUser has not been implemented.');
  }

  Future<String> getQrString() {
    throw UnimplementedError('getQrString has not been implemented.');
  }

  Future<String> logout() {
    throw UnimplementedError('logout has not been implemented.');
  }

  Future<String> singleVote(String author, String permlink, int weight) {
    throw UnimplementedError('singleVote has not been implemented.');
  }

  Future<String> comment(
    String parentAuthor,
    String parentPermlink,
    String permlink,
    String title,
    String body,
    Map<String, dynamic> jsonMetadata,
  ) {
    throw UnimplementedError('comment has not been implemented.');
  }

  Future<String> commentWithOptions(
    String parentAuthor,
    String parentPermlink,
    String permlink,
    String title,
    String body,
    String jsonMetadata,
    String options,
  ) {
    throw UnimplementedError('commentWithOptions has not been implemented.');
  }

  Future<String> deleteComment(String permlink) {
    throw UnimplementedError('deleteComment has not been implemented.');
  }

  Future<String> reblog(String author, String permlink, bool reblogFlag) {
    throw UnimplementedError('reblog has not been implemented.');
  }

  Future<String> follow(String author, bool followFlag) {
    throw UnimplementedError('follow has not been implemented.');
  }

  Future<String> claimRewards() {
    throw UnimplementedError('claimRewards has not been implemented.');
  }

  Future<String> signMessage(String message, String keyType) {
    throw UnimplementedError('SignMessage has not been implemented.');
  }

  Future<bool> switchUser(String userId) {
    throw UnimplementedError('switchUser has not been implemented.');
  }

  Future<List<String>> getOtherLogins() {
    throw UnimplementedError('getOtherLogins has not been implemented.');
  }

  Future<String> removeOtherLogin(String userId) {
    throw UnimplementedError('removeOtherLogin has not been implemented.');
  }

  Future<String> addAccountAuthority(
    String account,
    String keyType,
    int weight,
  ) {
    throw UnimplementedError('addAccountAuthority has not been implemented.');
  }

  Future<String> removeAccountAuthority(String account, String keyType) {
    throw UnimplementedError(
      'removeAccountAuthority has not been implemented.',
    );
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<ChainProperties> getChainProperties() {
    throw UnimplementedError('getChainProperties() has not been implemented.');
  }

  Future<List<Discussion>> getDiscussions(
    String by, {
    required int limit,
    String tag = '',
    String? startAuthor,
    String? startPermlink,
    String? observer,
  }) {
    throw UnimplementedError('getDiscussions() has not been implemented.');
  }

  Future<List<Account>> getAccounts(List<String> usernames) {
    throw UnimplementedError('getAccounts() has not been implemented.');
  }

  Future<VotingPower> getVotingPower(String username) {
    throw UnimplementedError('getVotingPower() has not been implemented.');
  }

  Future<ResourceCredits> getResourceCredits(String username) {
    throw UnimplementedError('getResourceCredits() has not been implemented.');
  }

  Future<List<Discussion>> getAccountPosts(
    String username,
    String by, {
    required int limit,
    String? startAuthor,
    String? startPermlink,
    String? observer,
  }) {
    throw UnimplementedError('getAccountPosts() has not been implemented.');
  }

  Future<bool> hasThreespeakInAccountAuths(String username) {
    throw UnimplementedError(
      'hasThreespeakInAccountAuths has not been implemented.',
    );
  }

  Future<List<CommunityItem>> getListOfCommunities(
    String? query, {
    int limit = 20,
    String? last,
    String? observer,
  }) {
    throw UnimplementedError('getListOfCommunities has not been implemented.');
  }

  Future<List<Discussion>> getCommentsList(String author, String permlink) {
    throw UnimplementedError('getCommentsList has not been implemented.');
  }

  String _toBase64(String input) {
    List<int> bytes = utf8.encode(input); // Convert string to bytes
    String base64Str = base64Encode(bytes); // Encode to Base64
    return base64Str;
  }

  Future<UploadResponse> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String token,
    required String uploadUrlSever,
  }) async {
    final url = Uri.parse("$uploadUrlSever/$token");

    // Detect MIME type
    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
    final mediaType = MediaType.parse(mimeType);

    final request = http.MultipartRequest("POST", url);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
        contentType: mediaType,
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> resJson = jsonDecode(response.body);
        final uploadUrl = resJson['url'];

        return UploadResponse(
          success: true,
          url: uploadUrl,
          message: 'Image uploaded successfully.',
        );
      } else {
        return UploadResponse(
          success: false,
          url: null,
          message: 'Upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return UploadResponse(
        success: false,
        url: null,
        message: 'Upload error: $e',
      );
    }
  }

  Future<UploadResponse> pickImageWithMaxSize(
    int maxDimension,
    String uploadUrlSever,
  ) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) {
      throw Exception("No image selected.");
    }

    Uint8List fileBytes = await pickedFile.readAsBytes();

    // Decode to check dimensions
    img.Image? decodedImage = img.decodeImage(fileBytes);
    if (decodedImage == null) {
      throw Exception("Failed to decode image.");
    }

    int width = decodedImage.width;
    int height = decodedImage.height;

    if (width <= maxDimension && height <= maxDimension) {
      var username = await getCurrentUser();
      username = username.replaceAll("\"", "");
      int timeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      var object = {
        "signed_message": {"type": "posting", "app": "ecency.app"},
        "authors": [username],
        "timestamp": timeStamp,
      };
      final resultOfSignature = await signMessage(
        jsonEncode(object),
        'posting',
      );
      print("Result of signature: $resultOfSignature");
      final decodedResult = jsonDecode(resultOfSignature);
      if (decodedResult['success'] == true) {
        object['signatures'] = [decodedResult['result']];
        var base64StringOfObject = _toBase64(jsonEncode(object));
        var uploadedUrl = await uploadImage(
          imageBytes: fileBytes,
          fileName: pickedFile.name,
          token: base64StringOfObject,
          uploadUrlSever: uploadUrlSever,
        );
        return uploadedUrl;
      } else {
        throw Exception("Failed to sign image: ${decodedResult['error']}");
      }
    } else {
      throw Exception(
        "Image too large: $width x $height (max: $maxDimension px)",
      );
    }
  }

  Future<dynamic> signAndBroadcastTx(dynamic operationRequest, String keyType) {
    throw UnimplementedError('signAndBroadcastTx has not been implemented.');
  }

  Future<String> subscribeUnsubscribeToCommunity(
    String communityId,
    bool subscribe,
  ) {
    throw UnimplementedError(
      'subscribeUnsubscribeToCommunity has not been implemented.',
    );
  }

  Future<String> transfer(
    String recipient,
    double amount,
    String assetSymbol, // 'HIVE' or 'HBD'
    String? memo,
  ) {
    throw UnimplementedError('transfer() has not been implemented.');
  }

  Future<List<CommunitySubscriber>> getCommunitySubscribers(
    String community, {
    int limit = 100,
    String? last,
  }) {
    throw UnimplementedError(
      'getCommunitySubscribers has not been implemented.',
    );
  }

  Future<List<ActiveVote>> getActiveVotes(String author, String permlink) {
    throw UnimplementedError('getActiveVotes has not been implemented.');
  }

  Future<List<AccountHistoryOp>> getAccountHistory(
    String account, {
    int index = -1,
    int limit = 1000,
    String? start,
    String? stop,
  }) {
    throw UnimplementedError('getAccountHistory has not been implemented.');
  }

  Future<bool> isHiveKeychainAvailable() {
    throw UnimplementedError(
      'isHiveKeychainAvailable has not been implemented.',
    );
  }
}
