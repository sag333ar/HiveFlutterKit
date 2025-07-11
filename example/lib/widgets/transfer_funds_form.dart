import 'package:flutter/material.dart';

class TransferFundsForm extends StatelessWidget {
  final TextEditingController recipientController;
  final TextEditingController amountController;
  final TextEditingController memoController;
  final String selectedAssetSymbol;
  final ValueChanged<String?> onAssetChanged;
  final VoidCallback onTransfer;
  final bool isTransferring;
  final String? transferResult;

  const TransferFundsForm({
    super.key,
    required this.recipientController,
    required this.amountController,
    required this.memoController,
    required this.selectedAssetSymbol,
    required this.onAssetChanged,
    required this.onTransfer,
    required this.isTransferring,
    this.transferResult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 24),
        const Text(
          'Transfer Funds', // Removed (Aioha) as it's specific to the old implementation detail
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: TextField(
            controller: recipientController,
            decoration: const InputDecoration(
              labelText: 'Recipient Username',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount (e.g., 1.0)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: DropdownButtonFormField<String>(
            value: selectedAssetSymbol,
            decoration: const InputDecoration(
              labelText: 'Asset',
              border: OutlineInputBorder(),
            ),
            items: <String>['HIVE', 'HBD']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onAssetChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: TextField(
            controller: memoController,
            decoration: const InputDecoration(
              labelText: 'Memo (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: isTransferring ? null : onTransfer,
          child: isTransferring
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Transfer Funds'),
        ),
        if (transferResult != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Transfer Result: $transferResult',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        const Divider(),
      ],
    );
  }
}
