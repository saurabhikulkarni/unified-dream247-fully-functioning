import 'package:flutter/material.dart';
import 'package:Dream247/features/winners/data/models/winners_model.dart';
import 'package:Dream247/features/winners/data/models/stories_model.dart';

abstract class WinnersRepositories {
  Future<List<WinnersModel>?>? getRecentMatches(BuildContext context);

  Future<List<StoriesModel>?>? getStories(BuildContext context);

  Future<List<WinContestData>?>? loadContestWinners(
    BuildContext context,
    String challengeId,
    int skip,
    int limit,
    String fantasyType,
    String matchKey,
  );
}
