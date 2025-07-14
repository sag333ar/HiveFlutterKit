class ContentModel {
  final String author;
  final String permlink;
  final String title;
  final String body;
  final int bodyLength;
  final String category;
  final String created;
  final String lastUpdate;
  final String url;
  final String jsonMetadata;
  final int children;
  final int netVotes;
  final int depth;
  final List<ActiveContentVote> activeVotes;
  final List<BeneficiaryContent> beneficiaries;

  ContentModel({
    required this.author,
    required this.permlink,
    required this.title,
    required this.body,
    required this.bodyLength,
    required this.category,
    required this.created,
    required this.lastUpdate,
    required this.url,
    required this.jsonMetadata,
    required this.children,
    required this.netVotes,
    required this.depth,
    required this.activeVotes,
    required this.beneficiaries,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      author: json['author'] ?? '',
      permlink: json['permlink'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      bodyLength: json['body_length'] ?? 0,
      category: json['category'] ?? '',
      created: json['created'] ?? '',
      lastUpdate: json['last_update'] ?? '',
      url: json['url'] ?? '',
      jsonMetadata: json['json_metadata'] ?? '',
      children: json['children'] ?? 0,
      netVotes: json['net_votes'] ?? 0,
      depth: json['depth'] ?? 0,
      activeVotes: (json['active_votes'] as List<dynamic>?)
              ?.map((e) => ActiveContentVote.fromJson(e))
              .toList() ??
          [],
      beneficiaries: (json['beneficiaries'] as List<dynamic>?)
              ?.map((e) => BeneficiaryContent.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ActiveContentVote {
  final String voter;
  final int percent;
  final int reputation;
  final int rshares;
  final String time;
  final int weight;

  ActiveContentVote({
    required this.voter,
    required this.percent,
    required this.reputation,
    required this.rshares,
    required this.time,
    required this.weight,
  });

  factory ActiveContentVote.fromJson(Map<String, dynamic> json) {
    return ActiveContentVote(
      voter: json['voter'] ?? '',
      percent: json['percent'] ?? 0,
      reputation: json['reputation'] ?? 0,
      rshares: json['rshares'] ?? 0,
      time: json['time'] ?? '',
      weight: json['weight'] ?? 0,
    );
  }
}

class BeneficiaryContent {
  final String account;
  final int weight;

  BeneficiaryContent({
    required this.account,
    required this.weight,
  });

  factory BeneficiaryContent.fromJson(Map<String, dynamic> json) {
    return BeneficiaryContent(
      account: json['account'] ?? '',
      weight: json['weight'] ?? 0,
    );
  }
}
