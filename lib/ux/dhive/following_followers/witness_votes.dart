import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/account_gridview.dart';

class WitnessVotes extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final String account;

  const WitnessVotes({super.key, required this.hfk, required this.account});

  @override
  State<WitnessVotes> createState() => _WitnessVotesState();
}

class _WitnessVotesState extends State<WitnessVotes> {
  List<dynamic> _witnessVotes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWitnessVotes();
  }

  Future<void> _fetchWitnessVotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await widget.hfk.getWitnessVotesData(
        widget.account,
      );
      setState(() {
        _witnessVotes = result.witnessVotes ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch witness votes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_witnessVotes.isEmpty) {
      return const Center(child: Text('No witness votes found.'));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Witness votes')),
      body: AccountGridView(
        accounts: _witnessVotes,
        getUsername: (item) => item.toString(),
      ),
    );
  }
}
