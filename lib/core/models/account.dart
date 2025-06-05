import 'dart:convert';

// Add AccountAsset and Authority classes for compatibility
class AccountAsset {
  final String value;
  AccountAsset(this.value);

  factory AccountAsset.fromJson(dynamic json) {
    if (json is String) return AccountAsset(json);
    if (json is Map && json.containsKey('amount') && json.containsKey('symbol')) {
      return AccountAsset('${json['amount']} ${json['symbol']}');
    }
    return AccountAsset(json.toString());
  }

  @override
  String toString() => value;
}

class Authority {
  int? weightThreshold;
  List<List<dynamic>>? accountAuths;
  List<List<dynamic>>? keyAuths;

  Authority({this.weightThreshold, this.accountAuths, this.keyAuths});

  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(
      weightThreshold: json['weight_threshold'],
      accountAuths: json['account_auths'] != null
          ? List<List<dynamic>>.from(json['account_auths'])
          : null,
      keyAuths: json['key_auths'] != null
          ? List<List<dynamic>>.from(json['key_auths'])
          : null,
    );
  }
}

class Account {
  int? id;
  String? name;
  Authority? owner;
  Authority? active;
  Authority? posting;
  String? memoKey;
  String? jsonMetadata;
  String? postingJsonMetadata;
  String? proxy;
  String? lastOwnerUpdate;
  String? lastAccountUpdate;
  String? created;
  bool? mined;
  bool? ownerChallenged;
  bool? activeChallenged;
  String? lastOwnerProved;
  String? lastActiveProved;
  String? recoveryAccount;
  String? resetAccount;
  String? lastAccountRecovery;
  int? commentCount;
  int? lifetimeVoteCount;
  int? postCount;
  bool? canVote;
  int? votingPower;
  String? lastVoteTime;
  Manabar? votingManabar;
  dynamic balance;
  dynamic savingsBalance;
  dynamic hbdBalance;
  String? hbdSeconds;
  String? hbdSecondsLastUpdate;
  String? hbdLastInterestPayment;
  dynamic savingsHbdBalance;
  String? savingsHbdSeconds;
  String? savingsHbdSecondsLastUpdate;
  String? savingsHbdLastInterestPayment;
  int? savingsWithdrawRequests;
  dynamic rewardHbdBalance;
  dynamic rewardHiveBalance;
  dynamic rewardVestingBalance;
  dynamic rewardVestingHive;
  dynamic curationRewards;
  dynamic postingRewards;
  dynamic vestingShares;
  dynamic delegatedVestingShares;
  dynamic receivedVestingShares;
  dynamic vestingWithdrawRate;
  String? nextVestingWithdrawal;
  dynamic withdrawn;
  dynamic toWithdraw;
  int? withdrawRoutes;
  List<int>? proxiedVsfVotes;
  int? witnessesVotedFor;
  dynamic averageBandwidth;
  dynamic lifetimeBandwidth;
  String? lastBandwidthUpdate;
  dynamic averageMarketBandwidth;
  dynamic lifetimeMarketBandwidth;
  String? lastMarketBandwidthUpdate;
  String? lastPost;
  String? lastRootPost;
  // ExtendedAccount fields
  dynamic vestingBalance;
  dynamic reputation;
  List<dynamic>? transferHistory;
  List<dynamic>? marketHistory;
  List<dynamic>? postHistory;
  List<dynamic>? voteHistory;
  List<dynamic>? otherHistory;
  List<String>? witnessVotes;
  List<String>? tagsUsage;
  List<String>? guestBloggers;
  List<dynamic>? openOrders;
  List<dynamic>? comments;
  List<dynamic>? blog;
  List<dynamic>? feed;
  List<dynamic>? recentReplies;
  List<dynamic>? recommended;

  Account({
    this.id,
    this.name,
    this.owner,
    this.active,
    this.posting,
    this.memoKey,
    this.jsonMetadata,
    this.postingJsonMetadata,
    this.proxy,
    this.lastOwnerUpdate,
    this.lastAccountUpdate,
    this.created,
    this.mined,
    this.ownerChallenged,
    this.activeChallenged,
    this.lastOwnerProved,
    this.lastActiveProved,
    this.recoveryAccount,
    this.resetAccount,
    this.lastAccountRecovery,
    this.commentCount,
    this.lifetimeVoteCount,
    this.postCount,
    this.canVote,
    this.votingPower,
    this.lastVoteTime,
    this.votingManabar,
    this.balance,
    this.savingsBalance,
    this.hbdBalance,
    this.hbdSeconds,
    this.hbdSecondsLastUpdate,
    this.hbdLastInterestPayment,
    this.savingsHbdBalance,
    this.savingsHbdSeconds,
    this.savingsHbdSecondsLastUpdate,
    this.savingsHbdLastInterestPayment,
    this.savingsWithdrawRequests,
    this.rewardHbdBalance,
    this.rewardHiveBalance,
    this.rewardVestingBalance,
    this.rewardVestingHive,
    this.curationRewards,
    this.postingRewards,
    this.vestingShares,
    this.delegatedVestingShares,
    this.receivedVestingShares,
    this.vestingWithdrawRate,
    this.nextVestingWithdrawal,
    this.withdrawn,
    this.toWithdraw,
    this.withdrawRoutes,
    this.proxiedVsfVotes,
    this.witnessesVotedFor,
    this.averageBandwidth,
    this.lifetimeBandwidth,
    this.lastBandwidthUpdate,
    this.averageMarketBandwidth,
    this.lifetimeMarketBandwidth,
    this.lastMarketBandwidthUpdate,
    this.lastPost,
    this.lastRootPost,
    this.vestingBalance,
    this.reputation,
    this.transferHistory,
    this.marketHistory,
    this.postHistory,
    this.voteHistory,
    this.otherHistory,
    this.witnessVotes,
    this.tagsUsage,
    this.guestBloggers,
    this.openOrders,
    this.comments,
    this.blog,
    this.feed,
    this.recentReplies,
    this.recommended,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      owner: json['owner'] != null ? Authority.fromJson(json['owner']) : null,
      active: json['active'] != null ? Authority.fromJson(json['active']) : null,
      posting: json['posting'] != null ? Authority.fromJson(json['posting']) : null,
      memoKey: json['memo_key'],
      jsonMetadata: json['json_metadata'],
      postingJsonMetadata: json['posting_json_metadata'],
      proxy: json['proxy'],
      lastOwnerUpdate: json['last_owner_update'],
      lastAccountUpdate: json['last_account_update'],
      created: json['created'],
      mined: json['mined'],
      ownerChallenged: json['owner_challenged'],
      activeChallenged: json['active_challenged'],
      lastOwnerProved: json['last_owner_proved'],
      lastActiveProved: json['last_active_proved'],
      recoveryAccount: json['recovery_account'],
      resetAccount: json['reset_account'],
      lastAccountRecovery: json['last_account_recovery'],
      commentCount: json['comment_count'],
      lifetimeVoteCount: json['lifetime_vote_count'],
      postCount: json['post_count'],
      canVote: json['can_vote'],
      votingPower: json['voting_power'],
      lastVoteTime: json['last_vote_time'],
      votingManabar: json['voting_manabar'] != null ? Manabar.fromJson(json['voting_manabar']) : null,
      balance: json['balance'] != null ? AccountAsset.fromJson(json['balance']) : null,
      savingsBalance: json['savings_balance'] != null ? AccountAsset.fromJson(json['savings_balance']) : null,
      hbdBalance: json['hbd_balance'] != null ? AccountAsset.fromJson(json['hbd_balance']) : null,
      hbdSeconds: json['hbd_seconds'],
      hbdSecondsLastUpdate: json['hbd_seconds_last_update'],
      hbdLastInterestPayment: json['hbd_last_interest_payment'],
      savingsHbdBalance: json['savings_hbd_balance'] != null ? AccountAsset.fromJson(json['savings_hbd_balance']) : null,
      savingsHbdSeconds: json['savings_hbd_seconds'],
      savingsHbdSecondsLastUpdate: json['savings_hbd_seconds_last_update'],
      savingsHbdLastInterestPayment: json['savings_hbd_last_interest_payment'],
      savingsWithdrawRequests: json['savings_withdraw_requests'],
      rewardHbdBalance: json['reward_hbd_balance'] != null ? AccountAsset.fromJson(json['reward_hbd_balance']) : null,
      rewardHiveBalance: json['reward_hive_balance'] != null ? AccountAsset.fromJson(json['reward_hive_balance']) : null,
      rewardVestingBalance: json['reward_vesting_balance'] != null ? AccountAsset.fromJson(json['reward_vesting_balance']) : null,
      rewardVestingHive: json['reward_vesting_hive'] != null ? AccountAsset.fromJson(json['reward_vesting_hive']) : null,
      curationRewards: json['curation_rewards'],
      postingRewards: json['posting_rewards'],
      vestingShares: json['vesting_shares'] != null ? AccountAsset.fromJson(json['vesting_shares']) : null,
      delegatedVestingShares: json['delegated_vesting_shares'] != null ? AccountAsset.fromJson(json['delegated_vesting_shares']) : null,
      receivedVestingShares: json['received_vesting_shares'] != null ? AccountAsset.fromJson(json['received_vesting_shares']) : null,
      vestingWithdrawRate: json['vesting_withdraw_rate'] != null ? AccountAsset.fromJson(json['vesting_withdraw_rate']) : null,
      nextVestingWithdrawal: json['next_vesting_withdrawal'],
      withdrawn: json['withdrawn'],
      toWithdraw: json['to_withdraw'],
      withdrawRoutes: json['withdraw_routes'],
      proxiedVsfVotes: json['proxied_vsf_votes'] != null ? List<int>.from(json['proxied_vsf_votes']) : null,
      witnessesVotedFor: json['witnesses_voted_for'],
      averageBandwidth: json['average_bandwidth'],
      lifetimeBandwidth: json['lifetime_bandwidth'],
      lastBandwidthUpdate: json['last_bandwidth_update'],
      averageMarketBandwidth: json['average_market_bandwidth'],
      lifetimeMarketBandwidth: json['lifetime_market_bandwidth'],
      lastMarketBandwidthUpdate: json['last_market_bandwidth_update'],
      lastPost: json['last_post'],
      lastRootPost: json['last_root_post'],
      vestingBalance: json['vesting_balance'] != null ? AccountAsset.fromJson(json['vesting_balance']) : null,
      reputation: json['reputation'],
      transferHistory: json['transfer_history'],
      marketHistory: json['market_history'],
      postHistory: json['post_history'],
      voteHistory: json['vote_history'],
      otherHistory: json['other_history'],
      witnessVotes: json['witness_votes'] != null ? List<String>.from(json['witness_votes']) : null,
      tagsUsage: json['tags_usage'] != null ? List<String>.from(json['tags_usage']) : null,
      guestBloggers: json['guest_bloggers'] != null ? List<String>.from(json['guest_bloggers']) : null,
      openOrders: json['open_orders'],
      comments: json['comments'],
      blog: json['blog'],
      feed: json['feed'],
      recentReplies: json['recent_replies'],
      recommended: json['recommended'],
    );
  }

  static List<Account> listFromJsonString(String jsonString) {
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((data) => Account.fromJson(data)).toList();
  }
}

class Manabar {
  dynamic currentMana;
  int? lastUpdateTime;

  Manabar({this.currentMana, this.lastUpdateTime});

  factory Manabar.fromJson(Map<String, dynamic> json) {
    return Manabar(
      currentMana: json['current_mana'],
      lastUpdateTime: json['last_update_time'],
    );
  }
}
