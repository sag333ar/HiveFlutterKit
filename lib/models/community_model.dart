import 'dart:convert';

class CommunitiesRequestModel {
  final CommunitiesRequestParams params;
  final String jsonrpc;
  final String method;
  final int id;

  CommunitiesRequestModel({
    required this.params,
    this.jsonrpc = "2.0",
    this.method = "bridge.list_communities",
    this.id = 1,
  });

  Map<String, dynamic> toJson() => {
        'params': params.toJson(),
        'jsonrpc': jsonrpc,
        'method': method,
        'id': id,
      };

  String toJsonString() => json.encode(toJson());
}

class CommunitiesRequestParams {
  final int limit;
  final String? query;
  final String? last;

  CommunitiesRequestParams({
    this.limit = 100,
    this.query,
    this.last,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'limit': limit,
    };
    if (query != null && query!.isNotEmpty) {
      map['query'] = query;
    }
    if (last != null && last!.isNotEmpty) {
      map['last'] = last;
    }
    return map;
  }
}

class CommunityItem {
  final int? id;
  final String? name;
  final String? title;
  final String? about;
  final String? description; // Added
  final int? typeId;
  final bool? isNsfw;
  final int? subscribers;
  final int? sumPending;
  final int? numAuthors;
  final int? numPending;
  final List<String>? admins;
  final String? avatarUrl;
  final String? lang;
  final DateTime? createdAt; // Changed type
  final Map<String, dynamic>? context;
  final int? rank; // Optional, often present in sorted results
  final double? score; // Optional, for search ranking or trending

  CommunityItem({
    this.id,
    this.name,
    this.title,
    this.about,
    this.description,
    this.typeId,
    this.isNsfw,
    this.subscribers,
    this.sumPending,
    this.numAuthors,
    this.numPending,
    this.admins,
    this.avatarUrl,
    this.lang,
    this.createdAt,
    this.context,
    this.rank,
    this.score,
  });

  factory CommunityItem.fromJson(Map<String, dynamic>? json) => CommunityItem(
        id: json?['id'],
        name: json?['name'],
        title: json?['title'],
        about: json?['about'],
        description: json?['description'],
        typeId: json?['type_id'],
        isNsfw: json?['is_nsfw'],
        subscribers: json?['subscribers'],
        sumPending: json?['sum_pending'],
        numAuthors: json?['num_authors'],
        numPending: json?['num_pending'],
        admins: (json?['admins'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        avatarUrl: json?['avatar_url'],
        lang: json?['lang'],
        createdAt: json?['created_at'] != null
            ? DateTime.tryParse(json!['created_at'])
            : null,
        context: json?['context'] != null
            ? Map<String, dynamic>.from(json!['context'])
            : null,
        rank: json?['rank'],
        score: (json?['score'] is num) ? (json?['score'] as num).toDouble() : null,
      );

  static List<CommunityItem> fromJsonStringList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => CommunityItem.fromJson(e)).toList();
  }
}
