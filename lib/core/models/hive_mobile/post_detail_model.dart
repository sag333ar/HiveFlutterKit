import 'package:hive_flutter_kit/core/models/hive_mobile/beneficiary_model.dart';
import 'package:hive_flutter_kit/core/models/hive_mobile/post_feed_model.dart';
import 'package:hive_flutter_kit/core/models/hive_mobile/post_json_meta_data.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/safe_convert.dart';

class PostDetailModel {
  final int? absRshares;
  final List<ActiveVoteModel>? activeVotes;
  final bool? allowCurationRewards;
  final bool? allowReplies;
  final bool? allowVotes;
  final String author;
  final int? authorReputation;
  final int? authorRewards;
  final List<BeneficiaryModel>? beneficiaries;
  final String body;
  final int? bodyLength;
  final DateTime? cashoutTime;
  final String? category;
  final int children;
  final int? childrenAbsRshares;
  final DateTime? created;
  final String? curatorPayoutValue;
  final int? depth;
  final int? id;
  final PostJsonMetadata? jsonMetadata;
  final DateTime? lastPayout;
  final DateTime? lastUpdate;
  final String? maxAcceptedPayout;
  final DateTime? maxCashoutTime;
  final int? netRshares;
  final int? netVotes;
  final String? parentAuthor;
  final String? parentPermlink;
  final String? pendingPayoutValue;
  final int? percentHbd;
  final String? permlink;
  final String? promoted;
  final List<dynamic>? rebloggedBy;
  final List<dynamic>? replies;
  final int? rewardWeight;
  final String? rootAuthor;
  final String? rootPermlink;
  final String? rootTitle;
  final String? title;
  final String? totalPayoutValue;
  final String? totalPendingPayoutValue;
  final int? totalVoteWeight;
  final String? url;
  final int? voteRshares;

  PostDetailModel({
    this.absRshares,
    this.activeVotes,
    this.allowCurationRewards,
    this.allowReplies,
    this.allowVotes,
    required this.author,
    this.authorReputation,
    this.authorRewards,
    this.beneficiaries,
    required this.body,
    this.bodyLength,
    this.cashoutTime,
    this.category,
    this.children = 0,
    this.childrenAbsRshares,
    this.created,
    this.curatorPayoutValue,
    this.depth,
    this.id,
    this.jsonMetadata,
    this.lastPayout,
    this.lastUpdate,
    this.maxAcceptedPayout,
    this.maxCashoutTime,
    this.netRshares,
    this.netVotes,
    this.parentAuthor,
    this.parentPermlink,
    this.pendingPayoutValue,
    this.percentHbd,
    this.permlink,
    this.promoted,
    this.rebloggedBy,
    this.replies,
    this.rewardWeight,
    this.rootAuthor,
    this.rootPermlink,
    this.rootTitle,
    this.title,
    this.totalPayoutValue,
    this.totalPendingPayoutValue,
    this.totalVoteWeight,
    this.url,
    this.voteRshares,
  });

  PostDetailModel copyWith({
    int? absRshares,
    List<ActiveVoteModel>? activeVotes,
    bool? allowCurationRewards,
    bool? allowReplies,
    bool? allowVotes,
    String? author,
    int? authorReputation,
    int? authorRewards,
    List<BeneficiaryModel>? beneficiaries,
    String? body,
    int? bodyLength,
    DateTime? cashoutTime,
    String? category,
    int? children,
    int? childrenAbsRshares,
    DateTime? created,
    String? curatorPayoutValue,
    int? depth,
    int? id,
    PostJsonMetadata? jsonMetadata,
    DateTime? lastPayout,
    DateTime? lastUpdate,
    String? maxAcceptedPayout,
    DateTime? maxCashoutTime,
    int? netRshares,
    int? netVotes,
    String? parentAuthor,
    String? parentPermlink,
    String? pendingPayoutValue,
    int? percentHbd,
    String? permlink,
    String? promoted,
    List<dynamic>? rebloggedBy,
    List<dynamic>? replies,
    int? rewardWeight,
    String? rootAuthor,
    String? rootPermlink,
    String? rootTitle,
    String? title,
    String? totalPayoutValue,
    String? totalPendingPayoutValue,
    int? totalVoteWeight,
    String? url,
    int? voteRshares,
  }) =>
      PostDetailModel(
        absRshares: absRshares ?? this.absRshares,
        activeVotes: activeVotes ?? this.activeVotes,
        allowCurationRewards: allowCurationRewards ?? this.allowCurationRewards,
        allowReplies: allowReplies ?? this.allowReplies,
        allowVotes: allowVotes ?? this.allowVotes,
        author: author ?? this.author,
        authorReputation: authorReputation ?? this.authorReputation,
        authorRewards: authorRewards ?? this.authorRewards,
        beneficiaries: beneficiaries ?? this.beneficiaries,
        body: body ?? this.body,
        bodyLength: bodyLength ?? this.bodyLength,
        cashoutTime: cashoutTime ?? this.cashoutTime,
        category: category ?? this.category,
        children: children ?? this.children,
        childrenAbsRshares: childrenAbsRshares ?? this.childrenAbsRshares,
        created: created ?? this.created,
        curatorPayoutValue: curatorPayoutValue ?? this.curatorPayoutValue,
        depth: depth ?? this.depth,
        id: id ?? this.id,
        jsonMetadata: jsonMetadata ?? this.jsonMetadata,
        lastPayout: lastPayout ?? this.lastPayout,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        maxAcceptedPayout: maxAcceptedPayout ?? this.maxAcceptedPayout,
        maxCashoutTime: maxCashoutTime ?? this.maxCashoutTime,
        netRshares: netRshares ?? this.netRshares,
        netVotes: netVotes ?? this.netVotes,
        parentAuthor: parentAuthor ?? this.parentAuthor,
        parentPermlink: parentPermlink ?? this.parentPermlink,
        pendingPayoutValue: pendingPayoutValue ?? this.pendingPayoutValue,
        percentHbd: percentHbd ?? this.percentHbd,
        permlink: permlink ?? this.permlink,
        promoted: promoted ?? this.promoted,
        rebloggedBy: rebloggedBy ?? this.rebloggedBy,
        replies: replies ?? this.replies,
        rewardWeight: rewardWeight ?? this.rewardWeight,
        rootAuthor: rootAuthor ?? this.rootAuthor,
        rootPermlink: rootPermlink ?? this.rootPermlink,
        rootTitle: rootTitle ?? this.rootTitle,
        title: title ?? this.title,
        totalPayoutValue: totalPayoutValue ?? this.totalPayoutValue,
        totalPendingPayoutValue:
            totalPendingPayoutValue ?? this.totalPendingPayoutValue,
        totalVoteWeight: totalVoteWeight ?? this.totalVoteWeight,
        url: url ?? this.url,
        voteRshares: voteRshares ?? this.voteRshares,
      );

  factory PostDetailModel.fromJson(Map<String, dynamic> json) =>
      PostDetailModel(
        absRshares: json["abs_rshares"],
        activeVotes: json["active_votes"] == null
            ? []
            : List<ActiveVoteModel>.from(
                json["active_votes"]!.map((x) => ActiveVoteModel.fromJson(x)))
          ..sort((a, b) => b.time!.compareTo(a.time!)),
        allowCurationRewards: json["allow_curation_rewards"],
        allowReplies: json["allow_replies"],
        allowVotes: json["allow_votes"],
        author: asString(json, 'author'),
        authorReputation: json["author_reputation"],
        authorRewards: json["author_rewards"],
        beneficiaries: json["beneficiaries"] == null
            ? []
            : List<BeneficiaryModel>.from(json["beneficiaries"]!
                .map((x) => BeneficiaryModel.fromJson(x))),
        body: asString(json, 'body'),
        bodyLength: json["body_length"],
        cashoutTime: json["cashout_time"] == null
            ? null
            : DateTime.parse(json["cashout_time"]),
        category: json["category"],
        children: json["children"],
        childrenAbsRshares: json["children_abs_rshares"],
        created:
            json["created"] == null ? null : DateTime.parse(json["created"]),
        curatorPayoutValue: json["curator_payout_value"],
        depth: json["depth"],
        id: json["id"],
        jsonMetadata: PostFeedModel.parseJsonMetaData(json['json_metadata']),
        lastPayout: json["last_payout"] == null
            ? null
            : DateTime.parse(json["last_payout"]),
        lastUpdate: json["last_update"] == null
            ? null
            : DateTime.parse(json["last_update"]),
        maxAcceptedPayout: json["max_accepted_payout"],
        maxCashoutTime: json["max_cashout_time"] == null
            ? null
            : DateTime.parse(json["max_cashout_time"]),
        netRshares: json["net_rshares"],
        netVotes: json["net_votes"],
        parentAuthor: json["parent_author"],
        parentPermlink: json["parent_permlink"],
        pendingPayoutValue: json["pending_payout_value"],
        percentHbd: json["percent_hbd"],
        permlink: json["permlink"],
        promoted: json["promoted"],
        rebloggedBy: json["reblogged_by"] == null
            ? []
            : List<dynamic>.from(json["reblogged_by"]!.map((x) => x)),
        replies: json["replies"] == null
            ? []
            : List<dynamic>.from(json["replies"]!.map((x) => x)),
        rewardWeight: json["reward_weight"],
        rootAuthor: json["root_author"],
        rootPermlink: json["root_permlink"],
        rootTitle: json["root_title"],
        title: json["title"],
        totalPayoutValue: json["total_payout_value"],
        totalPendingPayoutValue: json["total_pending_payout_value"],
        totalVoteWeight: json["total_vote_weight"],
        url: json["url"],
        voteRshares: json["vote_rshares"],
      );
}

class ActiveVoteModel {
  final int percent;
  final int? reputation;
  final int? rshares;
  final DateTime? time;
  final String voter;
  final int? weight;

  ActiveVoteModel({
    this.percent = 0,
    this.reputation,
    this.rshares,
    this.time,
    this.voter = "",
    this.weight,
  });

  ActiveVoteModel copyWith({
    int? percent,
    int? reputation,
    int? rshares,
    DateTime? time,
    String? voter,
    int? weight,
  }) =>
      ActiveVoteModel(
        percent: percent ?? this.percent,
        reputation: reputation ?? this.reputation,
        rshares: rshares ?? this.rshares,
        time: time ?? this.time,
        voter: voter ?? this.voter,
        weight: weight ?? this.weight,
      );

  factory ActiveVoteModel.fromJson(Map<String, dynamic> json) =>
      ActiveVoteModel(
        percent: asInt(json, 'percent'),
        reputation: json["reputation"],
        rshares: json["rshares"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        voter: asString(json, "voter"),
        weight: json["weight"],
      );

  Map<String, dynamic> toJson() => {
        "percent": percent,
        "reputation": reputation,
        "rshares": rshares,
        "time": time?.toIso8601String(),
        "voter": voter,
        "weight": weight,
      };
}
