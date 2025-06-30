import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

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
      appBar: AppBar(title: Text('${widget.account} Followers')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 3;
          if (constraints.maxWidth >= 900) {
            crossAxisCount = 6;
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: _followers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final follower = _followers[index];
                final username = follower['follower'] ?? '';
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                        'https://images.hive.blog/u/$username/avatar',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      username,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
