import 'package:flutter/material.dart';
import 'package:Dream247/features/landing/data/models/joined_matches_model.dart';
import 'package:Dream247/features/landing/data/models/match_list_model.dart';
import 'package:Dream247/features/landing/data/models/notification_model.dart';

abstract class HomeRepositories {
  Future<bool?> getAppDataWithHeader(BuildContext context);

  Future<String?> fetchPopUpBanner(BuildContext context);

  Future<List<MatchListModel>?>? getMatchList(
    BuildContext context,
    String gameType,
  );

  Future<List<JoinedMatchesModel>?>? getJoinedMatches(
    BuildContext context,
    String gameType,
  );

  Future<List<NotificationModel>?>? getNotifications(BuildContext context);

  Future<bool?> updateContestWon(BuildContext context);
}
