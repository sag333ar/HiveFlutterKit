import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/communities_models/community_subscriber.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/custom_circle_avatar.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/loading_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/retry.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';

class CommunityMembersWidget extends StatefulWidget {
  const CommunityMembersWidget({
    Key? key,
    required this.communityId,
  }) : super(key: key);
  final String communityId;

  @override
  State<CommunityMembersWidget> createState() => _CommunityMembersWidgetState();
}

class _CommunityMembersWidgetState extends State<CommunityMembersWidget> {
  final List<CommunitySubscriber> _members = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _last;
  String? _error;
  final int _pageSize = 100;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchMembers();
    }
  }

  Future<void> _fetchMembers({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _members.clear();
        _last = null;
        _hasMore = true;
      }
    });
    try {
      final newMembers = await HiveFlutterKitPlatform.instance.getCommunitySubscribers(
        widget.communityId,
        limit: _pageSize,
        last: _last,
      );
      if (newMembers.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          // Avoid duplicates
          final usernames = _members.map((m) => m.username).toSet();
          final filtered = newMembers.where((m) => !usernames.contains(m.username)).toList();
          _members.addAll(filtered);
          _last = _members.isNotEmpty ? _members.last.username : null;
          _hasMore = newMembers.length == _pageSize;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _membersGrid(List<CommunitySubscriber> members) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double width = constraints.maxWidth;

        if (width < 600) {
          crossAxisCount = 2;
        } else if (width < 900) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 6;
        }

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: members.length + (_isLoading || _hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= members.length) {
              if (_hasMore) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ));
              } else {
                return const SizedBox.shrink();
              }
            }
            final member = members[index];
            return Card(
              elevation: 1.5,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    CustomCircleAvatar(
                      height: 42,
                      width: 42,
                      url: server.userOwnerThumb(member.username),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (member.role.isNotEmpty)
                            Text(
                              member.role,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _membersWidget() {
    if (_error != null) {
      return RetryScreen(
        error: _error!,
        onRetry: () {
          _fetchMembers(refresh: true);
        },
      );
    } else if (_members.isEmpty && _isLoading) {
      return const LoadingScreen(
        title: 'Loading Members',
        subtitle: 'Please wait',
      );
    } else if (_members.isEmpty) {
      return const Center(child: Text('No community members found.'));
    } else {
      return _membersGrid(_members);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _membersWidget(),
    );
  }
}
