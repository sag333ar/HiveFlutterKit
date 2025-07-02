class ProposalAsset {
  final String amount;
  final String nai;
  final int precision;

  ProposalAsset({
    required this.amount,
    required this.nai,
    required this.precision,
  });

  factory ProposalAsset.fromJson(Map<String, dynamic> json) => ProposalAsset(
        amount: json['amount'],
        nai: json['nai'],
        precision: json['precision'],
      );
}

class Proposal {
  final int id;
  final int proposalId;
  final String creator;
  final String receiver;
  final String permlink;
  final String subject;
  final String status;
  final String startDate;
  final String endDate;
  final String totalVotes;
  final ProposalAsset dailyPay;

  Proposal({
    required this.id,
    required this.proposalId,
    required this.creator,
    required this.receiver,
    required this.permlink,
    required this.subject,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalVotes,
    required this.dailyPay,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) => Proposal(
        id: json['id'],
        proposalId: json['proposal_id'],
        creator: json['creator'],
        receiver: json['receiver'],
        permlink: json['permlink'],
        subject: json['subject'],
        status: json['status'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        totalVotes: json['total_votes'],
        dailyPay: ProposalAsset.fromJson(json['daily_pay']),
      );
}
