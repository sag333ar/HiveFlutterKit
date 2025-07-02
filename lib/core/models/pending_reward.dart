class PendingRewardEntry {
  final String? link;
  final String? payDate;
  final String? created;
  final String? amount;

  PendingRewardEntry({
    this.link,
    this.payDate,
    this.created,
    this.amount,
  });

  factory PendingRewardEntry.fromJson(Map<String, dynamic> json) {
    return PendingRewardEntry(
      link: json['link']?.toString(),
      payDate: json['payDate']?.toString(),
      created: json['created']?.toString(),
      amount: json['amount']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'link': link,
        'payDate': payDate,
        'created': created,
        'amount': amount,
      };
}

class PendingAuthorRewardData {
  final List<PendingRewardEntry>? posts;
  final List<PendingRewardEntry>? comments;
  final double? total;

  PendingAuthorRewardData({
    this.posts,
    this.comments,
    this.total,
  });

  factory PendingAuthorRewardData.fromJson(Map<String, dynamic> json) {
    return PendingAuthorRewardData(
      posts: (json['posts'] as List?)
              ?.map((e) => PendingRewardEntry.fromJson(e))
              .toList() ??
          [],
      comments: (json['comments'] as List?)
              ?.map((e) => PendingRewardEntry.fromJson(e))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'posts': posts?.map((e) => e.toJson()).toList(),
        'comments': comments?.map((e) => e.toJson()).toList(),
        'total': total,
      };
}

class PendingCurationRewardData {
  final List<PendingRewardEntry>? curation;
  final double? total;

  PendingCurationRewardData({
    this.curation,
    this.total,
  });

  factory PendingCurationRewardData.fromJson(Map<String, dynamic> json) {
    return PendingCurationRewardData(
      curation: (json['curation'] as List?)
              ?.map((e) => PendingRewardEntry.fromJson(e))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'curation': curation?.map((e) => e.toJson()).toList(),
        'total': total,
      };
}
