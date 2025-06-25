class Server {
  final String domain = "https://3speak.tv";
  final String myVideosApiUrl = "https://studio.3speak.tv/mobile/api/my-videos";
  final String kThreeSpeakUploadUrl = 'https://uploads.3speak.tv/files/';
  final String kThreeSpeakApiUrl = 'https://studio.3speak.tv/mobile/api';

  String userOwnerThumb(String value) {
    return "https://images.hive.blog/u/$value/avatar";
  }

  String userChannelCover(String value) {
    return "https://img.3speakcontent.co/user/$value/cover.png";
  }

  String communityIcon(String value) {
    return "https://images.hive.blog/u/$value/avatar?size=icon";
  }

  String resizedImage(String value) {
    return "https://images.hive.blog/640x0/$value";
  }
}

Server server = Server();
