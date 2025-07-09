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

  @override
  void dispose() {
    // Ensure loading state is reset when widget is disposed
    _loading = false;
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _loading = loading;
      });
    }
  }

  Future<void> _vote() async {
    if (_loading) return; 
    
    _setLoading(true);

    try {
      final weight = (_sliderValue.round()) * 100;
      
      if (widget.onClickUpvoteTap != null) {
        await widget.onClickUpvoteTap!(
          widget.author,
          widget.permlink,
          weight,
        );
        _setLoading(false);
        return;
      }

      final result = await widget.hfk.singleVote(
        widget.author,
        widget.permlink,
        weight,
      );

      if (!mounted) return;
      
      _setLoading(false);
      
      // Close bottom sheet first
      Navigator.of(context).pop();

      final decodedResult = jsonDecode(result);
      final success = decodedResult['success'] == true;

      widget.onVoted?.call(success, decodedResult[success ? 'result' : 'error']);

      if (mounted) {
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
      }
    } catch (e) {
      _setLoading(false);
      
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
            activeColor: _loading ? Colors.grey : Colors.blueAccent,
            inactiveColor: Colors.grey.shade300,
            label: '${_sliderValue.round()}%',
            onChanged: _loading ? null : (value) {
              setState(() {
                _sliderValue = (value / 5).round() * 5.0;
              });
            },
          ),
          Text(
            '${_sliderValue.round()}%',
            style: TextStyle(
              fontSize: 16,
              color: _loading ? Colors.grey : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: _loading ? Colors.grey.shade400 : Colors.blueAccent,
                foregroundColor: _loading ? Colors.grey.shade600 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _loading ? 0 : 2,
              ),
              onPressed: _loading ? null : _vote,
              child: _loading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Voting...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Vote',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _loading ? Colors.grey : Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}