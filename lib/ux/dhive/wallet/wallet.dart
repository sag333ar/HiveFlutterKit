import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/wallet_data.dart';

class Wallet extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final String? username;

  // Customizable colors
  final List<Color>? backgroundColors;
  final Color? fontColor;
  final Color? cardColor;
  final Color? balanceColor;
  final Color? hbdColor;
  final Color? savingsColor;
  final Color? savingsHbdColor;
  final Color? powerColor;
  final Color? estimatedValueColor;
  final Color? errorColor;
  final Color? appBarColor;

  const Wallet({
    super.key,
    required this.hfk,
    required this.username,
    this.backgroundColors,
    this.fontColor,
    this.cardColor,
    this.balanceColor,
    this.hbdColor,
    this.savingsColor,
    this.savingsHbdColor,
    this.powerColor,
    this.estimatedValueColor,
    this.errorColor,
    this.appBarColor,
  });

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  late Future<WalletData> _walletFuture;

  @override
  void initState() {
    super.initState();
    _walletFuture = widget.hfk.getFullWalletData(
      widget.username ?? 'sagarkothari88',
    );
  }

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  List<Color> get _backgroundColors =>
      widget.backgroundColors ??
      (_isDarkMode
          ? [const Color(0xFF121212), const Color(0xFF23272F)]
          : [Colors.grey.shade100, Colors.white]);

  Color get _fontColor =>
      widget.fontColor ?? (_isDarkMode ? Colors.white : Colors.black);

  Color get _cardColor =>
      widget.cardColor ?? (_isDarkMode ? Colors.grey.shade900 : Colors.white);

  Color get _balanceColor => widget.balanceColor ?? Colors.blue.shade100;

  Color get _hbdColor => widget.hbdColor ?? Colors.green.shade100;

  Color get _savingsColor => widget.savingsColor ?? Colors.amber.shade100;

  Color get _savingsHbdColor =>
      widget.savingsHbdColor ?? Colors.purple.shade100;

  Color get _powerColor => widget.powerColor ?? Colors.orange.shade100;

  Color get _estimatedValueColor =>
      widget.estimatedValueColor ?? Colors.blue.shade700;

  Color get _errorColor => widget.errorColor ?? Colors.red.shade50;

  Color get _appBarColor =>
      widget.appBarColor ??
      (_isDarkMode ? Colors.blueGrey.shade900 : Colors.blue.shade700);

  Widget _walletTile({
    required String label,
    required String value,
    IconData? icon,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading:
            icon != null
                ? CircleAvatar(
                  backgroundColor: color ?? _balanceColor,
                  child: Icon(icon, color: _fontColor),
                )
                : null,
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: _fontColor),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _fontColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: _appBarColor,
        elevation: 1,
        foregroundColor: _fontColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _backgroundColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<WalletData>(
          future: _walletFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            final wallet = snapshot.data;
            if (wallet == null) {
              return Center(
                child: Text(
                  'No wallet data found.',
                  style: TextStyle(color: _fontColor),
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: _cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Estimated Value",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _fontColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                wallet.estimatedValue ?? '-',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _estimatedValueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _walletTile(
                        label: "Balance",
                        value: wallet.balance ?? '-',
                        icon: Icons.account_balance_wallet_rounded,
                        color: _balanceColor,
                      ),
                      _walletTile(
                        label: "HBD Balance",
                        value: wallet.hbdBalance ?? '-',
                        icon: Icons.monetization_on_rounded,
                        color: _hbdColor,
                      ),
                      _walletTile(
                        label: "Savings Balance",
                        value: wallet.savingsBalance ?? '-',
                        icon: Icons.savings_rounded,
                        color: _savingsColor,
                      ),
                      _walletTile(
                        label: "Savings HBD Balance",
                        value: wallet.savingsHbdBalance ?? '-',
                        icon: Icons.savings_outlined,
                        color: _savingsHbdColor,
                      ),
                      _walletTile(
                        label: "Hive Power",
                        value: wallet.hivePower ?? '-',
                        icon: Icons.flash_on_rounded,
                        color: _powerColor,
                      ),
                      if (wallet.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Card(
                            color: _errorColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Error',
                                style: TextStyle(color: Colors.red),
                              ),
                              subtitle: Text(
                                wallet.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
