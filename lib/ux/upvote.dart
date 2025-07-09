import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class VoteBottomSheet extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final String author;
  final String permlink;
  final Function(bool status, String? result)? onVoted;
  final Function(String author, String permlink, int weight)? onClickUpvoteTap;

  const VoteBottomSheet({
    super.key,
    required this.hfk,
    required this.author,
    required this.permlink,
    this.onVoted,
    this.onClickUpvoteTap,
  });

  @override
  State<VoteBottomSheet> createState() => _VoteBottomSheetState();
}

class _VoteBottomSheetState extends State<VoteBottomSheet> {
  double _sliderValue = 50;
  bool _loading = false;

  Future<void> _vote() async {
    setState(() => _loading = true);
    try {
      final weight = (_sliderValue.round()) * 100;
      if (widget.onClickUpvoteTap != null) {
        widget.onClickUpvoteTap!(
          widget.author,
          widget.permlink,
          weight,
        );
        return;
      }

      final result = await widget.hfk.singleVote(
        widget.author,
        widget.permlink,
        weight,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close bottom sheet

      final decodedResult = jsonDecode(result);
      final success = decodedResult['success'] == true;

      widget.onVoted?.call(success, decodedResult[success ? 'result' : 'error']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Vote Success: ${decodedResult['result']}'
              : 'Vote Failed: ${decodedResult['error']}'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vote Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
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
              child: _loading
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
    );
  }
}
