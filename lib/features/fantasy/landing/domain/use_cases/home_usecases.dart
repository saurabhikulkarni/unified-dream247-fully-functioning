import 'package:flutter/material.dart';
import 'package:Dream247/features/landing/data/models/joined_matches_model.dart';
import 'package:Dream247/features/landing/data/models/match_list_model.dart';
import 'package:Dream247/features/landing/data/models/notification_model.dart';
import 'package:Dream247/features/landing/domain/repositories/home_repositories.dart';

class HomeUsecases {
  HomeRepositories homeRepositories;
  HomeUsecases(this.homeRepositories);

  Future<bool?> getAppDataWithHeader(BuildContext context) async {
    var res = await homeRepositories.getAppDataWithHeader(context);
    if (res != null) {
      return true;
    }
    return null;
  }

  Future<String?> fetchPopUpBanner(BuildContext context) async {
    var res = await homeRepositories.fetchPopUpBanner(context);
    if (res != null) {
      return res;
    }
    return "";
  }

  Future<List<MatchListModel>?>? getMatchList(
    BuildContext context,
    String gameType,
  ) async {
    var res = await homeRepositories.getMatchList(context, gameType);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<JoinedMatchesModel>?>? getJoinedMatches(
    BuildContext context,
    String gameType,
  ) async {
    var res = await homeRepositories.getJoinedMatches(context, gameType);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<NotificationModel>?>? getNotifications(
    BuildContext context,
  ) async {
    var res = await homeRepositories.getNotifications(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<bool?> updateContestWon(BuildContext context) async {
    var res = await homeRepositories.updateContestWon(context);
    if (res != null) {
      return true;
    }
    return null;
  }
}
