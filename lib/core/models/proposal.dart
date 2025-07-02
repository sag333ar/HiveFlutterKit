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
        amount: json['amount'].toString(),
        nai: json['nai'].toString(),
        precision: json['precision'] is int ? json['precision'] : int.parse(json['precision'].toString()),
      );

  String get formattedAmount {
    try {
      final numAmount = double.parse(amount);
      final divisor = precision > 0 ? 1000 : 1;
      return (numAmount / divisor).toStringAsFixed(0);
    } catch (e) {
      return amount;
    }
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'nai': nai,
        'precision': precision,
      };
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

  factory Proposal.fromJson(Map<String, dynamic> json) {
    // Handle totalVotes as either string or number
    String totalVotesStr;
    final totalVotesValue = json['total_votes'];
    if (totalVotesValue is String) {
      totalVotesStr = totalVotesValue;
    } else if (totalVotesValue is num) {
      totalVotesStr = totalVotesValue.toString();
    } else {
      totalVotesStr = '0';
    }

    return Proposal(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      proposalId: json['proposal_id'] is int ? json['proposal_id'] : int.parse(json['proposal_id'].toString()),
      creator: json['creator'].toString(),
      receiver: json['receiver'].toString(),
      permlink: json['permlink'].toString(),
      subject: json['subject'].toString(),
      status: json['status'].toString(),
      startDate: json['start_date'].toString(),
      endDate: json['end_date'].toString(),
      totalVotes: totalVotesStr,
      dailyPay: ProposalAsset.fromJson(json['daily_pay']),
    );
  }

  int get remainingDays {
    try {
      final endDateTime = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = endDateTime.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  String get formattedVotes {
    try {
      final votes = BigInt.parse(totalVotes);
      if (votes > BigInt.from(1000000000000)) {
        final trillions = votes ~/ BigInt.from(1000000000000);
        return '${trillions}T HP';
      } else if (votes > BigInt.from(1000000000)) {
        final billions = votes ~/ BigInt.from(1000000000);
        return '${billions}B HP';
      } else if (votes > BigInt.from(1000000)) {
        final millions = votes ~/ BigInt.from(1000000);
        return '${millions}M HP';
      } else if (votes > BigInt.from(1000)) {
        final thousands = votes ~/ BigInt.from(1000);
        return '${thousands}K HP';
      }
      return '$votes HP';
    } catch (e) {
      return '0 HP';
    }
  }

  String get formattedDailyPay {
    return '${dailyPay.formattedAmount} HBD';
  }

  String get statusBadgeColor {
    switch (status.toLowerCase()) {
      case 'active':
        return '#10B981'; // Green
      case 'upcoming':
        return '#F59E0B'; // Yellow
      case 'expired':
        return '#EF4444'; // Red
      default:
        return '#6B7280'; // Gray
    }
  }

  bool get isActive => status.toLowerCase() == 'active';
  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isExpired => status.toLowerCase() == 'expired' || remainingDays <= 0;

  String get durationText {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final duration = end.difference(start).inDays;
      return '$duration days';
    } catch (e) {
      return 'Unknown duration';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'proposal_id': proposalId,
        'creator': creator,
        'receiver': receiver,
        'permlink': permlink,
        'subject': subject,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
        'total_votes': totalVotes,
        'daily_pay': dailyPay.toJson(),
      };
}