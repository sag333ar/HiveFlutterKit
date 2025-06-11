import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/ux/login_screen.dart';

class SwitchUser extends StatefulWidget {
  final HiveFlutterKitPlatform aioha;
  final List<Color> backgroundColors;
  final Color fontColor;
  final Color borderColor;
  final Color addAccountButtonColor;
  final Color addAccountTextColor;
  final String title;
  final Widget logoIcon;
  final String? logoImagePath;
  final ThemeMode themeMode;

  const SwitchUser({
    required this.aioha,
    super.key,
    this.backgroundColors = const [
      Color.fromARGB(255, 160, 163, 165),
      Color(0xFF3498DB),
    ],
    this.fontColor = Colors.white,
    this.borderColor = const Color(0xFFFFFFFF),
    this.addAccountButtonColor = const Color(0xFF2ECC71),
    this.addAccountTextColor = Colors.white,
    this.title = 'Switch Account',
    this.logoIcon = const Icon(
      Icons.person_outline,
      size: 64,
      color: Colors.white,
    ),
    this.logoImagePath,
    this.themeMode = ThemeMode.system,
  });

  @override
  State<SwitchUser> createState() => _SwitchUserState();
}

class _SwitchUserState extends State<SwitchUser> {
  List<String> otherLogins = [];
  String? currentUser;
  String _avatarUrl = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUsers();

    _showBottomSheet();
  }

  Future<void> _fetchUsers() async {
    try {
      final username = await widget.aioha.getCurrentUser();
      final logins = await widget.aioha.getOtherLogins();

      setState(() {
        currentUser = username;
        otherLogins = logins;
        _updateAvatarUrl(username);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1E2A38),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _updateAvatarUrl(String? username) {
    username = username?.replaceAll('"', '');
    if (username != null && username.isNotEmpty) {
      setState(() {
        _avatarUrl = 'https://images.hive.blog/160x40/https://images.hive.blog/u/${username}/avatar';
        currentUser = username;
      });
    } else {
      setState(() {
        _avatarUrl = '';
        currentUser = null;
      });
    }
  }

  void _switchUser(String selectedUser) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to user: $selectedUser')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _getAvatarUrl(String username) {
    return 'https://images.hive.blog/160x40/https://images.hive.blog/u/${username}/avatar';
  }

  void _showBottomSheet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.backgroundColors,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
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
                  if (widget.logoImagePath != null)
                    Image.asset(widget.logoImagePath!, height: 64, width: 64)
                  else
                    widget.logoIcon,
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Current User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      currentUser ?? 'User not logged in',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading:
                        _avatarUrl.isNotEmpty
                            ? CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                _avatarUrl,
                              ),
                              radius: 20,
                            )
                            : const CircleAvatar(
                              child: Icon(Icons.person, color: Colors.white),
                              backgroundColor: Colors.grey,
                              radius: 20,
                            ),
                  ),
                  const Divider(color: Colors.white70),
                  if (otherLogins.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available Users',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return ListView.separated(
                            itemCount: otherLogins.length,
                            separatorBuilder:
                                (context, index) => Divider(
                                  color: Colors.white.withOpacity(0.3),
                                  thickness: 0.5,
                                  height: 1,
                                ),
                            itemBuilder: (context, index) {
                              final username = otherLogins[index];
                              final avatarUrl = _getAvatarUrl(username);
                              return ListTile(
                                title: Text(
                                  username,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    avatarUrl,
                                  ),
                                  radius: 20,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final username = otherLogins[index];
                                    setState(() {
                                      otherLogins.remove(username);
                                    });

                                    try {
                                      final result = await widget.aioha
                                          .removeOtherLogin(username);
                                      print('Removed user: $result');
                                      print('Removed user: $username');
                                      _showMessage('Removed user: $username');
                                    } catch (e) {
                                      print('Failed to remove user: $e');
                                      _showMessage(
                                        'Failed to remove user: $username',
                                      );
                                      setState(() {
                                        otherLogins.add(username);
                                      });
                                    }
                                  },
                                ),
                                onTap: () => _switchUser(username),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ] else
                    const Text(
                      'No other logged-in users available',
                      style: TextStyle(color: Colors.white70),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => LoginScreen(
                                aioha: widget.aioha,
                                backgroundColors: const [
                                  Color(0xFF2C3E50),
                                  Color(0xFFA489CB),
                                ],
                                fontColor: Colors.white,
                                borderColor: Colors.white.withOpacity(0.3),
                                hiveKeychainButtonColor: Colors.green,
                                hiveKeychainTextColor: Colors.white,
                                hiveAuthButtonColor: Colors.orange,
                                hiveAuthTextColor: Colors.white,
                                title: "Welcome to Aioha Hive",
                                subtitle: "Choose your login method",
                                logoIcon: const Icon(
                                  Icons.hexagon_outlined,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                uponLogin: (context, result) {
                                  print('FrontEnd Login Result: $result');
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => SwitchUser(aioha: widget.aioha,),
                                    ),
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.addAccountButtonColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Add Account',
                      style: TextStyle(
                        color: widget.addAccountTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
