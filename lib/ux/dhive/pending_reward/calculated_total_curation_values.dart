import 'package:hive_flutter_kit/ux/dhive/pending_reward/extract_number.dart';

Map<String, String> calculateTotalsCurationReward(
    List<Map<String, dynamic>> rewardsData) {
  double totalPostReward = 0.0;

  for (var reward in rewardsData) {
    if (reward['postReward'] != null) {
      totalPostReward += extractNumber(reward['postReward']);
    }
  }

  return {
    'postReward': '${totalPostReward.toStringAsFixed(2)} HBD',
  };
}
