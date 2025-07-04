class WalletData {
  final String? balance;
  final String? hbdBalance;
  final String? savingsBalance;
  final String? savingsHbdBalance;
  final String? hivePower;
  final String? estimatedValue;
  final String? error;

  WalletData({
    this.balance,
    this.hbdBalance,
    this.savingsBalance,
    this.savingsHbdBalance,
    this.hivePower,
    this.estimatedValue,
    this.error,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      balance: json['balance'] as String?,
      hbdBalance: json['hbd_balance'] as String?,
      savingsBalance: json['savings_balance'] as String?,
      savingsHbdBalance: json['savings_hbd_balance'] as String?,
      hivePower: json['hive_power'] as String?,
      estimatedValue: json['estimated_value'] as String?,
      error: json['error'] as String?,
    );
  }

  factory WalletData.fallback({String? error}) {
    return WalletData(
      balance: '0.000 HIVE',
      hbdBalance: '0.000 HBD',
      savingsBalance: '0.000 HIVE',
      savingsHbdBalance: '0.000 HBD',
      hivePower: '0 HP',
      estimatedValue: '\$0.00',
      error: error ?? 'Unknown error',
    );
  }
}
