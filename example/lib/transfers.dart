import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class Transfers extends StatefulWidget {
  const Transfers({super.key});

  @override
  State<Transfers> createState() => _TransfersState();
}

class _TransfersState extends State<Transfers> {
  late HiveFlutterKitPlatform hfk;
  final TextEditingController _transferRecipientController =
      TextEditingController();
  final TextEditingController _transferAmountController =
      TextEditingController();
  final TextEditingController _transferMemoController = TextEditingController();
  String _transferAssetSymbol = 'HIVE'; // Default asset
  String? _transferResult;
  bool _isTransferring = false;

  @override
  void initState() {
    super.initState();
    hfk = HiveFlutterKitPlatform.instance;
  }

  void _transferFunds() async {
    setState(() {
      _isTransferring = true;
      _transferResult = null;
    });

    final recipient = _transferRecipientController.text;
    final amountString = _transferAmountController.text;
    final memo =
        _transferMemoController.text.isEmpty
            ? null
            : _transferMemoController.text;

    if (recipient.isEmpty) {
      setState(() {
        _transferResult = 'Error: Recipient username is required.';
        _isTransferring = false;
      });
      return;
    }

    double amount;
    try {
      amount = double.parse(amountString);
      if (amount <= 0) {
        throw FormatException('Amount must be positive');
      }
    } catch (e) {
      setState(() {
        _transferResult =
            'Error: Invalid amount. Please enter a positive number.';
        _isTransferring = false;
      });
      return;
    }

    try {
      final result = await hfk.transfer(
        recipient,
        amount,
        _transferAssetSymbol,
        memo,
      );
      setState(() {
        _transferResult = 'Success: $result';
      });
    } catch (e) {
      setState(() {
        _transferResult = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTransferring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfers')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              const SizedBox(height: 24),
              const Text(
                'Transfer Funds (Aioha)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: TextField(
                  controller: _transferRecipientController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Username',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: TextField(
                  controller: _transferAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (e.g., 1.0)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: DropdownButtonFormField<String>(
                  value: _transferAssetSymbol,
                  decoration: const InputDecoration(
                    labelText: 'Asset',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      <String>['HIVE', 'HBD'].map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _transferAssetSymbol = newValue;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: TextField(
                  controller: _transferMemoController,
                  decoration: const InputDecoration(
                    labelText: 'Memo (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isTransferring ? null : _transferFunds,
                child:
                    _isTransferring
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Transfer Funds'),
              ),
              if (_transferResult != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Transfer Result: $_transferResult',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const Divider(),
        ],
      ),
    );
  }
}