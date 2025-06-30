import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

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
      appBar: AppBar(title: Text('${widget.account}\'s Followings')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 3;
          if (constraints.maxWidth >= 900) {
            crossAxisCount = 6;
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: _followings.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final following = _followings[index];
                final username = following['following'] ?? '';
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
