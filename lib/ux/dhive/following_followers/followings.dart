import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/account_gridview.dart';

class Followings extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final String account;

  const Followings({super.key, required this.hfk, required this.account});

  @override
  State<Followings> createState() => _FollowingsState();
}

class _FollowingsState extends State<Followings> {
  List<dynamic> _followings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFollowings();
  }

  Future<void> _fetchFollowings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await widget.hfk.getFollowingsData(
        widget.account,
        start: '',
        type: 'blog',
        limit: 100,
      );
      setState(() {
        _followings = result.followings ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch followings: $e';
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
    if (_followings.isEmpty) {
      return const Center(child: Text('No followings found.'));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Followings')),
      body: AccountGridView(
        accounts: _followings,
        getUsername: (item) => item['following'] ?? '',
      ),
    );
  }
}
