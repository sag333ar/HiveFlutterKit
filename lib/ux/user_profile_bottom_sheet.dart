import 'package:flutter/material.dart';

class UserProfileBottomSheet extends StatefulWidget {
  const UserProfileBottomSheet({super.key});

  @override
  State<UserProfileBottomSheet> createState() => _UserProfileBottomSheetState();
}

class _UserProfileBottomSheetState extends State<UserProfileBottomSheet> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _showBottomSheet();
  }

  ListTile _buildListTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        // Navigation logic to be implemented later
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(255, 160, 163, 165), Color(0xFF3498DB)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'User Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: 8,
                separatorBuilder:
                    (context, index) => Divider(
                      color: Colors.white.withOpacity(0.3),
                      thickness: 0.5,
                      height: 12, // Add vertical space
                    ),
                itemBuilder: (context, index) {
                  final items = [
                    {'title': 'Write a post', 'icon': Icons.edit},
                    {'title': 'My posts', 'icon': Icons.article},
                    {'title': 'My blog', 'icon': Icons.book},
                    {'title': 'Comments', 'icon': Icons.comment},
                    {'title': 'Replies', 'icon': Icons.reply},
                    {'title': 'Notifications', 'icon': Icons.notifications},
                    {'title': 'Switch user', 'icon': Icons.switch_account},
                    {'title': 'Log out', 'icon': Icons.logout},
                  ];
                  return _buildListTile(
                    items[index]['title'] as String,
                    items[index]['icon'] as IconData,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
