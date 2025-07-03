import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive_flutter_kit/core/models/hive_mobile/beneficiary_model.dart';
import 'package:hive_flutter_kit/core/models/hive_mobile/post_detail_model.dart';
import 'package:hive_flutter_kit/core/models/hive_mobile/post_json_meta_data.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/safe_convert.dart';
class PostFeedModel extends Equatable {
  final int postId;
  final String author;
  final String permlink;
  final String? category;
  final String title;
  final String body;
  final PostJsonMetadata? jsonMetadata;
  final DateTime created;
  final DateTime? lastUpdate;
  final int? depth;
  final int? children;
  final int? netRshares;
  final DateTime? lastPayout;
  final DateTime? cashoutTime;
  final String? totalPayoutValue;
  final String? curatorPayoutValue;
  final String? pendingPayoutValue;
  final String? promoted;
  final List<dynamic>? replies;
  final int? bodyLength;
  final int? authorReputation;
  final List<ActiveVoteModel>? activeVotes;
  final String? parentAuthor;
  final String? parentPermlink;
  final String? url;
  final String? rootTitle;
  final List<BeneficiaryModel>? beneficiaries;
  final String? maxAcceptedPayout;
  final int? percentHBD;
  final bool visited ;

  const PostFeedModel({
    this.visited = false,
    required this.postId,
    required this.author,
    this.permlink = "",
    this.category,
    required this.title,
    required this.body,
    this.jsonMetadata,
    required this.created,
    this.lastUpdate,
    this.depth,
    this.children,
    this.netRshares,
    this.lastPayout,
    this.cashoutTime,
    this.totalPayoutValue,
    this.curatorPayoutValue,
    this.pendingPayoutValue,
    this.promoted,
    this.replies,
    this.bodyLength,
    this.authorReputation,
    this.activeVotes,
    this.parentAuthor,
    this.parentPermlink,
    this.url,
    this.rootTitle,
    this.beneficiaries,
    this.maxAcceptedPayout,
    this.percentHBD,
  });

  PostFeedModel copyWith({
    int? postId,
    String? author,
    String? permlink,
    String? category,
    String? title,
    String? body,
    PostJsonMetadata? jsonMetadata,
    DateTime? created,
    DateTime? lastUpdate,
    int? depth,
    int? children,
    int? netRshares,
    DateTime? lastPayout,
    DateTime? cashoutTime,
    String? totalPayoutValue,
    String? curatorPayoutValue,
    String? pendingPayoutValue,
    String? promoted,
    List<dynamic>? replies,
    int? bodyLength,
    int? authorReputation,
    List<ActiveVoteModel>? activeVotes,
    String? parentAuthor,
    String? parentPermlink,
    String? url,
    String? rootTitle,
    List<BeneficiaryModel>? beneficiaries,
    String? maxAcceptedPayout,
    int? percentHBD,
    bool? visited
  }) =>
      PostFeedModel(
        postId: postId ?? this.postId,
        author: author ?? this.author,
        permlink: permlink ?? this.permlink,
        category: category ?? this.category,
        title: title ?? this.title,
        body: body ?? this.body,
        jsonMetadata: jsonMetadata ?? this.jsonMetadata,
        created: created ?? this.created,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        depth: depth ?? this.depth,
        children: children ?? this.children,
        netRshares: netRshares ?? this.netRshares,
        lastPayout: lastPayout ?? this.lastPayout,
        cashoutTime: cashoutTime ?? this.cashoutTime,
        totalPayoutValue: totalPayoutValue ?? this.totalPayoutValue,
        curatorPayoutValue: curatorPayoutValue ?? this.curatorPayoutValue,
        pendingPayoutValue: pendingPayoutValue ?? this.pendingPayoutValue,
        promoted: promoted ?? this.promoted,
        replies: replies ?? this.replies,
        bodyLength: bodyLength ?? this.bodyLength,
        authorReputation: authorReputation ?? this.authorReputation,
        activeVotes: activeVotes ?? this.activeVotes,
        parentAuthor: parentAuthor ?? this.parentAuthor,
        parentPermlink: parentPermlink ?? this.parentPermlink,
        url: url ?? this.url,
        rootTitle: rootTitle ?? this.rootTitle,
        beneficiaries: beneficiaries ?? this.beneficiaries,
        maxAcceptedPayout: maxAcceptedPayout ?? this.maxAcceptedPayout,
        percentHBD: percentHBD ?? this.percentHBD,
        visited: visited ?? this.visited,
      );

  factory PostFeedModel.fromJson(Map<String, dynamic> json) => PostFeedModel(
        postId: json["post_id"],
        author: asString(json, "author"),
        permlink: asString(json, "permlink"),
        category: json["category"],
        title: asString(json, "title"),
        body: asString(json, "body"),
        jsonMetadata: parseJsonMetaData(json['json_metadata']),
        created: DateTime.parse(json["created"]),
        lastUpdate: json["last_update"] != null
            ? DateTime.parse(json["last_update"])
            : null,
        depth: json["depth"],
        children: json["children"],
        netRshares: json["net_rshares"],
        lastPayout: json["last_payout"] != null
            ? DateTime.parse(json["last_payout"])
            : null,
        cashoutTime: json["cashout_time"] != null
            ? DateTime.parse(json["cashout_time"])
            : null,
        totalPayoutValue: json["total_payout_value"],
        curatorPayoutValue: json["curator_payout_value"],
        pendingPayoutValue: json["pending_payout_value"],
        promoted: json["promoted"],
        replies: List<dynamic>.from(json["replies"].map((x) => x)),
        bodyLength: asInt(json, "body_length"),
        authorReputation: asInt(json, 'author_reputation'),
        activeVotes: List<ActiveVoteModel>.from(
            json["active_votes"].map((x) => ActiveVoteModel.fromJson(x))),
        parentAuthor: json["parent_author"],
        parentPermlink: json["parent_permlink"],
        url: json["url"],
        rootTitle: json["root_title"],
        beneficiaries: List<BeneficiaryModel>.from(
            json["beneficiaries"].map((x) => BeneficiaryModel.fromJson(x))),
        maxAcceptedPayout: json["max_accepted_payout"],
        percentHBD: json["percent_hbd"],
      );

  static PostJsonMetadata? parseJsonMetaData(dynamic data) {
    if (data != null) {
      if (data is String) {
        Map<String, dynamic> map = json.decode(data);
        return PostJsonMetadata.fromJson(map);
      } else {
        if (data is Map) {
          return PostJsonMetadata.fromJson(data as Map<String, dynamic>);
        }
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [postId, author, permlink];
}
