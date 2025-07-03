import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/safe_convert.dart';

import 'post_json_meta_data_video.dart';

class PostJsonMetadata {
  final List<String>? tags;
  final List<String>? image;
  final List<String>? images;
  final List<String>? links;
  final List<String>? users;
  final String? app;
  final PostJsonVideo? video;
  final String? format;

  const PostJsonMetadata({
    required this.tags,
    required this.image,
    this.images = const [],
    this.app = "",
    this.format,
    this.links = const [],
    this.users = const [],
    required this.video,
  });

  factory PostJsonMetadata.fromJson(Map<String, dynamic>? json) =>
      PostJsonMetadata(
        tags: asList(json, 'tags').map((e) => e.toString()).toList(),
        image: _images(json),
        links: asList(json, 'links').map((e) => e.toString()).toList(),
        users: asList(json, 'users').map((e) => e.toString()).toList(),
        format: json?['format'] as String? ?? "",
        app: asString(json, 'app'),
        video: PostJsonVideo.fromJson(
          asMap(json, 'video'),
        ),
      );

  static List<String> _images(Map<String, dynamic>? json) {
    if (json?['image'] != null && json!['image'].isNotEmpty) {
      return asList(json, 'image').map((e) => e.toString()).toList();
    } else if (json?['images'] != null && json!['images'].isNotEmpty) {
      return asList(json, 'images').map((e) => e.toString()).toList();
    } else if (json?['links'] != null && json!['links'].isNotEmpty) {
      return _linkToImage(json['links']);
    } else {
      return [];
    }
  }

  static List<String> _linkToImage(List links) {
    List<String> result = [];
    for (var link in links) {
      int lastBracketIndex = link.lastIndexOf(")");

      result.add(lastBracketIndex != -1
          ? link.substring(0, lastBracketIndex) +
              link.substring(lastBracketIndex + 1)
          : link);
    }
    return result;
  }
}
