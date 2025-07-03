import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/safe_convert.dart';
import 'postJsonMetaDataVideoInfo.dart';

class PostJsonVideo {
  final PostJsonVideoInfo info;

  PostJsonVideo({
    required this.info,
  });

  factory PostJsonVideo.fromJson(Map<String, dynamic>? json) => PostJsonVideo(
        info: PostJsonVideoInfo.fromJson(
          asMap(json, 'info'),
        ),
      );
}
