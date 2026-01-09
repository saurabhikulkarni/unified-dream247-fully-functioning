import 'package:flutter/material.dart';

import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/live_challenges_model.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/match_livescore_model.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/match_player_teams_model.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/my_matches_model.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/player_preview_model.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/scorecard_model.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/team_compare_model.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/data/models/team_pdf_range_model.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/models/player_details_model.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/models/teams_model.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/data/models/user_teams_model.dart';

abstract class MyMatchesRepositories {
  Future<List<MyMatchesModel>?>? getUpcomingMatches(
    BuildContext context,
    String gameType,
  );

  Future<List<MyMatchesModel>?>? getLiveMatches(
    BuildContext context,
    String gameType,
  );

  Future<List<MyMatchesModel>?>? getCompletedMatches(
    BuildContext context,
    String gameType,
    int cursor,
  );

  Future<List<MyMatchesModel>?>? getCompletedOldMatches(
    BuildContext context,
    String gameType,
    int skip,
    int limit,
  );

  Future<List<TeamsModel>> liveGetMyTeams(BuildContext context);

  Future<LiveChallengesModel> getJoinedLiveContests(
    BuildContext context,
    int skip,
    int limit,
  );

  Future<List<UserTeamsModel>> liveGetUserTeam(
    BuildContext context,
    String joinTeamId,
  );

  Future<List<TeamsModel>> completeMatchGetMyTeams(BuildContext context);

  Future<List<PlayerPreviewModel>?>? liveViewTeam(
    BuildContext context,
    String teamId,
    int teamNumber,
    String userId,
  );

  Future<Map<String, dynamic>?> getLeaderboardLive(
    BuildContext context,
    String challengeId,
    String finalStatus,
    int skip,
    int limit,
  );

  Future<Map<String, dynamic>?> getSelfLeaderboardLive(
    BuildContext context,
    String challengeId,
    String finalStatus,
    int skip,
    int limit,
  );

  Future<List<TeamPdfRangeModel>?>? getTeamFilesPdf(
    BuildContext context,
    String challengeId,
  );

  Future<List<ScorecardModel>> getScorecard(BuildContext context);

  Future<List<PlayerPreviewModel>?>? dreamTeam(
    BuildContext context,
    String matchKey,
  );

  Future<TeamCompareModel?> teamCompare(
    BuildContext context,
    String team1id,
    String team2id,
    String userId,
    String challengeId,
    String l1,
    String l2,
  );

  Future<List<MatchLiveScoreModel>?>? getMatchLiveScore(BuildContext context);

  Future<PlayerDetailsModel?> getPlayerDetails(
    BuildContext context,
    String playerid,
  );

  Future<List<MatchPlayerTeamsModel>?>? matchPlayerTeams(
    BuildContext context,
    String joinTeamId,
  );

  Future<List<MatchPlayerTeamsModel>?>? matchplayerfantasyscorecards(
    BuildContext context,
  );
}
