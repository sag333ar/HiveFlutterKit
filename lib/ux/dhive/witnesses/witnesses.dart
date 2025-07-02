import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/account.dart';

class Witnesses extends StatefulWidget {
  final void Function(Account account)? onTapWitness;
  final void Function(Account account)? onTapLink;
  final void Function(Account account)? onTapCheckmark;

  const Witnesses({
    super.key,
    this.onTapWitness,
    this.onTapLink,
    this.onTapCheckmark,
  });

  @override
  State<Witnesses> createState() => _WitnessesState();
}

class _WitnessesState extends State<Witnesses> {
  late HiveFlutterKitPlatform hfk;
  List<Account> witnesses = [];
  bool isLoading = true;
  Set<String> approvedWitnesses = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hfk = HiveFlutterKitPlatform.instance;
    _loadWitnessData();
  }

  Future<void> _loadWitnessData() async {
    try {
      String username = await hfk.getCurrentUser();
      username = username.replaceAll('"', '');

      if (username.isEmpty) throw Exception("User not logged in");

      final accounts = await hfk.getAccounts([username]);
      if (accounts.isEmpty) throw Exception("No account info found");

      final account = accounts.first;
      approvedWitnesses = Set<String>.from(account.witnessVotes ?? []);
      final result = await hfk.getWitnessesByVote(limit: 60);

      setState(() {
        witnesses = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading witness data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Witnesses')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: witnesses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
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
