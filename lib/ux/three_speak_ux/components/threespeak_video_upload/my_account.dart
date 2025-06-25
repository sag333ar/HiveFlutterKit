import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum VideoListType { publishNow, myVideos, encoding }

class MyAccount extends StatefulWidget {
  final String token;
  const MyAccount({super.key, required this.token});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allVideos = [];
  bool isLoading = true;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final uri = Uri.parse('https://studio.3speak.tv/mobile/api/my-videos');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': widget.token,
    };
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          allVideos = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> get encodingVideos =>
      allVideos
          .where(
            (v) => [
              'uploaded',
              'encoding_queued',
              'encoding',
            ].contains(v['status']),
          )
          .toList();

  List<dynamic> get publishNowVideos =>
      allVideos.where((v) => v['status'] == 'publish_manual').toList();

  List<dynamic> get myVideos =>
      allVideos.where((v) => v['status'] == 'published').toList();

  Widget buildVideoList(
    List<dynamic> videos, {
    required VideoListType listType,
  }) {
    if (videos.isEmpty) {
      return const Center(child: Text('No videos found.'));
    }

    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final thumbnailUrl = video['thumbUrl'] ?? '';
        final title = video['title'] ?? 'No Title';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnailUrl,
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Container(width: 100, height: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),

              // Title and spacing
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Publish button only for 'publishNow' tab
              if (listType == VideoListType.publishNow)
                ElevatedButton(
                  onPressed: () {
                    print("Publish video: ${video['_id']}");
                  },
                  child: const Text("Publish"),
                ),

              // Always show the 3-dot icon
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  print("More options for: ${video['_id']}");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Videos"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Publish Now'),
            Tab(text: 'My Videos'),
            Tab(text: 'Encoding'),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  buildVideoList(
                    publishNowVideos,
                    listType: VideoListType.publishNow,
                  ),
                  buildVideoList(myVideos, listType: VideoListType.myVideos),
                  buildVideoList(
                    encodingVideos,
                    listType: VideoListType.encoding,
                  ),
                ],
              ),
    );
  }
}
