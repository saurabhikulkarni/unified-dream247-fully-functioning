import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/winners/data/models/winners_model.dart';
import 'package:unified_dream247/features/fantasy/winners/data/models/stories_model.dart';
import 'package:unified_dream247/features/fantasy/winners/domain/repositories/winners_repositories.dart';

class WinnersUsecases {
  WinnersRepositories winnersRepositories;
  WinnersUsecases(this.winnersRepositories);

  Future<List<WinnersModel>?>? getRecentMatches(
    BuildContext context,
  ) async {
    var res = await winnersRepositories.getRecentMatches(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<StoriesModel>?>? getStories(BuildContext context) async {
    var res = await winnersRepositories.getStories(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<WinContestData>?>? loadContestWinners(
    BuildContext context,
    String challengeId,
    int skip,
    int limit,
    String fantasyType,
    String matchKey,
  ) async {
    var res = await winnersRepositories.loadContestWinners(
      context,
      challengeId,
      skip,
      limit,
      fantasyType,
      matchKey,
    );
    return res;
  }
}
