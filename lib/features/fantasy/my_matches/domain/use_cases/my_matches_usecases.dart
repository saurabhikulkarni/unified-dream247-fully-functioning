import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/live_challenges_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_livescore_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/match_player_teams_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/my_matches_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/player_preview_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/scorecard_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/team_compare_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/data/models/team_pdf_range_model.dart';
import 'package:unified_dream247/features/fantasy/my_matches/domain/repositories/my_matches_repositories.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/player_details_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/user_teams_model.dart';

class MyMatchesUsecases {
  MyMatchesRepositories myMatchesRepositories;
  MyMatchesUsecases(this.myMatchesRepositories);

  Future<List<MyMatchesModel>?>? getUpcomingMatches(
    BuildContext context,
    String gameType,
  ) async {
    var res = await myMatchesRepositories.getUpcomingMatches(context, gameType);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<MyMatchesModel>?>? getLiveMatches(
    BuildContext context,
    String gameType,
  ) async {
    var res = await myMatchesRepositories.getLiveMatches(context, gameType);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<MyMatchesModel>?>? getCompletedMatches(
    BuildContext context,
    String gameType,
    int cursor,
  ) async {
    var res = await myMatchesRepositories.getCompletedMatches(
      context,
      gameType,
      cursor,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<MyMatchesModel>?>? getCompletedOldMatches(
    BuildContext context,
    String gameType,
    int skip,
    int limit,
  ) async {
    var res = await myMatchesRepositories.getCompletedOldMatches(
      context,
      gameType,
      skip,
      limit,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<LiveChallengesModel> getJoinedLiveContests(
    BuildContext context,
    int skip,
    int limit,
  ) async {
    var res = await myMatchesRepositories.getJoinedLiveContests(
      context,
      skip,
      limit,
    );
    return res;
  }

  Future<List<TeamsModel>> completeMatchGetMyTeams(BuildContext context) async {
    var res = await myMatchesRepositories.completeMatchGetMyTeams(context);
    return res;
  }

  Future<PlayerDetailsModel?> getPlayerDetails(
    BuildContext context,
    String playerid,
  ) async {
    var res = await myMatchesRepositories.getPlayerDetails(context, playerid);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<MatchPlayerTeamsModel>?>? matchPlayerTeams(
    BuildContext context,
    String joinTeamId,
  ) async {
    var res = await myMatchesRepositories.matchPlayerTeams(context, joinTeamId);
    if (res != null) {
      return res;
    }
    return [];
  }

  Future<List<MatchPlayerTeamsModel>?>? matchplayerfantasyscorecards(
    BuildContext context,
  ) async {
    var res = await myMatchesRepositories.matchplayerfantasyscorecards(context);
    if (res != null) {
      return res;
    }
    return [];
  }

  Future<List<PlayerPreviewModel>?>? dreamTeam(
    BuildContext context,
    String matchKey,
  ) async {
    var res = await myMatchesRepositories.dreamTeam(context, matchKey);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<TeamPdfRangeModel>?>? getTeamFilesPdf(
    BuildContext context,
    String challengeId,
  ) async {
    var res = await myMatchesRepositories.getTeamFilesPdf(context, challengeId);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<ScorecardModel>> getScorecard(BuildContext context) async {
    var res = await myMatchesRepositories.getScorecard(context);
    return res;
  }

  Future<TeamCompareModel?> teamCompare(
    BuildContext context,
    String team1id,
    String team2id,
    String userId,
    String challengeId,
    String l1,
    String l2,
  ) async {
    var res = await myMatchesRepositories.teamCompare(
      context,
      team1id,
      team2id,
      userId,
      challengeId,
      l1,
      l2,
    );
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<List<MatchLiveScoreModel>?>? getMatchLiveScore(
    BuildContext context,
  ) async {
    var res = await myMatchesRepositories.getMatchLiveScore(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getLeaderboardLive(
    BuildContext context,
    String challengeId,
    String finalStatus,
    int skip,
    int limit,
  ) async {
    var res = await myMatchesRepositories.getLeaderboardLive(
      context,
      challengeId,
      finalStatus,
      skip,
      limit,
    );
    return res;
  }

  Future<Map<String, dynamic>?> getSelfLeaderboardLive(
    BuildContext context,
    String challengeId,
    String finalStatus,
    int skip,
    int limit,
  ) async {
    var res = await myMatchesRepositories.getSelfLeaderboardLive(
      context,
      challengeId,
      finalStatus,
      skip,
      limit,
    );
    return res;
  }

  Future<List<TeamsModel>> liveGetMyTeams(BuildContext context) async {
    var res = await myMatchesRepositories.liveGetMyTeams(context);
    return res;
  }

  Future<List<UserTeamsModel>> liveGetUserTeam(
    BuildContext context,
    String joinTeamId,
  ) async {
    var res = await myMatchesRepositories.liveGetUserTeam(context, joinTeamId);
    return res;
  }

  Future<List<PlayerPreviewModel>?>? liveViewTeam(
    BuildContext context,
    String teamId,
    int teamNumber,
    String userId,
  ) async {
    var res = await myMatchesRepositories.liveViewTeam(
      context,
      teamId,
      teamNumber,
      userId,
    );
    if (res != null) {
      return res;
    }
    return null;
  }
}
