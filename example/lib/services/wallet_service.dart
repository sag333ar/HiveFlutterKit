import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class WalletService {
  final HiveFlutterKitPlatform hfk;
  final Function(String) showSnackBar; // For displaying messages

  WalletService({
    required this.hfk,
    required this.showSnackBar,
  });

  Future<String> transferFunds({
    required String recipient,
    required String amountString,
    required String assetSymbol,
    String? memo,
  }) async {
    if (recipient.isEmpty) {
      return 'Error: Recipient username is required.';
    }

    double amount;
    try {
      amount = double.parse(amountString);
      if (amount <= 0) {
        throw const FormatException('Amount must be positive');
      }
    } catch (e) {
      return 'Error: Invalid amount. Please enter a positive number.';
    }

    try {
      final result = await hfk.transfer(
        recipient,
        amount,
        assetSymbol,
        memo?.isEmpty ?? true ? null : memo,
      );
      return 'Success: $result';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
