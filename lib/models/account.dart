import 'dart:convert';

class Account {
  int? id;
  String? jsonrpc;
  List<AccountResult>? result;

  Account({this.id, this.jsonrpc, this.result});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      jsonrpc: json['jsonrpc'],
      result:
          (json['result'] as List?)
              ?.map((e) => AccountResult.fromJson(e))
              .toList(),
    );
  }

  static List<Account> listFromJsonString(String jsonString) {
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((data) => Account.fromJson(data)).toList();
  }
}

class AccountResult {
  AccountAuthActive? active;
  String? balance;
  bool? canVote;
  int? commentCount;
  DateTime? created;
  int? curationRewards;
  List<dynamic>? delayedVotes;
  String? delegatedVestingShares;
  Manabar? downvoteManabar;
  DateTime? governanceVoteExpirationTs;
  List<dynamic>? guestBloggers;
  String? hbdBalance;
  DateTime? hbdLastInterestPayment;
  String? hbdSeconds;
  DateTime? hbdSecondsLastUpdate;
  int? id;
  String? jsonMetadata;
  DateTime? lastAccountRecovery;
  DateTime? lastAccountUpdate;
  DateTime? lastOwnerUpdate;
  DateTime? lastPost;
  DateTime? lastRootPost;
  DateTime? lastVoteTime;
  int? lifetimeVoteCount;
  List<dynamic>? marketHistory;
  String? memoKey;
  bool? mined;
  String? name;
  DateTime? nextVestingWithdrawal;
  int? openRecurrentTransfers;
  List<dynamic>? otherHistory;
  AccountAuthActive? owner;
  int? pendingClaimedAccounts;
  int? pendingTransfers;
  int? postBandwidth;
  int? postCount;
  List<dynamic>? postHistory;
  String? postVotingPower;
  AccountAuthActive? posting;
  String? postingJsonMetadata;
  int? postingRewards;
  DateTime? previousOwnerUpdate;
  List<int>? proxiedVsfVotes;
  String? proxy;
  String? receivedVestingShares;
  String? recoveryAccount;
  int? reputation;
  String? resetAccount;
  String? rewardHbdBalance;
  String? rewardHiveBalance;
  String? rewardVestingBalance;
  String? rewardVestingHive;
  String? savingsBalance;
  String? savingsHbdBalance;
  DateTime? savingsHbdLastInterestPayment;
  String? savingsHbdSeconds;
  DateTime? savingsHbdSecondsLastUpdate;
  int? savingsWithdrawRequests;
  List<dynamic>? tagsUsage;
  int? toWithdraw;
  List<dynamic>? transferHistory;
  String? vestingBalance;
  String? vestingShares;
  String? vestingWithdrawRate;
  List<dynamic>? voteHistory;
  Manabar? votingManabar;
  int? votingPower;
  int? withdrawRoutes;
  int? withdrawn;
  List<String>? witnessVotes;
  int? witnessesVotedFor;

  AccountResult({
    this.active,
    this.balance,
    this.canVote,
    this.commentCount,
    this.created,
    this.curationRewards,
    this.delayedVotes,
    this.delegatedVestingShares,
    this.downvoteManabar,
    this.governanceVoteExpirationTs,
    this.guestBloggers,
    this.hbdBalance,
    this.hbdLastInterestPayment,
    this.hbdSeconds,
    this.hbdSecondsLastUpdate,
    this.id,
    this.jsonMetadata,
    this.lastAccountRecovery,
    this.lastAccountUpdate,
    this.lastOwnerUpdate,
    this.lastPost,
    this.lastRootPost,
    this.lastVoteTime,
    this.lifetimeVoteCount,
    this.marketHistory,
    this.memoKey,
    this.mined,
    this.name,
    this.nextVestingWithdrawal,
    this.openRecurrentTransfers,
    this.otherHistory,
    this.owner,
    this.pendingClaimedAccounts,
    this.pendingTransfers,
    this.postBandwidth,
    this.postCount,
    this.postHistory,
    this.postVotingPower,
    this.posting,
    this.postingJsonMetadata,
    this.postingRewards,
    this.previousOwnerUpdate,
    this.proxiedVsfVotes,
    this.proxy,
    this.receivedVestingShares,
    this.recoveryAccount,
    this.reputation,
    this.resetAccount,
    this.rewardHbdBalance,
    this.rewardHiveBalance,
    this.rewardVestingBalance,
    this.rewardVestingHive,
    this.savingsBalance,
    this.savingsHbdBalance,
    this.savingsHbdLastInterestPayment,
    this.savingsHbdSeconds,
    this.savingsHbdSecondsLastUpdate,
    this.savingsWithdrawRequests,
    this.tagsUsage,
    this.toWithdraw,
    this.transferHistory,
    this.vestingBalance,
    this.vestingShares,
    this.vestingWithdrawRate,
    this.voteHistory,
    this.votingManabar,
    this.votingPower,
    this.withdrawRoutes,
    this.withdrawn,
    this.witnessVotes,
    this.witnessesVotedFor,
  });

  factory AccountResult.fromJson(Map<String, dynamic> json) {
    return AccountResult(
      active:
          json['active'] != null
              ? AccountAuthActive.fromJson(json['active'])
              : null,
      balance: json['balance'],
      canVote: json['can_vote'],
      commentCount: json['comment_count'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      curationRewards: json['curation_rewards'],
      delayedVotes: json['delayed_votes'],
      delegatedVestingShares: json['delegated_vesting_shares'],
      downvoteManabar:
          json['downvote_manabar'] != null
              ? Manabar.fromJson(json['downvote_manabar'])
              : null,
      governanceVoteExpirationTs:
          json['governance_vote_expiration_ts'] != null
              ? DateTime.parse(json['governance_vote_expiration_ts'])
              : null,
      guestBloggers: json['guest_bloggers'],
      hbdBalance: json['hbd_balance'],
      hbdLastInterestPayment:
          json['hbd_last_interest_payment'] != null
              ? DateTime.parse(json['hbd_last_interest_payment'])
              : null,
      hbdSeconds: json['hbd_seconds'],
      hbdSecondsLastUpdate:
          json['hbd_seconds_last_update'] != null
              ? DateTime.parse(json['hbd_seconds_last_update'])
              : null,
      id: json['id'],
      jsonMetadata: json['json_metadata'],
      lastAccountRecovery:
          json['last_account_recovery'] != null
              ? DateTime.parse(json['last_account_recovery'])
              : null,
      lastAccountUpdate:
          json['last_account_update'] != null
              ? DateTime.parse(json['last_account_update'])
              : null,
      lastOwnerUpdate:
          json['last_owner_update'] != null
              ? DateTime.parse(json['last_owner_update'])
              : null,
      lastPost:
          json['last_post'] != null ? DateTime.parse(json['last_post']) : null,
      lastRootPost:
          json['last_root_post'] != null
              ? DateTime.parse(json['last_root_post'])
              : null,
      lastVoteTime:
          json['last_vote_time'] != null
              ? DateTime.parse(json['last_vote_time'])
              : null,
      lifetimeVoteCount: json['lifetime_vote_count'],
      marketHistory: json['market_history'],
      memoKey: json['memo_key'],
      mined: json['mined'],
      name: json['name'],
      nextVestingWithdrawal:
          json['next_vesting_withdrawal'] != null
              ? DateTime.parse(json['next_vesting_withdrawal'])
              : null,
      openRecurrentTransfers: json['open_recurrent_transfers'],
      otherHistory: json['other_history'],
      owner:
          json['owner'] != null
              ? AccountAuthActive.fromJson(json['owner'])
              : null,
      pendingClaimedAccounts: json['pending_claimed_accounts'],
      pendingTransfers: json['pending_transfers'],
      postBandwidth: json['post_bandwidth'],
      postCount: json['post_count'],
      postHistory: json['post_history'],
      postVotingPower: json['post_voting_power'],
      posting:
          json['posting'] != null
              ? AccountAuthActive.fromJson(json['posting'])
              : null,
      postingJsonMetadata: json['posting_json_metadata'],
      postingRewards: json['posting_rewards'],
      previousOwnerUpdate:
          json['previous_owner_update'] != null
              ? DateTime.parse(json['previous_owner_update'])
              : null,
      proxiedVsfVotes:
          json['proxied_vsf_votes'] != null
              ? List<int>.from(json['proxied_vsf_votes'])
              : null,
      proxy: json['proxy'],
      receivedVestingShares: json['received_vesting_shares'],
      recoveryAccount: json['recovery_account'],
      reputation: json['reputation'],
      resetAccount: json['reset_account'],
      rewardHbdBalance: json['reward_hbd_balance'],
      rewardHiveBalance: json['reward_hive_balance'],
      rewardVestingBalance: json['reward_vesting_balance'],
      rewardVestingHive: json['reward_vesting_hive'],
      savingsBalance: json['savings_balance'],
      savingsHbdBalance: json['savings_hbd_balance'],
      savingsHbdLastInterestPayment:
          json['savings_hbd_last_interest_payment'] != null
              ? DateTime.parse(json['savings_hbd_last_interest_payment'])
              : null,
      savingsHbdSeconds: json['savings_hbd_seconds'],
      savingsHbdSecondsLastUpdate:
          json['savings_hbd_seconds_last_update'] != null
              ? DateTime.parse(json['savings_hbd_seconds_last_update'])
              : null,
      savingsWithdrawRequests: json['savings_withdraw_requests'],
      tagsUsage: json['tags_usage'],
      toWithdraw: json['to_withdraw'],
      transferHistory: json['transfer_history'],
      vestingBalance: json['vesting_balance'],
      vestingShares: json['vesting_shares'],
      vestingWithdrawRate: json['vesting_withdraw_rate'],
      voteHistory: json['vote_history'],
      votingManabar:
          json['voting_manabar'] != null
              ? Manabar.fromJson(json['voting_manabar'])
              : null,
      votingPower: json['voting_power'],
      withdrawRoutes: json['withdraw_routes'],
      withdrawn: json['withdrawn'],
      witnessVotes:
          json['witness_votes'] != null
              ? List<String>.from(json['witness_votes'])
              : null,
      witnessesVotedFor: json['witnesses_voted_for'],
    );
  }
}

class AccountAuthActive {
  List<List<dynamic>>? accountAuths;
  List<List<dynamic>>? keyAuths;
  int? weightThreshold;

  AccountAuthActive({this.accountAuths, this.keyAuths, this.weightThreshold});

  factory AccountAuthActive.fromJson(Map<String, dynamic> json) {
    return AccountAuthActive(
      accountAuths:
          json['account_auths'] != null
              ? List<List<dynamic>>.from(json['account_auths'])
              : null,
      keyAuths:
          json['key_auths'] != null
              ? List<List<dynamic>>.from(json['key_auths'])
              : null,
      weightThreshold: json['weight_threshold'],
    );
  }
}

class Manabar {
  int? currentMana;
  int? lastUpdateTime;

  Manabar({this.currentMana, this.lastUpdateTime});

  factory Manabar.fromJson(Map<String, dynamic> json) {
    return Manabar(
      currentMana: json['current_mana'],
      lastUpdateTime: json['last_update_time'],
    );
  }
}
