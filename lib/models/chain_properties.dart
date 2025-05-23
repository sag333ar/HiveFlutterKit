import 'dart:convert';

class ChainProperties {
  String? accountCreationFee;
  int? accountSubsidyBudget;
  int? accountSubsidyDecay;
  int? hbdInterestRate;
  int? maximumBlockSize;

  ChainProperties({
    this.accountCreationFee,
    this.accountSubsidyBudget,
    this.accountSubsidyDecay,
    this.hbdInterestRate,
    this.maximumBlockSize,
  });

  factory ChainProperties.fromJson(Map<String, dynamic> json) =>
      ChainProperties(
        accountCreationFee: json["account_creation_fee"],
        accountSubsidyBudget: json["account_subsidy_budget"],
        accountSubsidyDecay: json["account_subsidy_decay"],
        hbdInterestRate: json["hbd_interest_rate"],
        maximumBlockSize: json["maximum_block_size"],
      );

  Map<String, dynamic> toJson() => {
    "account_creation_fee": accountCreationFee,
    "account_subsidy_budget": accountSubsidyBudget,
    "account_subsidy_decay": accountSubsidyDecay,
    "hbd_interest_rate": hbdInterestRate,
    "maximum_block_size": maximumBlockSize,
  };

  static ChainProperties fromJsonString(String str) =>
      ChainProperties.fromJson(json.decode(str));

  static String toJsonString(ChainProperties data) =>
      json.encode(data.toJson());
}
