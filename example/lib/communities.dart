import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';

class Communities extends StatefulWidget {
  const Communities({super.key});

  @override
  State<Communities> createState() => _CommunitiesState();
}

class _CommunitiesState extends State<Communities> {
  late HiveFlutterKitPlatform hfk;

  int _communityPage = 0;
  final int _communityPageSize = 20;
  List<CommunityItem> _communities = [];
  bool _isLoadingCommunities = false;
  bool _hasMoreCommunities = true;

  String? _currentObserver;
  String? _lastCommunityName;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    hfk = HiveFlutterKitPlatform.instance;
  }

  Future<void> _fetchCommunities({bool loadMore = false}) async {
    if (_isLoadingCommunities || !_hasMoreCommunities) return;

    setState(() {
      _isLoadingCommunities = true;
    });

    try {
      final result = await hfk.getListOfCommunities(
        _searchQuery.isNotEmpty ? _searchQuery : null,
        limit: _communityPageSize,
        last: loadMore ? _lastCommunityName : null,
        observer: _currentObserver, // optional, nullable
      );

      if (result.isEmpty) {
        setState(() {
          _hasMoreCommunities = false;
        });
      } else {
        setState(() {
          if (loadMore) {
            _communities.addAll(result);
          } else {
            _communities = result;
          }
          _lastCommunityName = result.last.name;
          _hasMoreCommunities = result.length == _communityPageSize;
          _communityPage += 1;
        });
      }

      debugPrint('Communities: ${_communities.map((c) => c.name).join(', ')}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${result.length} communities')),
      );
    } catch (e) {
      debugPrint('Error fetching communities: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching communities: $e')));
    } finally {
      setState(() {
        _isLoadingCommunities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communities')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _communityPage = 0;
                  _hasMoreCommunities = true;
                  _lastCommunityName = null;
                  _fetchCommunities(loadMore: false);
                },
                child: const Text('Fetch Communities'),
              ),
              if (_communities.isNotEmpty)
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _communities.length,
                      itemBuilder: (context, index) {
                        final c = _communities[index];
                        return ListTile(
                          title: Text(c.title ?? c.name ?? ''),
                          subtitle: Text(c.about ?? ''),
                        );
                      },
                    ),
                    if (_hasMoreCommunities)
                      ElevatedButton(
                        onPressed: () => _fetchCommunities(loadMore: true),
                        child:
                            _isLoadingCommunities
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Load More'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
