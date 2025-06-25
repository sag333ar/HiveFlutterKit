import 'dart:convert';

class DiscussionAsset {
  final double? amount;
  final String? symbol;

  DiscussionAsset({this.amount, this.symbol});

  factory DiscussionAsset.fromRawJson(String str) => DiscussionAsset.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DiscussionAsset.fromJson(dynamic json) {
    if (json is String) {
      final parts = json.split(' ');
      return DiscussionAsset(amount: double.tryParse(parts[0]), symbol: parts[1]);
    } else if (json is Map<String, dynamic>) {
      return DiscussionAsset(
        amount: double.tryParse(json['amount'].toString()),
        symbol: json['symbol'],
      );
    } else {
      throw Exception("Invalid DiscussionAsset format");
    }
  }

  Map<String, dynamic> toJson() => {
    "amount": amount?.toStringAsFixed(3),
    "symbol": symbol,
  };

  @override
  String toString() => "${amount?.toStringAsFixed(3)} $symbol";
}

class BeneficiaryRoute {
  final String? account;
  final int? weight;

  BeneficiaryRoute({this.account, this.weight});

  factory BeneficiaryRoute.fromRawJson(String str) =>
      BeneficiaryRoute.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BeneficiaryRoute.fromJson(Map<String, dynamic> json) =>
      BeneficiaryRoute(account: json["account"], weight: json["weight"]);

  Map<String, dynamic> toJson() => {"account": account, "weight": weight};
}

class Comment {
  final int? id;
  final String? category;
  final String? parentAuthor;
  final String? parentPermlink;
  final String? author;
  final String? permlink;
  final String? title;
  final String? body;
  // final String? jsonMetadata;
  final String? lastUpdate;
  final String? created;
  final String? active;
  final String? lastPayout;
  final int? depth;
  final int? children;
  final int? netRshares;
  final int? absRshares;
  final String? voteRshares;
  final String? childrenAbsRshares;
  final String? cashoutTime;
  final String? maxCashoutTime;
  final int? totalVoteWeight;
  final int? rewardWeight;
  final DiscussionAsset? totalPayoutValue;
  final DiscussionAsset? curatorPayoutValue;
  final String? authorRewards;
  final int? netVotes;
  final int? rootComment;
  final String? maxAcceptedPayout;
  final int? percentHbd;
  final bool? allowReplies;
  final bool? allowVotes;
  final bool? allowCurationRewards;
  final List<BeneficiaryRoute>? beneficiaries;

  Comment({
    this.id,
    this.category,
    this.parentAuthor,
    this.parentPermlink,
    this.author,
    this.permlink,
    this.title,
    this.body,
    // this.jsonMetadata,
    this.lastUpdate,
    this.created,
    this.active,
    this.lastPayout,
    this.depth,
    this.children,
    this.netRshares,
    this.absRshares,
    this.voteRshares,
    this.childrenAbsRshares,
    this.cashoutTime,
    this.maxCashoutTime,
    this.totalVoteWeight,
    this.rewardWeight,
    this.totalPayoutValue,
    this.curatorPayoutValue,
    this.authorRewards,
    this.netVotes,
    this.rootComment,
    this.maxAcceptedPayout,
    this.percentHbd,
    this.allowReplies,
    this.allowVotes,
    this.allowCurationRewards,
    this.beneficiaries,
  });

  factory Comment.fromRawJson(String str) => Comment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json["id"],
    category: json["category"],
    parentAuthor: json["parent_author"],
    parentPermlink: json["parent_permlink"],
    author: json["author"],
    permlink: json["permlink"],
    title: json["title"],
    body: json["body"],
    // jsonMetadata: json["json_metadata"],
    lastUpdate: json["last_update"],
    created: json["created"],
    active: json["active"],
    lastPayout: json["last_payout"],
    depth: json["depth"],
    children: json["children"],
    netRshares: json["net_rshares"],
    absRshares: json["abs_rshares"],
    voteRshares: json["vote_rshares"],
    childrenAbsRshares: json["children_abs_rshares"],
    cashoutTime: json["cashout_time"],
    maxCashoutTime: json["max_cashout_time"],
    totalVoteWeight: json["total_vote_weight"],
    rewardWeight: json["reward_weight"],
    totalPayoutValue:
        json["total_payout_value"] != null
            ? DiscussionAsset.fromJson(json["total_payout_value"])
            : null,
    curatorPayoutValue:
        json["curator_payout_value"] != null
            ? DiscussionAsset.fromJson(json["curator_payout_value"])
            : null,
    authorRewards: json["author_rewards"],
    netVotes: json["net_votes"],
    rootComment: json["root_comment"],
    maxAcceptedPayout: json["max_accepted_payout"],
    percentHbd: json["percent_hbd"],
    allowReplies: json["allow_replies"],
    allowVotes: json["allow_votes"],
    allowCurationRewards: json["allow_curation_rewards"],
    beneficiaries:
        json["beneficiaries"] != null
            ? List<BeneficiaryRoute>.from(
              json["beneficiaries"].map((x) => BeneficiaryRoute.fromJson(x)),
            )
            : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category": category,
    "parent_author": parentAuthor,
    "parent_permlink": parentPermlink,
    "author": author,
    "permlink": permlink,
    "title": title,
    "body": body,
    // "json_metadata": jsonMetadata,
    "last_update": lastUpdate,
    "created": created,
    "active": active,
    "last_payout": lastPayout,
    "depth": depth,
    "children": children,
    "net_rshares": netRshares,
    "abs_rshares": absRshares,
    "vote_rshares": voteRshares,
    "children_abs_rshares": childrenAbsRshares,
    "cashout_time": cashoutTime,
    "max_cashout_time": maxCashoutTime,
    "total_vote_weight": totalVoteWeight,
    "reward_weight": rewardWeight,
    "total_payout_value": totalPayoutValue?.toString(),
    "curator_payout_value": curatorPayoutValue?.toString(),
    "author_rewards": authorRewards,
    "net_votes": netVotes,
    "root_comment": rootComment,
    "max_accepted_payout": maxAcceptedPayout,
    "percent_hbd": percentHbd,
    "allow_replies": allowReplies,
    "allow_votes": allowVotes,
    "allow_curation_rewards": allowCurationRewards,
    "beneficiaries": beneficiaries?.map((x) => x.toJson()).toList(),
  };
}

class ActiveVote {
  final String voter;
  final int rshares;
  final int? percent;
  final int? reputation;
  final String? time;
  final int? weight;

  ActiveVote({
    required this.voter,
    required this.rshares,
    this.percent,
    this.reputation,
    this.time,
    this.weight,
  });

  factory ActiveVote.fromJson(Map<String, dynamic> json) => ActiveVote(
        voter: json['voter'],
        rshares: json['rshares'],
        percent: json['percent'],
        reputation: json['reputation'],
        time: json['time'],
        weight: json['weight'],
      );

  Map<String, dynamic> toJson() => {
        'voter': voter,
        'rshares': rshares,
        'percent': percent,
        'reputation': reputation,
        'time': time,
        'weight': weight,
      };
}

/// Represents a discussion or post, extending [Comment].
class Discussion extends Comment {
  final String? url;
  final String? rootTitle;
  final double? payout;
  final String? payoutAt;
  final DiscussionAsset? pendingPayoutValue;
  final DiscussionAsset? totalPendingPayoutValue;
  final List<ActiveVote>? activeVotes;
  final List<String>? replies;
  final double? authorReputation;
  final DiscussionAsset? promoted;
  final dynamic firstRebloggedBy;
  final dynamic firstRebloggedOn;
  final List<String>? rebloggedBy;
  final JsonMetadata? jsonMetadata;
  final String? community;
  final String? communityTitle;
  final Stats? stats;


  Discussion({
    required super.id,
    required super.category,
    required super.parentAuthor,
    required super.parentPermlink,
    required super.author,
    required super.permlink,
    required super.title,
    required super.body,
    required super.lastUpdate,
    required super.created,
    required super.active,
    required super.lastPayout,
    required super.depth,
    required super.children,
    required super.netRshares,
    required super.absRshares,
    required super.voteRshares,
    required super.childrenAbsRshares,
    required super.cashoutTime,
    required super.maxCashoutTime,
    required super.totalVoteWeight,
    required super.rewardWeight,
    required super.totalPayoutValue,
    required super.curatorPayoutValue,
    required super.authorRewards,
    required super.netVotes,
    required super.rootComment,
    required super.maxAcceptedPayout,
    required super.percentHbd,
    required super.allowReplies,
    required super.allowVotes,
    required super.allowCurationRewards,
    required super.beneficiaries,
    this.url,
    this.rootTitle,
    this.payout,
    this.pendingPayoutValue,
    this.payoutAt,
    this.totalPendingPayoutValue,
    this.activeVotes,
    this.replies,
    this.authorReputation,
    this.promoted,
    this.firstRebloggedBy,
    this.firstRebloggedOn,
    this.rebloggedBy,
    this.jsonMetadata,
    this.community,
    this.communityTitle,
    this.stats
  });

  factory Discussion.fromRawJson(String str) =>
      Discussion.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Discussion.fromJson(Map<String, dynamic> json) {
    final metadataRaw = json['json_metadata'];
    final statsRaw = json['stats'];

    Stats? stats;
    JsonMetadata? metadata;

    if(statsRaw != null) {
      try {
        final decoded =
            statsRaw is String ? jsonDecode(statsRaw) : statsRaw;
        stats = Stats.fromJson(decoded);
      } catch (e) {
        stats = null;
      }
    }
    
    if (metadataRaw != null) {
      try {
        final decoded =
            metadataRaw is String ? jsonDecode(metadataRaw) : metadataRaw;
        metadata = JsonMetadata.fromJson(decoded);
      } catch (e) {
        metadata = null;
      }
    }

    return Discussion(
      id: json['id'],
      category: json['category'],
      parentAuthor: json['parent_author'],
      parentPermlink: json['parent_permlink'],
      author: json['author'],
      permlink: json['permlink'],
      title: json['title'],
      body: json['body'],
      jsonMetadata: metadata,
      stats: stats,
      lastUpdate: json['last_update'],
      created: json['created'],
      active: json['active'],
      lastPayout: json['last_payout'],
      depth: json['depth'],
      children: json['children'],
      netRshares: json['net_rshares'],
      absRshares: json['abs_rshares'],
      voteRshares: json['vote_rshares'],
      childrenAbsRshares: json['children_abs_rshares'],
      cashoutTime: json['cashout_time'],
      maxCashoutTime: json['max_cashout_time'],
      totalVoteWeight: json['total_vote_weight'],
      rewardWeight: json['reward_weight'],
      totalPayoutValue:
          json['total_payout_value'] != null
              ? DiscussionAsset.fromJson(json['total_payout_value'])
              : null,
      curatorPayoutValue:
          json['curator_payout_value'] != null
              ? DiscussionAsset.fromJson(json['curator_payout_value'])
              : null,
      authorRewards: json['author_rewards'],
      netVotes: json['net_votes'],
      rootComment: json['root_comment'],
      maxAcceptedPayout: json['max_accepted_payout'],
      percentHbd: json['percent_hbd'],
      allowReplies: json['allow_replies'],
      allowVotes: json['allow_votes'],
      allowCurationRewards: json['allow_curation_rewards'],
      beneficiaries:
          json['beneficiaries'] != null
              ? List<BeneficiaryRoute>.from(
                json['beneficiaries'].map((x) => BeneficiaryRoute.fromJson(x)),
              )
              : null,
      url: json['url'],
      rootTitle: json['root_title'],
      payout: json['payout'] != null ? (json['payout'] as num).toDouble() : null,
      payoutAt: json['payout_at'],
      pendingPayoutValue:
          json['pending_payout_value'] != null
              ? DiscussionAsset.fromJson(json['pending_payout_value'])
              : null,
      totalPendingPayoutValue:
          json['total_pending_payout_value'] != null
              ? DiscussionAsset.fromJson(json['total_pending_payout_value'])
              : null,
      activeVotes:
          json['active_votes'] != null
              ? List<ActiveVote>.from(
                json['active_votes'].map((x) => ActiveVote.fromJson(x)),
              )
              : null,
      replies:
          json['replies'] != null ? List<String>.from(json['replies']) : null,
      authorReputation: json['author_reputation'],
      promoted:
          json['promoted'] != null ? DiscussionAsset.fromJson(json['promoted']) : null,
      rebloggedBy:
          json['reblogged_by'] != null
              ? List<String>.from(json['reblogged_by'])
              : null,
      firstRebloggedBy: json['first_reblogged_by'],
      firstRebloggedOn: json['first_reblogged_on'],
      community: json['community'] ?? '',
      communityTitle: json['community_title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'parent_author': parentAuthor,
    'parent_permlink': parentPermlink,
    'author': author,
    'permlink': permlink,
    'title': title,
    'body': body,
    'json_metadata':
        jsonMetadata != null ? jsonEncode(jsonMetadata!.toJson()) : null,
    'stats': stats != null ? stats!.toJson() : null,
    'last_update': lastUpdate,
    'created': created,
    'active': active,
    'last_payout': lastPayout,
    'depth': depth,
    'children': children,
    'net_rshares': netRshares,
    'abs_rshares': absRshares,
    'vote_rshares': voteRshares,
    'children_abs_rshares': childrenAbsRshares,
    'cashout_time': cashoutTime,
    'max_cashout_time': maxCashoutTime,
    'total_vote_weight': totalVoteWeight,
    'reward_weight': rewardWeight,
    'total_payout_value': totalPayoutValue?.toJson(),
    'curator_payout_value': curatorPayoutValue?.toJson(),
    'author_rewards': authorRewards,
    'net_votes': netVotes,
    'root_comment': rootComment,
    'max_accepted_payout': maxAcceptedPayout,
    'percent_hbd': percentHbd,
    'allow_replies': allowReplies,
    'allow_votes': allowVotes,
    'allow_curation_rewards': allowCurationRewards,
    'beneficiaries': beneficiaries?.map((x) => x.toJson()).toList(),
    'url': url,
    'root_title': rootTitle,
    'payout': payout,
    'payout_at': payoutAt,
    'pending_payout_value': pendingPayoutValue?.toJson(),
    'total_pending_payout_value': totalPendingPayoutValue?.toJson(),
    'active_votes': activeVotes?.map((x) => x.toJson()).toList(),
    'replies': replies,
    'author_reputation': authorReputation,
    'promoted': promoted?.toJson(),
    'reblogged_by': rebloggedBy,
    'first_reblogged_by': firstRebloggedBy,
    'first_reblogged_on': firstRebloggedOn,
    'community': community,
    'community_title': communityTitle,
  };

  static List<Discussion> fromJsonStringList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Discussion.fromJson(e)).toList();
  }
}

class Stats{
  double? flagWeight;
  bool? gray;
  bool? hide;
  int? totalVotes;

  Stats({
    this.flagWeight,
    this.gray,
    this.hide,
    this.totalVotes,
  });

    factory Stats.fromRawJson(String str) =>
      Stats.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Stats.fromJson(Map<String , dynamic> json) {
    return Stats(
      flagWeight: json['flag_weight'],
      gray: json['gray'],
      hide: json['hide'],
      totalVotes: json['total_votes'],
      );
  }

  Map<String, dynamic> toJson() => {
    'flag_weight': flagWeight,
    'gray': gray,
    'hide': hide,
    'total_votes': totalVotes,
  };
}

class JsonMetadata {
  final String? app;
  final Format? format;
  final List<String>? image;
  final List<String>? links;
  final List<String>? tags;
  final String? description;
  final List<String>? users;
  final List<dynamic>? imageRatios;
  final List<String>? thumbnails;
  final String? type;
  final String? actiCrVal;
  final List<String>? actifitUserId;
  final List<String>? activityDate;
  final List<String>? activityType;
  final String? appType;
  final List<String>? chestUnit;
  final List<String>? community;
  final List<String>? dataTrackingSource;
  final List<String>? detailedActivity;
  final List<String>? heightUnit;
  final List<dynamic>? stepCount;
  final List<String>? thighsUnit;
  final List<String>? waistUnit;
  final List<String>? weightUnit;
  final String? shortForm;
  final String? fitbitUserId;

  JsonMetadata({
    this.app,
    this.format,
    this.image,
    this.links,
    this.tags,
    this.description,
    this.users,
    this.imageRatios,
    this.thumbnails,
    this.type,
    this.actiCrVal,
    this.actifitUserId,
    this.activityDate,
    this.activityType,
    this.appType,
    this.chestUnit,
    this.community,
    this.dataTrackingSource,
    this.detailedActivity,
    this.heightUnit,
    this.stepCount,
    this.thighsUnit,
    this.waistUnit,
    this.weightUnit,
    this.shortForm,
    this.fitbitUserId,
  });

  factory JsonMetadata.fromRawJson(String str) =>
      JsonMetadata.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory JsonMetadata.fromJson(Map<String, dynamic> json) => JsonMetadata(
    app: json["app"],
    format: formatValues.map[json["format"]],
    image: json["image"] != null ? List<String>.from(json["image"]) : null,
    links: json["links"] != null ? List<String>.from(json["links"]) : null,
    tags: json["tags"] != null ? List<String>.from(json["tags"]) : null,
    description: json["description"],
    users: json["users"] != null ? List<String>.from(json["users"]) : null,
    imageRatios: json["imageRatios"],
    thumbnails:
        json["thumbnails"] != null
            ? List<String>.from(json["thumbnails"])
            : null,
    type: json["type"],
    actiCrVal: json["actiCrVal"],
    actifitUserId:
        json["actifit_user_id"] != null
            ? List<String>.from(json["actifit_user_id"])
            : null,
    activityDate:
        json["activity_date"] != null
            ? List<String>.from(json["activity_date"])
            : null,
    activityType:
        json["activity_type"] != null
            ? List<String>.from(json["activity_type"])
            : null,
    appType: json["app_type"],
    chestUnit:
        json["chest_unit"] != null
            ? List<String>.from(json["chest_unit"])
            : null,
    community:
        json["community"] != null ? List<String>.from(json["community"]) : null,
    dataTrackingSource:
        json["data_tracking_source"] != null
            ? List<String>.from(json["data_tracking_source"])
            : null,
    detailedActivity:
        json["detailed_activity"] != null
            ? List<String>.from(json["detailed_activity"])
            : null,
    heightUnit:
        json["height_unit"] != null
            ? List<String>.from(json["height_unit"])
            : null,
    stepCount: json["step_count"],
    thighsUnit:
        json["thighs_unit"] != null
            ? List<String>.from(json["thighs_unit"])
            : null,
    waistUnit:
        json["waist_unit"] != null
            ? List<String>.from(json["waist_unit"])
            : null,
    weightUnit:
        json["weight_unit"] != null
            ? List<String>.from(json["weight_unit"])
            : null,
    shortForm: json["short_form"],
    fitbitUserId: json["fitbit_user_id"],
  );

  Map<String, dynamic> toJson() => {
    "app": app,
    "format": formatValues.reverse[format],
    "image": image,
    "links": links,
    "tags": tags,
    "description": description,
    "users": users,
    "imageRatios": imageRatios,
    "thumbnails": thumbnails,
    "type": type,
    "actiCrVal": actiCrVal,
    "actifit_user_id": actifitUserId,
    "activity_date": activityDate,
    "activity_type": activityType,
    "app_type": appType,
    "chest_unit": chestUnit,
    "community": community,
    "data_tracking_source": dataTrackingSource,
    "detailed_activity": detailedActivity,
    "height_unit": heightUnit,
    "step_count": stepCount,
    "thighs_unit": thighsUnit,
    "waist_unit": waistUnit,
    "weight_unit": weightUnit,
    "short_form": shortForm,
    "fitbit_user_id": fitbitUserId,
  };
}

enum Format { MARKDOWN, MARKDOWN_HTML }

final formatValues = EnumValues({
  "markdown": Format.MARKDOWN,
  "markdown_html": Format.MARKDOWN_HTML,
});

class EnumValues<T> {
  final Map<String, T> map;
  late final Map<T, String> reverseMap;

  EnumValues(this.map) {
    reverseMap = map.map((k, v) => MapEntry(v, k));
  }

  Map<T, String> get reverse => reverseMap;
}
