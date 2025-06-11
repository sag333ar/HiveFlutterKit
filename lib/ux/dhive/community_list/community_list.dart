import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';

class CommunitiesList extends StatefulWidget {
  /// onSelectCommunity should return a Future so frontend can handle navigation.
  final Future<void> Function(CommunityItem) onSelectCommunity;
  final HiveFlutterKitPlatform hfk;

  const CommunitiesList({
    Key? key,
    required this.onSelectCommunity,
    required this.hfk,
  }) : super(key: key);

  @override
  State<CommunitiesList> createState() => _CommunitiesListState();
}

class _CommunitiesListState extends State<CommunitiesList> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<CommunityItem> _communities = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _lastCommunityName;
  String? _error;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadCommunities(initial: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length >= 3) {
      _loadCommunities(initial: true);
    } else if (query.isEmpty) {
      _loadCommunities(initial: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLoading &&
        _hasMore) {
      _loadCommunities();
    }
  }

  Future<void> _loadCommunities({bool initial = false}) async {
    if (!initial && (_isLoadingMore || !_hasMore)) return;

    setState(() {
      if (initial) {
        _isLoading = true;
        _error = null;
        _communities = [];
        _lastCommunityName = null;
        _hasMore = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final query = _searchController.text.trim();
      final result = await widget.hfk.getListOfCommunities(
        query.isEmpty ? null : query,
        limit: _pageSize,
        last: initial ? null : _lastCommunityName,
      );

      setState(() {
        if (initial) {
          _communities = result;
        } else {
          _communities.addAll(result);
        }
        if (result.isEmpty ||
            result.length < _pageSize ||
            result.last.name == _lastCommunityName) {
          _hasMore = false;
        } else {
          _lastCommunityName = result.last.name;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _hasMore = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  String communityIcon(String value) {
    return "https://images.hive.blog/u/$value/avatar?size=icon";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search communities...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextButton(
                          onPressed: () => _loadCommunities(initial: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                  : _communities.isEmpty
                  ? const Center(
                    child: Text(
                      "No communities found",
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                  : ListView.builder(
                    controller: _scrollController,
                    itemCount: _communities.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _communities.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final community = _communities[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              communityIcon(community.name!),
                            ),
                          ),
                          title: Text(
                            community.title ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            community.about ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            '${community.subscribers ?? 0} members',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          onTap: () async {
                            await widget.onSelectCommunity(community);
                          },
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
