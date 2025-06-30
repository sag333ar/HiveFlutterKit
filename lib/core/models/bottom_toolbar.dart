class BottomBarItem {
  final String imagePath;
  final String label;
  final String url;
  final bool isNetwork;

  BottomBarItem({
    required this.imagePath,
    required this.label,
    required this.url,
    this.isNetwork = false,
  });
}