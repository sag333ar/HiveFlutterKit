import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/account.dart';

class Witnesses extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final void Function(Account account)? onTapWitness;
  final void Function(Account account)? onTapLink;
  final void Function(Account account)? onTapCheckmark;

  const Witnesses({
    super.key,
    required this.hfk,
    this.onTapWitness,
    this.onTapLink,
    this.onTapCheckmark,
  });

  @override
  State<Witnesses> createState() => _WitnessesState();
}

class _WitnessesState extends State<Witnesses> {
  List<Account> witnesses = [];
  Set<String> approvedWitnesses = {};
  final ScrollController _scrollController = ScrollController();

  bool isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _lastWitnessName;
  final int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadWitnessData(initial: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !isLoading) {
      _loadWitnessData();
    }
  }

  Future<void> _loadWitnessData({bool initial = false}) async {
    if (!initial && (_isLoadingMore || !_hasMore)) return;

    setState(() {
      if (initial) {
        isLoading = true;
        witnesses = [];
        _hasMore = true;
        _lastWitnessName = null;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      String username = await widget.hfk.getCurrentUser();
      username = username.replaceAll('"', '');

      if (username.isEmpty) throw Exception("User not logged in");

      if (initial) {
        final accounts = await widget.hfk.getAccounts([username]);
        if (accounts.isNotEmpty) {
          approvedWitnesses = Set<String>.from(accounts.first.witnessVotes ?? []);
        }
      }

      final result = await widget.hfk.getWitnessesByVote(
        limit: _pageSize,
        startAt: initial ? "" : _lastWitnessName ?? "",
      );

      setState(() {
        if (initial) {
          witnesses = result;
        } else {
          witnesses.addAll(result);
        }

        if (result.isEmpty || result.length < _pageSize) {
          _hasMore = false;
        } else {
          _lastWitnessName = result.last.name;
        }
      });
    } catch (e) {
      debugPrint('Error loading witness data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Witnesses')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              controller: _scrollController,
              itemCount: witnesses.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == witnesses.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final witness = witnesses[index];
                return _buildWitnessTile(witness, index + 1);
              },
            ),
    );
  }

  Widget _buildWitnessTile(Account account, int rank) {
    final avatarUrl = "https://images.hive.blog/u/${account.name}/avatar";
    final meta = _extractProfile(account.jsonMetadata);

    return InkWell(
      onTap: () => widget.onTapWitness?.call(account),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '$rank. ${account.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTapLink?.call(account),
              child: const Icon(Icons.link, size: 16),
            ),
          ],
        ),
        subtitle: Text(
          meta['about'] ?? 'No description',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: GestureDetector(
          onTap: () => widget.onTapCheckmark?.call(account),
          child: Icon(
            Icons.check_circle,
            color: approvedWitnesses.contains(account.name)
                ? Colors.green
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _extractProfile(String? metadata) {
    try {
      final decoded = metadata != null
          ? Map<String, dynamic>.from(jsonDecode(metadata))
          : {};
      return decoded['profile'] ?? {};
    } catch (_) {
      return {};
    }
  }
}
