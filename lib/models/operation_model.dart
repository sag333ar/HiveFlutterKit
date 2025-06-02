import 'dart:convert';

class Operation {
  final String type;
  final Map<String, dynamic> data;

  Operation({required this.type, required this.data});

  factory Operation.fromJson(List<dynamic> json) {
    return Operation(
      type: json[0] as String,
      data: Map<String, dynamic>.from(json[1] as Map),
    );
  }

  List toJson() => [type, data];
}

class OperationRequest {
  final List<Operation> operations;

  OperationRequest({required this.operations});

  factory OperationRequest.fromJson(List<dynamic> json) {
    return OperationRequest(
      operations: json.map((e) => Operation.fromJson(e as List)).toList(),
    );
  }

  List toJson() => operations.map((op) => op.toJson()).toList();
}

class OperationProfile {
  final String? name;
  final int? version;
  final String? website;
  final String? profileImage;
  final String? about;
  final String? location;
  final String? coverImage;
  final String? btcLightningAddress;

  OperationProfile({
    this.name,
    this.version,
    this.website,
    this.profileImage,
    this.about,
    this.location,
    this.coverImage,
    this.btcLightningAddress,
  });

  factory OperationProfile.fromJson(Map<String, dynamic> json) {
    return OperationProfile(
      name: json['name'],
      version: json['version'],
      website: json['website'],
      profileImage: json['profile_image'],
      about: json['about'],
      location: json['location'],
      coverImage: json['cover_image'],
      btcLightningAddress: json['btcLightningAddress'],
    );
  }
}

class OperationBlockChainData {
  final String? address;
  final String? signature;

  OperationBlockChainData({this.address, this.signature});

  factory OperationBlockChainData.fromJson(Map<String, dynamic> json) {
    return OperationBlockChainData(
      address: json['address'],
      signature: json['signature'],
    );
  }
}

class OperationExtra {
  final String? name;
  final OperationBlockChainData? blockChainData;
  final String? loginMethod;

  OperationExtra({this.name, this.blockChainData, this.loginMethod});

  factory OperationExtra.fromJson(Map<String, dynamic> json) {
    final blockChainDataJson = json['blockChainData']?['data'];
    return OperationExtra(
      name: json['name'],
      blockChainData: blockChainDataJson != null
          ? OperationBlockChainData.fromJson(blockChainDataJson)
          : null,
      loginMethod: json['blockChainData']?['loginMethod'],
    );
  }
}

class OperationBitcoin {
  final String? address;
  final String? ordinalAddress;
  final String? signature;
  final String? message;

  OperationBitcoin({
    this.address,
    this.ordinalAddress,
    this.signature,
    this.message,
  });

  factory OperationBitcoin.fromJson(Map<String, dynamic> json) {
    return OperationBitcoin(
      address: json['address'],
      ordinalAddress: json['ordinalAddress'],
      signature: json['signature'],
      message: json['message'],
    );
  }
}

class OperationResponse {
  final OperationProfile? profile;
  final OperationExtra? extra;
  final OperationBitcoin? bitcoin;

  OperationResponse({this.profile, this.extra, this.bitcoin});

  factory OperationResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OperationResponse();
    return OperationResponse(
      profile: json['profile'] != null
          ? OperationProfile.fromJson(json['profile'])
          : null,
      extra: json['extra'] != null
          ? OperationExtra.fromJson(json['extra'])
          : null,
      bitcoin: json['bitcoin'] != null
          ? OperationBitcoin.fromJson(json['bitcoin'])
          : null,
    );
  }

  static OperationResponse fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return OperationResponse();
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return OperationResponse.fromJson(map);
    } catch (_) {
      return OperationResponse();
    }
  }

  Map<String, dynamic> toJson() => {
    if (profile != null) 'profile': {
      'name': profile?.name,
      'version': profile?.version,
      'website': profile?.website,
      'profile_image': profile?.profileImage,
      'about': profile?.about,
      'location': profile?.location,
      'cover_image': profile?.coverImage,
      'btcLightningAddress': profile?.btcLightningAddress,
    },
    if (extra != null) 'extra': {
      'name': extra?.name,
      'blockChainData': extra?.blockChainData != null
          ? {
        'data': {
          'address': extra?.blockChainData?.address,
          'signature': extra?.blockChainData?.signature,
        },
        'loginMethod': extra?.loginMethod,
      }
          : null,
    },
    if (bitcoin != null) 'bitcoin': {
      'address': bitcoin?.address,
      'ordinalAddress': bitcoin?.ordinalAddress,
      'signature': bitcoin?.signature,
      'message': bitcoin?.message,
    },
  };
}
