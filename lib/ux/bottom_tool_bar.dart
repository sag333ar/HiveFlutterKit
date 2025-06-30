import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/models/bottom_toolbar.dart';
import 'package:hive_flutter_kit/core/utils/constants/url_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomToolbarWithSlider extends StatefulWidget {
  const BottomToolbarWithSlider({
    super.key,
    this.backgroundColor = const Color(0xFF3C3C3C),
  });
  final Color? backgroundColor;

  @override
  State<BottomToolbarWithSlider> createState() =>
      _BottomToolbarWithSliderState();
}

class _BottomToolbarWithSliderState extends State<BottomToolbarWithSlider> {
  int _highlightedIndex = 0;
  late Timer _timer;
  final _username = 'sagarkothari88';
  late final String _avatarUrl;

  late final List<BottomBarItem> _items;

  @override
  void initState() {
    super.initState();
    _avatarUrl =
        'https://images.hive.blog/u/$_username/avatar?${DateTime.now().millisecondsSinceEpoch}';

    _items = [
      BottomBarItem(
        imagePath: _avatarUrl,
        label: 'Vote',
        url: AppUrls.developerWitness,
        isNetwork: true,
      ),
      BottomBarItem(
        imagePath: AppAssets.inbox,
        label: 'Inbox',
        url: AppUrls.inbox,
      ),
      BottomBarItem(
        imagePath: AppAssets.stats,
        label: 'Stats',
        url: AppUrls.stats,
      ),
      BottomBarItem(
        imagePath: AppAssets.donate,
        label: 'Donate',
        url: AppUrls.donate,
      ),
      BottomBarItem(
        imagePath: AppAssets.hifind,
        label: 'HiFind',
        url: AppUrls.hifind,
      ),
      BottomBarItem(
        imagePath: AppAssets.vote,
        label: 'Witness',
        url: AppUrls.witness,
      ),
    ];

    _startHighlightLoop();
  }

  void _startHighlightLoop() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1) % _items.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildItem(BuildContext context, int i) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isActive = i == _highlightedIndex;
    final baseSize = isMobile ? 24.0 : 32.0;
    final scale = isActive ? 1.2 : 0.8;
    final fontSize = isMobile ? 9.0 : 11.0;

    return GestureDetector(
      onTap: () => _launchUrl(_items[i].url),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: baseSize,
                height: baseSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child:
                      _items[i].isNetwork
                          ? Image.network(
                            _items[i].imagePath,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                          )
                          : Image.asset(
                            _items[i].imagePath,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.apps, color: Colors.grey),
                          ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (isActive)
              SizedBox(
                width: baseSize * 2,
                child: Text(
                  _items[i].label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final containerHeight = 64.00;
    final horizontalPadding = isMobile ? 8.0 : 12.0;

    return Container(
      height: containerHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _items.length,
              (i) => _buildItem(context, i),
            ),
          ),
        ),
      ),
    );
  }
}

