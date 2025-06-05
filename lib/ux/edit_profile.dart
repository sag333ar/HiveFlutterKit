import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final String username;
  final double size;
  final VoidCallback onTap;
  final VoidCallback onReload;

  const EditProfile({
    Key? key,
    required this.username,
    required this.size,
    required this.onTap,
    required this.onReload,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  late String _imageUrl;
  bool _loadFallback = false;
  int _reloadCount = 0;

  @override
  void initState() {
    super.initState();
    _setImageUrl();
  }

  void _setImageUrl() {
    _imageUrl =
        'https://images.hive.blog/u/${widget.username}/avatar?${DateTime.now().millisecondsSinceEpoch + _reloadCount}';
  }

  void reload() {
    widget.onReload();
    setState(() {
      _reloadCount++;
      _loadFallback = false;
      _setImageUrl();
    });
  }

  String get initials {
    final names = widget.username.split(' ');
    return names.length > 1
        ? '${names[0][0]}${names[1][0]}'.toUpperCase()
        : names[0].substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Use root navigator context for modals if needed
        // showModalBottomSheet(
        //   context: Navigator.of(context, rootNavigator: true).context,
        //   ...
        // );
        widget.onTap();
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Colors.grey.shade300,
            child: ClipOval(
              child:
                  _loadFallback
                      ? Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: widget.size / 2.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : Image.network(
                        _imageUrl,
                        width: widget.size,
                        height: widget.size,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: widget.size / 2.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.edit,
                size: widget.size * 0.25,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
