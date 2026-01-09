import 'package:Dream247/core/utils/model_parsers.dart';

class LevelRewardModel {
  int? currentLevel;
  int? nextLevel;
  int? totalPlayContest;
  String? numberOfWinningContest;
  int? totalWinningContest;
  int? nextLevelReward;
  int? processForNext;
  String? rewardType;
  bool? allLevelCompleted;

  LevelRewardModel({
    this.currentLevel,
    this.nextLevel,
    this.totalPlayContest,
    this.numberOfWinningContest,
    this.totalWinningContest,
    this.nextLevelReward,
    this.processForNext,
    this.rewardType,
    this.allLevelCompleted,
  });

  LevelRewardModel.fromJson(Map<String, dynamic> json) {
    currentLevel = ModelParsers.toIntParser(json["currentLevel"]);
    nextLevel = ModelParsers.toIntParser(json["nextLevel"]);
    totalPlayContest = ModelParsers.toIntParser(json["totalPlayContest"]);
    totalWinningContest = ModelParsers.toIntParser(json["totalWinningContest"]);
    nextLevelReward = ModelParsers.toIntParser(json["nextLevelReward"]);
    processForNext = ModelParsers.toIntParser(json["processForNext"]);
    rewardType = ModelParsers.toStringParser(json["rewardType"]);
    numberOfWinningContest = ModelParsers.toStringParser(
      json["NumberOfWinningContest"],
    );
    allLevelCompleted = ModelParsers.toBoolParser(json["allLevelCompleted"]);
  }
}
