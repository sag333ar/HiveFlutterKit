import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class VoteDialog extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final String author;
  final String permlink;
  final VoidCallback? onVoted;

  const VoteDialog({
    super.key,
    required this.hfk,
    required this.author,
    required this.permlink,
    this.onVoted,
  });

  @override
  State<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends State<VoteDialog> {
  double _sliderValue = 50;
  bool _loading = false;

  Future<void> _vote() async {
    setState(() => _loading = true);
    try {
      final weight = (_sliderValue.round()) * 100;
      final result = await widget.hfk.singleVote(
        widget.author,
        widget.permlink,
        weight,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      final decodedResult = jsonDecode(result);
      if (decodedResult['success'] == true && widget.onVoted != null) {
        widget.onVoted!();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vote Success: $result'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vote Failed: ${decodedResult['error']}'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vote Error: $e'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Vote Weight',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.grey.shade300,
              label: '${_sliderValue.round()}%',
              onChanged: (value) {
                setState(() {
                  _sliderValue = (value / 5).round() * 5.0;
                });
              },
            ),
            Text(
              '${_sliderValue.round()}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loading ? null : _vote,
                child:
                    _loading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Vote',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
