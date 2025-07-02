import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/account_gridview.dart';

class Followers extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final String account;

  const Followers({super.key, required this.hfk, required this.account});

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  List<dynamic> _followers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
  }

  Future<void> _fetchFollowers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await widget.hfk.getFollowersData(
        widget.account,
        start: '',
        type: 'blog',
        limit: 100,
      );
      setState(() {
        _followers = result.followers ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch followers: $e';
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
    if (_followers.isEmpty) {
      return const Center(child: Text('No followers found.'));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Followers')),
      body: AccountGridView(
        accounts: _followers,
        getUsername: (item) => item['follower'] ?? '',
      ),
    );
  }
}
