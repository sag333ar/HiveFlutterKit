import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/account.dart';

class Witnesses extends StatefulWidget {
  const Witnesses({super.key});

  @override
  State<Witnesses> createState() => _WitnessesState();
}

class _WitnessesState extends State<Witnesses> {
  late HiveFlutterKitPlatform hfk;
  List<Account> witnesses = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hfk = HiveFlutterKitPlatform.instance;
    _getWitnessesByVote();
  }

  Future<void> _getWitnessesByVote() async {
    try {
      final result = await hfk.getWitnessesByVote(limit: 10);
      setState(() {
        witnesses = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching witnesses by vote: $e');
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Row(
        children: [
          Text('$rank. ${account.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          const Icon(Icons.link, size: 16),
        ],
      ),
      subtitle: Text(meta['about'] ?? 'No description', maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  Map<String, dynamic> _extractProfile(String? metadata) {
    try {
      final decoded = metadata != null ? Map<String, dynamic>.from(jsonDecode(metadata)) : {};
      return decoded['profile'] ?? {};
    } catch (_) {
      return {};
    }
  }
}
