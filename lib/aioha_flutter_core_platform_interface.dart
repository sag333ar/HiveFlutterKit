import 'package:aioha_flutter_core/models/login_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:aioha_flutter_core/models/account.dart';
import 'package:aioha_flutter_core/models/chain_properties.dart';
import 'package:aioha_flutter_core/models/discussion.dart';
import 'package:aioha_flutter_core/models/resource_credits.dart';
import 'package:aioha_flutter_core/models/voting_power.dart';
import 'package:aioha_flutter_core/models/community_model.dart';
import 'package:aioha_flutter_core/models/operation_model.dart';

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:crypto/crypto.dart';

import 'aioha_flutter_core_method_channel.dart';

abstract class AiohaFlutterCorePlatform extends PlatformInterface {
  /// Constructs a AiohaFlutterCorePlatform.
  AiohaFlutterCorePlatform() : super(token: _token);
  static final Object _token = Object();
  final ImagePicker _picker = ImagePicker();

  static AiohaFlutterCorePlatform _instance = MethodChannelAiohaFlutterCore();

  /// The default instance of [AiohaFlutterCorePlatform] to use.
  ///
  /// Defaults to [MethodChannelAiohaFlutterCore].
  static AiohaFlutterCorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AiohaFlutterCorePlatform] when
  /// they register themselves.
  static set instance(AiohaFlutterCorePlatform instance) {
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

  String computeSha256(Uint8List data) {
    Digest digest = sha256.convert(data);
    return digest.toString();
  }

  String toBase64(String input) {
    List<int> bytes = utf8.encode(input); // Convert string to bytes
    String base64Str = base64Encode(bytes); // Encode to Base64
    return base64Str;
  }

  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String token,
    required String uploadUrlSever,
  }) async {
    final url = Uri.parse("$uploadUrlSever/$token");

    // Detect MIME type (e.g., image/jpeg or image/png)
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

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> resJson = jsonDecode(response.body);
      final uploadUrl = resJson['url'];
      print("✅ Uploaded URL: $uploadUrl");
      return uploadUrl;
    } else {
      print("❌ Upload failed: ${response.statusCode}");
      print("Response: ${response.body}");
      throw Exception(
        "Upload failed: ${response.statusCode} - ${response.body}",
      );
    }
  }

  Future<String> pickImageWithMaxSize(int maxDimension,String uploadUrlSever) async {
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
        var base64StringOfObject = toBase64(jsonEncode(object));
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

  Future<OperationResponse> signAndBroadcastTx(
    OperationRequest operationRequest,
    String keyType,
  ) {
    throw UnimplementedError('signAndBroadcastTx has not been implemented.');
  }
}
