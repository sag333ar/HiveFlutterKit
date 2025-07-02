import 'package:flutter/material.dart';

class AccountGridView extends StatelessWidget {
  final List<dynamic> accounts;
  final String Function(dynamic item) getUsername;

  const AccountGridView({
    super.key,
    required this.accounts,
    required this.getUsername,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth >= 900) {
          crossAxisCount = 6;
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: accounts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final item = accounts[index];
              final username = getUsername(item);
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
    );
  }
}
