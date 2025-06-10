import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';

String? getVideoUrl(GQLFeedItem item) {
  try {
    final metadata = item.jsonMetadata?['raw'];
    final sourceMap = metadata?['video']?['info'];
    if (sourceMap is Map) {
      return sourceMap['video_v2'];
    }
  } catch (e) {
    print('Video URL parse error: $e');
  }
  return null;
}
