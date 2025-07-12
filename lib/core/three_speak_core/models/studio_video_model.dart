import 'dart:convert';
import 'dart:ffi';

import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';

class VideoFeedGridItemViewModel {
  String title;
  String author;
  String permlink;
  DateTime created;
  String category; // community / tag
  int? numOfUpvotes;
  int? numOfComments;
  Float? hiveValue;
  int? duration;
  String? thumbnail;

  VideoFeedGridItemViewModel({
    required this.title,
    required this.author,
    required this.permlink,
    required this.created,
    required this.category,
    required this.numOfUpvotes,
    required this.numOfComments,
    required this.hiveValue,
    required this.duration,
    required this.thumbnail,
  });

  static VideoFeedGridItemViewModel fromThreeSpeakVideo(ThreeSpeakVideo video) {
    return VideoFeedGridItemViewModel(
      title: video.title ?? '',
      author: video.owner ?? '',
      permlink: video.permlink ?? '',
      created: video.created ?? DateTime.now(),
      category: video.category ?? '',
      numOfComments: null,
      numOfUpvotes: null,
      hiveValue: null,
      duration: video.duration ?? 0,
      thumbnail: video.getThumbnail(),
    );
  }

  static VideoFeedGridItemViewModel fromGQLFeedItem(GQLFeedItem video) {
    return VideoFeedGridItemViewModel(
      title: video.title ?? '',
      author: video.author?.username ?? '',
      permlink: video.permlink ?? '',
      created: video.createdAt ?? DateTime.now()),
      category: video.category ?? '',
      numOfComments: null,
      numOfUpvotes: null,
      hiveValue: null,
      duration: video.duration ?? 0,
      thumbnail: video.getThumbnail(),
    );
  }
}

class ThreeSpeakVideo {
  Map<String, bool>? encoding;
  bool? updateSteem;
  bool? lowRc;
  bool? needsBlockchainUpdate;
  String? status;
  String? encodingPriceSteem;
  bool? paid;
  int? encodingProgress;
  DateTime? created;
  bool? is3CjContent;
  bool? isVod;
  bool? isNsfwContent;
  bool? declineRewards;
  bool? rewardPowerup;
  String? language;
  String? category;
  bool? firstUpload;
  String? community;
  bool? indexed;
  int? views;
  String? hive;
  bool? upvoteEligible;
  String? publishType;
  String? beneficiaries;
  int? votePercent;
  bool? reducedUpvote;
  bool? donations;
  bool? postToHiveBlog;
  List<String>? tagsV2;
  bool? fromMobile;
  bool? isReel;
  int? width;
  int? height;
  bool? isAudio;
  dynamic jsonMetaDataAppName;
  String? id;
  String? originalFilename;
  String? permlink;
  int? duration;
  int? size;
  String? owner;
  String? uploadType;
  String? title;
  String? description;
  String? tags;
  int? v;
  String? filename;
  String? localFilename;
  String? thumbnail;
  String? videoV2;
  List<dynamic>? badges;
  bool? curationComplete;
  bool? hasAudioOnlyVersion;
  bool? hasTorrent;
  bool? isB2;
  bool? needsHiveUpdate;
  bool? pinned;
  bool? publishFailed;
  bool? recommended;
  double? score;
  bool? steemPosted;
  String? jobId;

  ThreeSpeakVideo({
    this.encoding,
    this.updateSteem,
    this.lowRc,
    this.needsBlockchainUpdate,
    this.status,
    this.encodingPriceSteem,
    this.paid,
    this.encodingProgress,
    this.created,
    this.is3CjContent,
    this.isVod,
    this.isNsfwContent,
    this.declineRewards,
    this.rewardPowerup,
    this.language,
    this.category,
    this.firstUpload,
    this.community,
    this.indexed,
    this.views,
    this.hive,
    this.upvoteEligible,
    this.publishType,
    this.beneficiaries,
    this.votePercent,
    this.reducedUpvote,
    this.donations,
    this.postToHiveBlog,
    this.tagsV2,
    this.fromMobile,
    this.isReel,
    this.width,
    this.height,
    this.isAudio,
    this.jsonMetaDataAppName,
    this.id,
    this.originalFilename,
    this.permlink,
    this.duration,
    this.size,
    this.owner,
    this.uploadType,
    this.title,
    this.description,
    this.tags,
    this.v,
    this.filename,
    this.localFilename,
    this.thumbnail,
    this.videoV2,
    this.badges,
    this.curationComplete,
    this.hasAudioOnlyVersion,
    this.hasTorrent,
    this.isB2,
    this.needsHiveUpdate,
    this.pinned,
    this.publishFailed,
    this.recommended,
    this.score,
    this.steemPosted,
    this.jobId,
  });

  factory ThreeSpeakVideo.fromRawJson(String str) =>
      ThreeSpeakVideo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  static List<ThreeSpeakVideo> threeSpeakVideosFromJsonString(String string) {
    return List<ThreeSpeakVideo>.from(
      json.decode(string).map((x) => ThreeSpeakVideo.fromJson(x)),
    );
  }

  factory ThreeSpeakVideo.fromJson(Map<String, dynamic> json) =>
      ThreeSpeakVideo(
        encoding: Map.from(
          json["encoding"]!,
        ).map((k, v) => MapEntry<String, bool>(k, v)),
        updateSteem: json["updateSteem"],
        lowRc: json["lowRc"],
        needsBlockchainUpdate: json["needsBlockchainUpdate"],
        status: json["status"],
        encodingPriceSteem: json["encoding_price_steem"],
        paid: json["paid"],
        encodingProgress:
            json["encodingProgress"] == null
                ? null
                : (json["encodingProgress"] as num).toInt(),
        created:
            json["created"] == null ? null : DateTime.parse(json["created"]),
        is3CjContent: json["is3CJContent"],
        isVod: json["isVOD"],
        isNsfwContent: json["isNsfwContent"],
        declineRewards: json["declineRewards"],
        rewardPowerup: json["rewardPowerup"],
        language: json["language"],
        category: json["category"],
        firstUpload: json["firstUpload"],
        community: json["community"],
        indexed: json["indexed"],
        views: json["views"],
        hive: json["hive"],
        upvoteEligible: json["upvoteEligible"],
        publishType: json["publish_type"],
        beneficiaries: json["beneficiaries"],
        votePercent:
            json["votePercent"] == null
                ? null
                : (json["votePercent"] as num).toInt(),
        reducedUpvote: json["reducedUpvote"],
        donations: json["donations"],
        postToHiveBlog: json["postToHiveBlog"],
        tagsV2:
            json["tags_v2"] == null
                ? []
                : List<String>.from(json["tags_v2"]!.map((x) => x)),
        fromMobile: json["fromMobile"],
        isReel: json["isReel"],
        width: json["width"],
        height: json["height"],
        isAudio: json["isAudio"],
        jsonMetaDataAppName: json["jsonMetaDataAppName"],
        id: json["_id"],
        originalFilename: json["originalFilename"],
        permlink: json["permlink"],
        duration:
            json["duration"] == null ? null : (json["duration"] as num).toInt(),
        size: json["size"] == null ? null : (json["size"] as num).toInt(),
        owner: json["owner"],
        uploadType: json["upload_type"],
        title: json["title"],
        description: json["description"],
        tags: json["tags"],
        v: json["__v"] == null ? null : (json["__v"] as num).toInt(),
        filename: json["filename"],
        localFilename: json["local_filename"],
        thumbnail: json["thumbnail"],
        videoV2: json["video_v2"],
        badges:
            json["badges"] == null
                ? []
                : List<dynamic>.from(json["badges"]!.map((x) => x)),
        curationComplete: json["curationComplete"],
        hasAudioOnlyVersion: json["hasAudioOnlyVersion"],
        hasTorrent: json["hasTorrent"],
        isB2: json["isB2"],
        needsHiveUpdate: json["needsHiveUpdate"],
        pinned: json["pinned"],
        publishFailed: json["publishFailed"],
        recommended: json["recommended"],
        score: json["score"]?.toDouble(),
        steemPosted: json["steemPosted"],
        jobId: json["job_id"],
      );

  Map<String, dynamic> toJson() => {
    "encoding": Map.from(
      encoding!,
    ).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "updateSteem": updateSteem,
    "lowRc": lowRc,
    "needsBlockchainUpdate": needsBlockchainUpdate,
    "status": status,
    "encoding_price_steem": encodingPriceSteem,
    "paid": paid,
    "encodingProgress": encodingProgress,
    "created": created?.toIso8601String(),
    "is3CJContent": is3CjContent,
    "isVOD": isVod,
    "isNsfwContent": isNsfwContent,
    "declineRewards": declineRewards,
    "rewardPowerup": rewardPowerup,
    "language": language,
    "category": category,
    "firstUpload": firstUpload,
    "community": community,
    "indexed": indexed,
    "views": views,
    "hive": hive,
    "upvoteEligible": upvoteEligible,
    "publish_type": publishType,
    "beneficiaries": beneficiaries,
    "votePercent": votePercent,
    "reducedUpvote": reducedUpvote,
    "donations": donations,
    "postToHiveBlog": postToHiveBlog,
    "tags_v2": tagsV2 == null ? [] : List<dynamic>.from(tagsV2!.map((x) => x)),
    "fromMobile": fromMobile,
    "isReel": isReel,
    "width": width,
    "height": height,
    "isAudio": isAudio,
    "jsonMetaDataAppName": jsonMetaDataAppName,
    "_id": id,
    "originalFilename": originalFilename,
    "permlink": permlink,
    "duration": duration,
    "size": size,
    "owner": owner,
    "upload_type": uploadType,
    "title": title,
    "description": description,
    "tags": tags,
    "__v": v,
    "filename": filename,
    "local_filename": localFilename,
    "thumbnail": thumbnail,
    "video_v2": videoV2,
    "badges": badges == null ? [] : List<dynamic>.from(badges!.map((x) => x)),
    "curationComplete": curationComplete,
    "hasAudioOnlyVersion": hasAudioOnlyVersion,
    "hasTorrent": hasTorrent,
    "isB2": isB2,
    "needsHiveUpdate": needsHiveUpdate,
    "pinned": pinned,
    "publishFailed": publishFailed,
    "recommended": recommended,
    "score": score,
    "steemPosted": steemPosted,
    "job_id": jobId,
  };

  String getThumbnail() {
    return thumbnail ??
        ''.replaceAll('ipfs://', 'https://ipfs-3speak.b-cdn.net/ipfs/');
  }
}
