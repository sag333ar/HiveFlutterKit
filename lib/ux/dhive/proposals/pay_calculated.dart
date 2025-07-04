  import 'package:hive_flutter_kit/core/models/proposal.dart';

String calculatePaid(Proposal proposal) {
    // Calculate based on start date and daily pay
    final startDate = DateTime.parse(proposal.startDate);
    final now = DateTime.now();
    final daysPassed = now.difference(startDate).inDays;
    final dailyAmount = double.parse(proposal.dailyPay.amount) / 1000;
    return (daysPassed * dailyAmount).toStringAsFixed(0);
  }

  String calculateToPay(Proposal proposal) {
    // Calculate remaining amount to be paid
    final remainingDays = proposal.remainingDays;
    final dailyAmount = double.parse(proposal.dailyPay.amount) / 1000;
    return (remainingDays * dailyAmount).toStringAsFixed(0);
  }